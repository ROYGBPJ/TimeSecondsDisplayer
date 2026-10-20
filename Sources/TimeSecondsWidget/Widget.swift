import WidgetKit
import SwiftUI

struct TimeSecondsProvider: TimelineProvider {
    func placeholder(in context: Context) -> TimeSecondsEntry {
        TimeSecondsEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (TimeSecondsEntry) -> Void) {
        let entry = TimeSecondsEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TimeSecondsEntry>) -> Void) {
        // Force updates every minute for the Home Screen clock
        let entries = (0..<5).map { i in
            TimeSecondsEntry(date: Calendar.current.date(byAdding: .minute, value: i, to: Date())!)
        }
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct TimeSecondsEntry: TimelineEntry {
    let date: Date
}

struct TimeSecondsWidgetEntryView : View {
    var entry: TimeSecondsEntry

    @Environment(\.widgetFamily) var family

    var body: some View {
        ZStack {
            // High-contrast futuristic background
            Color(hex: "0A0A0C")
                .ignoresSafeArea()

            if family == .accessoryCircular {
                // Lock Screen Circular: Minimalist neon ring and time
                ZStack {
                    Circle()
                        .stroke(Color.cyan.opacity(0.3), lineWidth: 2)
                    Text(formatSeconds(entry.date))
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(.cyan)
                }
                .frame(width: 44, height: 44)
            } else if family == .accessoryRectangular {
                // Lock Screen Rectangular: Elegant linear display
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.cyan)
                    Text("NOW: \(formatFullTime(entry.date))")
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 8)
            } else {
                // Home Screen Widget: High-end Digital Display
                VStack {
                    Text("TimeSeconds")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(.gray)
                        .kerning(2)

                    Text(formatFullTime(entry.date))
                        .font(.system(size: 32, weight: .thin, design: .monospaced))
                        .foregroundColor(.white)
                        .shadow(color: .cyan, radius: 10)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    func formatSeconds(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "ss"
        return formatter.string(from: date)
    }

    func formatFullTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }
}

@main
struct TimeSecondsWidget: Widget {
    let kind: String = "TimeSecondsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TimeSecondsProvider()) { entry in
            TimeSecondsWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("TimeSeconds Displayer")
        .description("Luxurious futuristic time tracking.")
        .supportedFamilies([.systemSmall, .accessoryCircular, .accessoryRectangular])
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6: // RGB (24-bit)
            (r, g, b) = ( (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF )
        case 8: // RGB(A) (32-bit)
            (r, g, b) = ( (int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, 0 )
        default:
            (r, g, b) = (128, 128, 128)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1.0
        )
    }
}
