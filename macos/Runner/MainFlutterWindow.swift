import AVFoundation
import Accelerate
import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  private var recapVideoEncoder: RecapVideoEncoder?

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
    recapVideoEncoder = RecapVideoEncoder(messenger: flutterViewController.engine.binaryMessenger)

    super.awakeFromNib()
  }
}

/// Encodes the session recap frames sent from Dart into an H.264 MP4.
final class RecapVideoEncoder {
  private let queue = DispatchQueue(label: "japanana.recap-video")
  private var writer: AVAssetWriter?
  private var input: AVAssetWriterInput?
  private var adaptor: AVAssetWriterInputPixelBufferAdaptor?
  private var path = ""
  private var width = 0
  private var height = 0
  private var fps: Int32 = 24
  private var frameIndex: Int64 = 0

  init(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "japanana/recap_video", binaryMessenger: messenger)
    channel.setMethodCallHandler { [weak self] call, result in
      self?.handle(call, result: result)
    }
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as? [String: Any] ?? [:]
    queue.async {
      do {
        var value: Any?
        switch call.method {
        case "start":
          try self.start(
            path: args["path"] as? String ?? "",
            width: args["width"] as? Int ?? 0,
            height: args["height"] as? Int ?? 0,
            fps: Int32(args["fps"] as? Int ?? 24))
        case "addFrame":
          guard let data = args["rgba"] as? FlutterStandardTypedData else {
            throw RecapVideoError.badFrame
          }
          try self.addFrame(data.data)
        case "finish":
          value = try self.finish()
        default:
          DispatchQueue.main.async { result(FlutterMethodNotImplemented) }
          return
        }
        DispatchQueue.main.async { result(value) }
      } catch {
        DispatchQueue.main.async {
          result(FlutterError(code: "recap_video", message: "\(error)", details: nil))
        }
      }
    }
  }

  private func start(path: String, width: Int, height: Int, fps: Int32) throws {
    let url = URL(fileURLWithPath: path)
    try? FileManager.default.removeItem(at: url)
    let writer = try AVAssetWriter(outputURL: url, fileType: .mp4)
    let input = AVAssetWriterInput(
      mediaType: .video,
      outputSettings: [
        AVVideoCodecKey: AVVideoCodecType.h264,
        AVVideoWidthKey: width,
        AVVideoHeightKey: height,
        AVVideoCompressionPropertiesKey: [AVVideoAverageBitRateKey: 6_000_000],
      ])
    input.expectsMediaDataInRealTime = false
    let adaptor = AVAssetWriterInputPixelBufferAdaptor(
      assetWriterInput: input,
      sourcePixelBufferAttributes: [
        kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
        kCVPixelBufferWidthKey as String: width,
        kCVPixelBufferHeightKey as String: height,
      ])
    guard writer.canAdd(input) else { throw RecapVideoError.cannotStart }
    writer.add(input)
    guard writer.startWriting() else { throw writer.error ?? RecapVideoError.cannotStart }
    writer.startSession(atSourceTime: .zero)
    self.writer = writer
    self.input = input
    self.adaptor = adaptor
    self.path = path
    self.width = width
    self.height = height
    self.fps = fps
    frameIndex = 0
  }

  private func addFrame(_ rgba: Data) throws {
    guard let input = input, let adaptor = adaptor, rgba.count >= width * height * 4 else {
      throw RecapVideoError.badFrame
    }
    while !input.isReadyForMoreMediaData {
      Thread.sleep(forTimeInterval: 0.005)
    }
    var buffer: CVPixelBuffer?
    if let pool = adaptor.pixelBufferPool {
      CVPixelBufferPoolCreatePixelBuffer(nil, pool, &buffer)
    } else {
      CVPixelBufferCreate(nil, width, height, kCVPixelFormatType_32BGRA, nil, &buffer)
    }
    guard let pixelBuffer = buffer else { throw RecapVideoError.badFrame }
    CVPixelBufferLockBaseAddress(pixelBuffer, [])
    defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, []) }
    guard let base = CVPixelBufferGetBaseAddress(pixelBuffer) else { throw RecapVideoError.badFrame }
    let rowBytes = CVPixelBufferGetBytesPerRow(pixelBuffer)
    var source = rgba
    let error: vImage_Error = source.withUnsafeMutableBytes { bytes in
      var src = vImage_Buffer(
        data: bytes.baseAddress, height: vImagePixelCount(height),
        width: vImagePixelCount(width), rowBytes: width * 4)
      var dst = vImage_Buffer(
        data: base, height: vImagePixelCount(height),
        width: vImagePixelCount(width), rowBytes: rowBytes)
      // RGBA from Flutter to the BGRA the encoder expects.
      let map: [UInt8] = [2, 1, 0, 3]
      return vImagePermuteChannels_ARGB8888(&src, &dst, map, vImage_Flags(kvImageNoFlags))
    }
    guard error == kvImageNoError else { throw RecapVideoError.badFrame }
    let time = CMTime(value: frameIndex, timescale: fps)
    guard adaptor.append(pixelBuffer, withPresentationTime: time) else {
      throw writer?.error ?? RecapVideoError.badFrame
    }
    frameIndex += 1
  }

  private func finish() throws -> String {
    guard let writer = writer, let input = input else { throw RecapVideoError.cannotStart }
    input.markAsFinished()
    let done = DispatchSemaphore(value: 0)
    writer.finishWriting { done.signal() }
    done.wait()
    self.writer = nil
    self.input = nil
    self.adaptor = nil
    if writer.status != .completed {
      throw writer.error ?? RecapVideoError.cannotStart
    }
    return path
  }
}

enum RecapVideoError: Error {
  case cannotStart
  case badFrame
}
