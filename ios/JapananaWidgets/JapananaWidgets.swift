import SwiftUI
import WidgetKit

// Shared with the app through the App Group, written by `WidgetBridge` in
// Runner/AppDelegate.swift.
private let appGroup = "group.com.lucas-goldner.hikou"
private let snapshotKey = "widget_snapshot"

// MARK: - Data

struct WidgetGrammar: Codable {
  let title: String
  let usage: String
  let example: String
  let translation: String
  let book: String
}

struct WidgetDay: Codable {
  let date: String
  let cards: Int
}

struct WidgetLabels: Codable {
  let dayStreak: String
  let cardsToday: String
  let studyToday: String
  let grammarOfDay: String
  let thisWeek: String
  let supporterPerk: String
  let openToUnlock: String

  static let english = WidgetLabels(
    dayStreak: "day streak",
    cardsToday: "cards today",
    studyToday: "Study today to keep it!",
    grammarOfDay: "Grammar of the day",
    thisWeek: "This week",
    supporterPerk: "Supporter perk",
    openToUnlock: "Become a supporter in Japanana to unlock widgets.")
}

/// What the app last told the widgets.
struct WidgetSnapshot: Codable {
  let isSupporter: Bool
  let streak: Int
  let lastStudyDate: String?
  let days: [WidgetDay]
  let grammar: WidgetGrammar?
  let locale: String
  let labels: WidgetLabels

  static let locked = WidgetSnapshot(
    isSupporter: false, streak: 0, lastStudyDate: nil, days: [], grammar: nil,
    locale: "en", labels: .english)

  /// Shown in the widget gallery.
  static var preview: WidgetSnapshot {
    let today = Date()
    let counts = [8, 12, 0, 15, 20, 9, 18]
    let days = counts.enumerated().map { index, cards in
      WidgetDay(date: dayString(daysAgo: counts.count - 1 - index, from: today), cards: cards)
    }
    return WidgetSnapshot(
      isSupporter: true, streak: 12, lastStudyDate: dayString(daysAgo: 0, from: today),
      days: days,
      grammar: WidgetGrammar(
        title: "んです", usage: "Asking to confirm, or giving a reason",
        example: "雨が降っているんですか", translation: "Is it raining?", book: "N4"),
      locale: "en", labels: .english)
  }

  static func load() -> WidgetSnapshot {
    guard let json = UserDefaults(suiteName: appGroup)?.string(forKey: snapshotKey),
      let snapshot = try? JSONDecoder().decode(WidgetSnapshot.self, from: Data(json.utf8))
    else { return .locked }
    return snapshot
  }

  /// The streak as of today: it ends when a whole day passed without study.
  func currentStreak(on date: Date = Date()) -> Int {
    guard let last = lastStudyDate else { return 0 }
    let alive = [dayString(daysAgo: 0, from: date), dayString(daysAgo: 1, from: date)]
    return alive.contains(last) ? streak : 0
  }

  func studiedToday(on date: Date = Date()) -> Bool {
    lastStudyDate == dayString(daysAgo: 0, from: date)
  }

  func cardsToday(on date: Date = Date()) -> Int {
    cards(on: dayString(daysAgo: 0, from: date))
  }

  func cards(on day: String) -> Int {
    days.first { $0.date == day }?.cards ?? 0
  }

  /// The last seven days ending today, oldest first.
  func week(on date: Date = Date()) -> [(label: String, cards: Int, isToday: Bool)] {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: locale)
    formatter.setLocalizedDateFormatFromTemplate("EEEEE")
    return (0..<7).reversed().map { daysAgo in
      let day = Calendar.current.date(byAdding: .day, value: -daysAgo, to: date) ?? date
      return (formatter.string(from: day), cards(on: dayString(daysAgo: 0, from: day)), daysAgo == 0)
    }
  }
}

private func dayString(daysAgo: Int, from date: Date) -> String {
  let day = Calendar.current.date(byAdding: .day, value: -daysAgo, to: date) ?? date
  let parts = Calendar.current.dateComponents([.year, .month, .day], from: day)
  return String(format: "%04ld-%02ld-%02ld", parts.year ?? 0, parts.month ?? 0, parts.day ?? 0)
}

