import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:japanana/core/extensions.dart';
import 'package:japanana/core/presentation/widgets/neo_button.dart';
import 'package:japanana/core/presentation/widgets/note_background.dart';
import 'package:japanana/features/in_review/data/recap_video_encoder.dart';
import 'package:japanana/features/in_review/domain/session_recap.dart';
import 'package:japanana/features/in_review/presentation/recap/recap_frame.dart';
import 'package:japanana/features/in_review/presentation/widgets/review_widgets.dart';
import 'package:japanana/features/settings/data/external_actions.dart';
import 'package:path_provider/path_provider.dart';

const _kFps = 24;
const _kPixelRatio = 2.0;

/// Frame shared as an image where video can't be encoded: the stats.
const _kStillProgress = 0.36;

/// Plays the recap and exports it as a video (or image) to share.
class RecapShareScreen extends HookConsumerWidget {
  const RecapShareScreen({required this.recap, super.key});

  final SessionRecap recap;

  static Future<void> show(BuildContext context, SessionRecap recap) =>
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => RecapShareScreen(recap: recap)),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final neo = context.neo;
    final encoder = ref.watch(recapVideoEncoderProvider);
    final player = useAnimationController(duration: kRecapDuration);
    final frame = useState<double?>(null);
    final exporting = useState<double?>(null);
    final boundaryKey = useMemoized(GlobalKey.new);
    final buttonKey = useMemoized(GlobalKey.new);

    useEffect(() {
      player.repeat();
      return null;
    }, const []);

    Rect? shareOrigin() {
      final box = buttonKey.currentContext?.findRenderObject() as RenderBox?;
      return box == null ? null : box.localToGlobal(Offset.zero) & box.size;
    }

    Future<ui.Image> capture(double progress) async {
      frame.value = progress;
      await WidgetsBinding.instance.endOfFrame;
      final boundary =
          boundaryKey.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
      return boundary.toImage(pixelRatio: _kPixelRatio);
    }

    Future<void> export() async {
      if (exporting.value != null) return;
      final messenger = ScaffoldMessenger.of(context);
      final failed = l10n.recapFailed;
      final text = l10n.recapShareText(recap.cards, recap.firstTryPercent);
      final actions = ref.read(externalActionsProvider);
      final origin = shareOrigin();
      player.stop();
      exporting.value = 0;
      try {
        final directory = await getTemporaryDirectory();
        if (encoder.isSupported) {
          final frames = kRecapDuration.inMilliseconds * _kFps ~/ 1000;
          final path = '${directory.path}/japanana-recap.mp4';
          await encoder.start(
            path: path,
            width: (kRecapSize.width * _kPixelRatio).round(),
            height: (kRecapSize.height * _kPixelRatio).round(),
            fps: _kFps,
          );
          for (var i = 0; i < frames; i++) {
            final image = await capture(i / (frames - 1));
            // Raw RGBA is the default format.
            final bytes = await image.toByteData();
            image.dispose();
            await encoder.addFrame(bytes!.buffer.asUint8List());
            exporting.value = (i + 1) / frames;
          }
          final video = await encoder.finish();
          await actions.shareFile(
            video,
            mimeType: 'video/mp4',
            text: text,
            shareOrigin: origin,
          );
        } else {
          final image = await capture(_kStillProgress);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          image.dispose();
          final file = File('${directory.path}/japanana-recap.png');
          await file.writeAsBytes(bytes!.buffer.asUint8List());
          await actions.shareFile(
            file.path,
            mimeType: 'image/png',
            text: text,
            shareOrigin: origin,
          );
        }
      } on Exception {
        messenger.showSnackBar(SnackBar(content: Text(failed)));
      } finally {
        if (context.mounted) {
          exporting.value = null;
          frame.value = null;
          player.repeat();
        }
      }
    }

    final progress = exporting.value;
    return Stack(
      children: [
        const NoteBackground(),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(
              l10n.recapTitle,
              style: context.textTheme.headlineSmall,
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: kRecapSize.aspectRatio,
                        child: DecoratedBox(
                          decoration: neo.decoration(),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(neo.radius - 3),
                            child: FittedBox(
                              child: RepaintBoundary(
                                key: boundaryKey,
                                child: AnimatedBuilder(
                                  animation: player,
                                  builder: (context, _) => RecapFrame(
                                    recap: recap,
                                    progress: frame.value ?? player.value,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (progress != null) ...[
                    Text(
                      l10n.recapRendering((progress * 100).round()),
                      style: TextStyle(
                        fontFamily: kReviewFont,
                        fontWeight: FontWeight.bold,
                        color: neo.onCard,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 14,
                      decoration: BoxDecoration(
                        color: neo.card,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: neo.border, width: 2.5),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progress,
                        child: Container(color: neo.accent),
                      ),
                    ),
                  ] else
                    Padding(
                      key: buttonKey,
                      padding: const EdgeInsets.only(right: 5),
                      child: NeoButton(
                        onPressed: export,
                        color: neo.accent,
                        foregroundColor: neo.onAccent,
                        shadowColor: neo.accentShadow,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.ios_share, color: neo.onAccent),
                            const SizedBox(width: 10),
                            Text(
                              (encoder.isSupported
                                      ? l10n.recapShareVideo
                                      : l10n.recapShareImage)
                                  .toUpperCase(),
                              style: const TextStyle(
                                fontFamily: kReviewFont,
                                fontSize: 16,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
