import WidgetKit
import SwiftUI
import ActivityKit

// MARK: - Dynamic Island Views
@available(iOS 16.1, *)
struct DynamicIslandLiveActivityView: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WidgetCreationAttributes.self) { context in
            // Lock Screen / Banner UI
            LockScreenView(context: context)
                .padding()
                .background(Color("WidgetBackground"))
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded Region
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: context.state.icon)
                        .foregroundColor(Color(context.state.color))
                        .font(.title2)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(Int(context.state.progress * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                DynamicIslandExpandedRegion(.center) {
                    Text(context.attributes.widgetTitle)
                        .font(.headline)
                        .lineLimit(1)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(context.state.status)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        
                        ProgressView(value: context.state.progress)
                            .progressViewStyle(.linear)
                            .tint(Color(context.state.color))
                    }
                }
            } compactLeading: {
                // Compact Leading
                Image(systemName: context.state.icon)
                    .foregroundColor(Color(context.state.color))
                    .font(.caption)
            } compactTrailing: {
                // Compact Trailing
                if context.state.progress > 0 && context.state.progress < 1 {
                    CircularProgressView(progress: context.state.progress)
                        .frame(width: 20, height: 20)
                } else {
                    Image(systemName: "sparkles")
                        .foregroundColor(.yellow)
                        .font(.caption)
                }
            } minimal: {
                // Minimal View
                Image(systemName: context.state.icon)
                    .foregroundColor(Color(context.state.color))
                    .font(.caption2)
            }
            .widgetURL(URL(string: "assetworks://widget/\(context.attributes.widgetTitle)"))
            .keylineTint(Color(context.state.color))
        }
    }
}

// MARK: - Lock Screen View
@available(iOS 16.1, *)
struct LockScreenView: View {
    let context: ActivityViewContext<WidgetCreationAttributes>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: context.state.icon)
                    .foregroundColor(Color(context.state.color))
                    .font(.title2)
                
                VStack(alignment: .leading) {
                    Text(context.attributes.widgetTitle)
                        .font(.headline)
                    Text("by @\(context.attributes.username)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text("\(Int(context.state.progress * 100))%")
                    .font(.title3)
                    .monospacedDigit()
                    .foregroundColor(Color(context.state.color))
            }
            
            Text(context.state.status)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            ProgressView(value: context.state.progress)
                .progressViewStyle(.linear)
                .tint(Color(context.state.color))
        }
        .padding()
    }
}

// MARK: - Circular Progress View
@available(iOS 16.0, *)
struct CircularProgressView: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 2)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 2, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: progress)
        }
    }
}

// MARK: - Widget Bundle
@main
@available(iOS 16.1, *)
struct AssetWorksWidgetBundle: WidgetBundle {
    var body: some Widget {
        DynamicIslandLiveActivityView()
        AssetWorksHomeWidget()
    }
}

// MARK: - Home Screen Widget
@available(iOS 16.0, *)
struct AssetWorksHomeWidget: Widget {
    let kind: String = "AssetWorksWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WidgetProvider()) { entry in
            WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("AssetWorks")
        .description("Your widgets at a glance")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Widget Provider
struct WidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), widgetCount: 0, latestWidget: nil)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), widgetCount: 5, latestWidget: "My Cool Widget")
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        // Generate timeline entries
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, widgetCount: 5 + hourOffset, latestWidget: "Widget #\(hourOffset)")
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let widgetCount: Int
    let latestWidget: String?
}

struct WidgetEntryView: View {
    var entry: WidgetProvider.Entry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.yellow)
                Text("AssetWorks")
                    .font(.headline)
            }
            
            Text("\(entry.widgetCount) Widgets")
                .font(.largeTitle)
                .bold()
            
            if let latest = entry.latestWidget {
                Text("Latest: \(latest)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}