// MARK: - Timeline

struct SnapshotEntry: TimelineEntry {
  let date: Date
  let snapshot: WidgetSnapshot
}

struct SnapshotProvider: TimelineProvider {
  func placeholder(in context: Context) -> SnapshotEntry {
    SnapshotEntry(date: Date(), snapshot: .preview)
  }

  func getSnapshot(in context: Context, completion: @escaping (SnapshotEntry) -> Void) {
    let snapshot = context.isPreview ? WidgetSnapshot.preview : WidgetSnapshot.load()
    completion(SnapshotEntry(date: Date(), snapshot: snapshot))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<SnapshotEntry>) -> Void) {
    let now = Date()
    let entry = SnapshotEntry(date: now, snapshot: WidgetSnapshot.load())
    // Redraw after midnight so the streak and today's cards roll over.
    let tomorrow = Calendar.current.startOfDay(
      for: Calendar.current.date(byAdding: .day, value: 1, to: now) ?? now)
    completion(Timeline(entries: [entry], policy: .after(tomorrow)))
  }
}

// MARK: - Style

private extension Color {
  init(hex: UInt32) {
    self.init(
      red: Double((hex >> 16) & 0xFF) / 255,
      green: Double((hex >> 8) & 0xFF) / 255,
      blue: Double(hex & 0xFF) / 255)
  }
}

/// The app's neubrutalism tokens: light paper or the midnight notebook.
struct Palette {
  let paper: Color
  let card: Color
  let ink: Color
  let muted: Color
  let accent: Color
  let onAccent: Color
  let shadow: Color
  let red: Color

  static func of(_ scheme: ColorScheme) -> Palette {
    scheme == .dark
      ? Palette(
        paper: Color(hex: 0x1A1E29), card: Color(hex: 0x2D3446), ink: Color(hex: 0xECE9F7),
        muted: Color(hex: 0xB9B6C6), accent: Color(hex: 0xF8D318), onAccent: Color(hex: 0x171002),
        shadow: Color(hex: 0xF8D318), red: Color(hex: 0xD05557))
      : Palette(
        paper: Color(hex: 0xF7F5FF), card: .white, ink: .black,
        muted: Color(hex: 0x4A4A55), accent: Color(hex: 0xF8D318), onAccent: .black,
        shadow: .black, red: Color(hex: 0xD05557))
  }
}

/// Outlined card with a hard offset shadow.
struct NeoCard<Content: View>: View {
  let palette: Palette
  var fill: Color? = nil
  var shadow: Color? = nil
  var radius: CGFloat = 14
  @ViewBuilder let content: () -> Content

  var body: some View {
    content()
      .background(
        RoundedRectangle(cornerRadius: radius, style: .continuous)
          .fill(fill ?? palette.card)
      )
      .overlay(
        RoundedRectangle(cornerRadius: radius, style: .continuous)
          .stroke(palette.ink, lineWidth: 2.5)
      )
      .background(
        RoundedRectangle(cornerRadius: radius, style: .continuous)
          .fill(shadow ?? palette.shadow)
          .offset(x: 3, y: 3)
      )
  }
}

/// Graph paper behind every widget.
struct GridPaper: View {
  let palette: Palette

  var body: some View {
    GeometryReader { geometry in
      Path { path in
        let cell: CGFloat = 14
        var x = cell
        while x < geometry.size.width {
          path.move(to: CGPoint(x: x, y: 0))
          path.addLine(to: CGPoint(x: x, y: geometry.size.height))
          x += cell
        }
        var y = cell
        while y < geometry.size.height {
          path.move(to: CGPoint(x: 0, y: y))
          path.addLine(to: CGPoint(x: geometry.size.width, y: y))
          y += cell
        }
      }
      .stroke(palette.ink.opacity(0.08), lineWidth: 0.7)
    }
    .background(palette.paper)
  }
}

private extension View {
  func widgetBackground(_ palette: Palette, fill: Color? = nil) -> some View {
    containerBackground(for: .widget) {
      if let fill { fill } else { GridPaper(palette: palette) }
    }
  }
}

// MARK: - Shared views

struct Pill: View {
  let text: String
  let palette: Palette
  var fill: Color? = nil
  var foreground: Color? = nil

  var body: some View {
    Text(text)
      .font(.system(size: 10, weight: .heavy, design: .rounded))
      .textCase(.uppercase)
      .foregroundStyle(foreground ?? palette.ink)
      .padding(.horizontal, 7)
      .padding(.vertical, 3)
      .background(Capsule().fill(fill ?? palette.card))
      .overlay(Capsule().stroke(palette.ink, lineWidth: 1.5))
  }
}

/// Shown instead of the content until the learner is a supporter.
struct LockedView: View {
  let snapshot: WidgetSnapshot
  let palette: Palette
  var compact = false

  var body: some View {
    VStack(spacing: compact ? 6 : 10) {
      ZStack(alignment: .topTrailing) {
        Image("NanaSleep")
          .resizable()
          .scaledToFit()
          .frame(height: compact ? 64 : 86)
        Image(systemName: "lock.fill")
          .font(.system(size: 12, weight: .bold))
          .foregroundStyle(palette.onAccent)
          .padding(6)
          .background(Circle().fill(palette.accent))
          .overlay(Circle().stroke(palette.ink, lineWidth: 1.5))
      }
      Pill(
        text: snapshot.labels.supporterPerk, palette: palette, fill: palette.accent,
        foreground: palette.onAccent)
      if !compact {
        Text(snapshot.labels.openToUnlock)
          .font(.system(size: 12, weight: .semibold, design: .rounded))
          .foregroundStyle(palette.muted)
          .multilineTextAlignment(.center)
      }
    }
  }
}

// MARK: - Streak widget

struct StreakView: View {
  @Environment(\.widgetFamily) private var family
  @Environment(\.colorScheme) private var scheme
  let entry: SnapshotEntry

  var body: some View {
    let palette = Palette.of(scheme)
    let snapshot = entry.snapshot
    let streak = snapshot.currentStreak(on: entry.date)
    switch family {
    case .accessoryCircular:
      ZStack {
        AccessoryWidgetBackground()
        VStack(spacing: 0) {
          Image(systemName: snapshot.isSupporter ? "flame.fill" : "lock.fill")
            .font(.system(size: 14, weight: .bold))
          if snapshot.isSupporter {
            Text("\(streak)").font(.system(size: 20, weight: .heavy, design: .rounded))
          }
        }
      }
      .containerBackground(for: .widget) { Color.clear }
    case .accessoryRectangular:
      HStack(spacing: 8) {
        Image(systemName: snapshot.isSupporter ? "flame.fill" : "lock.fill")
          .font(.system(size: 22, weight: .bold))
        VStack(alignment: .leading, spacing: 0) {
          if snapshot.isSupporter {
            Text("\(streak) \(snapshot.labels.dayStreak)")
              .font(.system(size: 15, weight: .heavy, design: .rounded))
            Text("\(snapshot.cardsToday(on: entry.date)) \(snapshot.labels.cardsToday)")
              .font(.system(size: 12, weight: .semibold, design: .rounded))
          } else {
            Text(snapshot.labels.supporterPerk)
              .font(.system(size: 14, weight: .heavy, design: .rounded))
          }
        }
        Spacer(minLength: 0)
      }
      .containerBackground(for: .widget) { Color.clear }
    case .accessoryInline:
      Label(
        snapshot.isSupporter ? "\(streak) \(snapshot.labels.dayStreak)" : snapshot.labels.supporterPerk,
        systemImage: snapshot.isSupporter ? "flame.fill" : "lock.fill"
      )
      .containerBackground(for: .widget) { Color.clear }
    default:
      Group {
        if snapshot.isSupporter {
          smallStreak(snapshot: snapshot, streak: streak, palette: palette)
        } else {
          LockedView(snapshot: snapshot, palette: palette, compact: true)
        }
      }
      .widgetBackground(palette, fill: snapshot.isSupporter ? palette.accent : nil)
    }
  }

  private func smallStreak(snapshot: WidgetSnapshot, streak: Int, palette: Palette) -> some View {
    let studied = snapshot.studiedToday(on: entry.date)
    return ZStack(alignment: .topTrailing) {
      Image("Nana")
        .resizable()
        .scaledToFit()
        .frame(width: 72, height: 72)
        .offset(x: 14, y: -10)
      VStack(alignment: .leading, spacing: 0) {
        Image(systemName: "flame.fill")
          .font(.system(size: 20, weight: .bold))
          .foregroundStyle(palette.red)
        Spacer(minLength: 0)
        Text("\(streak)")
          .font(.system(size: 54, weight: .black, design: .rounded))
          .foregroundStyle(Color.black)
          .minimumScaleFactor(0.6)
          .lineLimit(1)
        Text(snapshot.labels.dayStreak)
          .font(.system(size: 13, weight: .heavy, design: .rounded))
          .foregroundStyle(Color.black)
        Spacer(minLength: 6)
        NeoCard(palette: Palette.of(.light), radius: 9) {
          Text(
            studied
              ? "\(snapshot.cardsToday(on: entry.date)) \(snapshot.labels.cardsToday)"
              : snapshot.labels.studyToday
          )
          .font(.system(size: 10, weight: .heavy, design: .rounded))
          .foregroundStyle(Color.black)
          .lineLimit(1)
          .minimumScaleFactor(0.7)
          .padding(.horizontal, 7)
          .padding(.vertical, 4)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
  }
}

struct StreakWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: "JapananaStreak", provider: SnapshotProvider()) { entry in
      StreakView(entry: entry)
    }
    .configurationDisplayName("Streak")
    .description("Your study streak and today's cards.")
    .supportedFamilies([.systemSmall, .accessoryCircular, .accessoryRectangular, .accessoryInline])
  }
}

// MARK: - Grammar of the day widget

struct GrammarView: View {
  @Environment(\.widgetFamily) private var family
  @Environment(\.colorScheme) private var scheme
  let entry: SnapshotEntry

  var body: some View {
    let palette = Palette.of(scheme)
    let snapshot = entry.snapshot
    Group {
      if !snapshot.isSupporter {
        LockedView(snapshot: snapshot, palette: palette, compact: family == .systemSmall)
      } else if let grammar = snapshot.grammar {
        content(grammar: grammar, labels: snapshot.labels, palette: palette)
      } else {
        Image("Nana").resizable().scaledToFit().padding(12)
      }
    }
    .widgetBackground(palette)
  }

  private func content(grammar: WidgetGrammar, labels: WidgetLabels, palette: Palette) -> some View {
    HStack(alignment: .top, spacing: 10) {
      VStack(alignment: .leading, spacing: 6) {
        HStack(spacing: 6) {
          Pill(text: grammar.book, palette: palette, fill: palette.accent, foreground: palette.onAccent)
          if family != .systemSmall {
            Text(labels.grammarOfDay)
              .font(.system(size: 11, weight: .heavy, design: .rounded))
              .foregroundStyle(palette.muted)
          }
        }
        Text(grammar.title)
          .font(.system(size: family == .systemSmall ? 24 : 28, weight: .black))
          .foregroundStyle(palette.ink)
          .lineLimit(1)
          .minimumScaleFactor(0.5)
        Text(grammar.usage)
          .font(.system(size: 12, weight: .semibold, design: .rounded))
          .foregroundStyle(palette.muted)
          .lineLimit(family == .systemSmall ? 4 : 2)
        if family != .systemSmall {
          Spacer(minLength: 0)
          NeoCard(palette: palette, radius: 10) {
            VStack(alignment: .leading, spacing: 2) {
              Text(grammar.example)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(palette.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
              Text(grammar.translation)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(palette.muted)
                .lineLimit(1)
            }
            .padding(.horizontal, 9)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity, alignment: .leading)
          }
        }
      }
      if family != .systemSmall {
        Image("Nana")
          .resizable()
          .scaledToFit()
          .frame(width: 76)
      }
    }
  }
}

struct GrammarWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: "JapananaGrammar", provider: SnapshotProvider()) { entry in
      GrammarView(entry: entry)
    }
    .configurationDisplayName("Grammar of the day")
    .description("A new grammar point from your books every day.")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}

// MARK: - Week widget

struct WeekView: View {
  @Environment(\.widgetFamily) private var family
  @Environment(\.colorScheme) private var scheme
  let entry: SnapshotEntry

  var body: some View {
    let palette = Palette.of(scheme)
    let snapshot = entry.snapshot
    Group {
      if snapshot.isSupporter {
        content(snapshot: snapshot, palette: palette)
      } else {
        LockedView(snapshot: snapshot, palette: palette)
      }
    }
    .widgetBackground(palette)
  }

  private func content(snapshot: WidgetSnapshot, palette: Palette) -> some View {
    let week = snapshot.week(on: entry.date)
    let most = max(week.map { $0.cards }.max() ?? 0, 1)
    return VStack(alignment: .leading, spacing: 10) {
      HStack(alignment: .center, spacing: 8) {
        NeoCard(palette: palette, fill: palette.accent, shadow: palette.ink, radius: 10) {
          HStack(spacing: 4) {
            Image(systemName: "flame.fill").foregroundStyle(palette.red)
            Text("\(snapshot.currentStreak(on: entry.date))")
              .font(.system(size: 18, weight: .black, design: .rounded))
              .foregroundStyle(Color.black)
          }
          .padding(.horizontal, 8)
          .padding(.vertical, 3)
        }
        VStack(alignment: .leading, spacing: 0) {
          Text(snapshot.labels.thisWeek)
            .font(.system(size: 15, weight: .heavy, design: .rounded))
            .foregroundStyle(palette.ink)
          Text("\(snapshot.cardsToday(on: entry.date)) \(snapshot.labels.cardsToday)")
            .font(.system(size: 11, weight: .semibold, design: .rounded))
            .foregroundStyle(palette.muted)
        }
        Spacer(minLength: 0)
        Image("Nana").resizable().scaledToFit().frame(height: 44)
      }
      HStack(alignment: .bottom, spacing: 7) {
        ForEach(Array(week.enumerated()), id: \.offset) { _, day in
          VStack(spacing: 4) {
            GeometryReader { geometry in
              VStack {
                Spacer(minLength: 0)
                NeoCard(
                  palette: palette, fill: day.isToday ? palette.accent : palette.card,
                  radius: 5
                ) {
                  Color.clear
                    .frame(height: max(6, geometry.size.height * CGFloat(day.cards) / CGFloat(most)))
                }
              }
            }
            Text(day.label)
              .font(.system(size: 10, weight: .heavy, design: .rounded))
              .foregroundStyle(day.isToday ? palette.ink : palette.muted)
          }
        }
      }
      if family == .systemLarge, let grammar = snapshot.grammar {
        NeoCard(palette: palette) {
          VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
              Pill(text: grammar.book, palette: palette, fill: palette.accent, foreground: palette.onAccent)
              Text(snapshot.labels.grammarOfDay)
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundStyle(palette.muted)
            }
            Text(grammar.title)
              .font(.system(size: 26, weight: .black))
              .foregroundStyle(palette.ink)
            Text(grammar.usage)
              .font(.system(size: 12, weight: .semibold, design: .rounded))
              .foregroundStyle(palette.muted)
              .lineLimit(2)
            Text(grammar.example)
              .font(.system(size: 14, weight: .bold))
              .foregroundStyle(palette.ink)
            Text(grammar.translation)
              .font(.system(size: 11, weight: .medium, design: .rounded))
              .foregroundStyle(palette.muted)
          }
          .padding(10)
          .frame(maxWidth: .infinity, alignment: .leading)
        }
      }
    }
  }
}

struct WeekWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: "JapananaWeek", provider: SnapshotProvider()) { entry in
      WeekView(entry: entry)
    }
    .configurationDisplayName("This week")
    .description("Cards per day, your streak and the grammar of the day.")
    .supportedFamilies([.systemMedium, .systemLarge])
  }
}

// MARK: - Bundle

@main
struct JapananaWidgets: WidgetBundle {
  var body: some Widget {
    StreakWidget()
    GrammarWidget()
    WeekWidget()
  }
}
