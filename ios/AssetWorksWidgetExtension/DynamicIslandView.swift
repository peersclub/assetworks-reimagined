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
    // App Group identifier for data sharing
    let appGroupId = "group.com.assetworks.widgets"
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), widgetCount: 0, latestWidget: nil, savedWidgets: 0, createdToday: 0)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = loadWidgetData() ?? SimpleEntry(date: Date(), widgetCount: 5, latestWidget: "My Cool Widget", savedWidgets: 3, createdToday: 1)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        // Load current data from shared container
        let currentEntry = loadWidgetData() ?? SimpleEntry(date: Date(), widgetCount: 0, latestWidget: nil, savedWidgets: 0, createdToday: 0)
        entries.append(currentEntry)
        
        // Refresh every 30 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        let timeline = Timeline(entries: entries, policy: .after(nextUpdate))
        completion(timeline)
    }
    
    private func loadWidgetData() -> SimpleEntry? {
        guard let userDefaults = UserDefaults(suiteName: appGroupId) else { return nil }
        
        let totalWidgets = userDefaults.integer(forKey: "totalWidgets")
        let savedWidgets = userDefaults.integer(forKey: "savedWidgets")
        let createdToday = userDefaults.integer(forKey: "createdToday")
        let latestWidget = userDefaults.string(forKey: "latestWidget")
        
        return SimpleEntry(
            date: Date(),
            widgetCount: totalWidgets,
            latestWidget: latestWidget,
            savedWidgets: savedWidgets,
            createdToday: createdToday
        )
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let widgetCount: Int
    let latestWidget: String?
    let savedWidgets: Int
    let createdToday: Int
}

struct WidgetEntryView: View {
    @Environment(\.widgetFamily) var widgetFamily
    var entry: WidgetProvider.Entry
    
    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Small Widget View
struct SmallWidgetView: View {
    let entry: WidgetProvider.Entry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.yellow)
                    .font(.title3)
                Spacer()
            }
            
            Text("\(entry.widgetCount)")
                .font(.largeTitle)
                .bold()
            
            Text("Total Widgets")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            if entry.createdToday > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "plus.circle.fill")
                        .font(.caption2)
                        .foregroundColor(.green)
                    Text("\(entry.createdToday) today")
                        .font(.caption2)
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        .widgetURL(URL(string: "assetworks://dashboard"))
    }
}

// MARK: - Medium Widget View
struct MediumWidgetView: View {
    let entry: WidgetProvider.Entry
    
    var body: some View {
        HStack(spacing: 16) {
            // Left side - Main stats
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundColor(.yellow)
                    Text("AssetWorks")
                        .font(.headline)
                }
                
                Spacer()
                
                Text("\(entry.widgetCount)")
                    .font(.largeTitle)
                    .bold()
                Text("Total Widgets")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Right side - Additional stats
            VStack(alignment: .leading, spacing: 12) {
                StatRow(icon: "bookmark.fill", value: "\(entry.savedWidgets)", label: "Saved")
                StatRow(icon: "plus.circle.fill", value: "\(entry.createdToday)", label: "Today")
                
                if let latest = entry.latestWidget {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Latest")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(latest)
                            .font(.caption)
                            .lineLimit(1)
                    }
                }
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
        .widgetURL(URL(string: "assetworks://dashboard"))
    }
}

// MARK: - Large Widget View
struct LargeWidgetView: View {
    let entry: WidgetProvider.Entry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.yellow)
                    .font(.title2)
                Text("AssetWorks")
                    .font(.title2)
                    .bold()
                Spacer()
                Text(entry.date, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Main stats
            HStack(spacing: 20) {
                StatCard(
                    title: "Total",
                    value: "\(entry.widgetCount)",
                    icon: "square.grid.2x2.fill",
                    color: .blue
                )
                
                StatCard(
                    title: "Saved",
                    value: "\(entry.savedWidgets)",
                    icon: "bookmark.fill",
                    color: .orange
                )
                
                StatCard(
                    title: "Today",
                    value: "\(entry.createdToday)",
                    icon: "plus.circle.fill",
                    color: .green
                )
            }
            
            Divider()
            
            // Latest widget
            if let latest = entry.latestWidget {
                VStack(alignment: .leading, spacing: 4) {
                    Label("Latest Widget", systemImage: "clock.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(latest)
                        .font(.headline)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            // Quick actions
            HStack(spacing: 12) {
                Link(destination: URL(string: "assetworks://create")!) {
                    Label("Create", systemImage: "plus")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)
                }
                
                Link(destination: URL(string: "assetworks://dashboard")!) {
                    Label("Dashboard", systemImage: "square.grid.2x2")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.purple.opacity(0.2))
                        .cornerRadius(8)
                }
            }
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

// MARK: - Helper Views
struct StatRow: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.blue)
            VStack(alignment: .leading, spacing: 0) {
                Text(value)
                    .font(.headline)
                Text(label)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            Text(value)
                .font(.title2)
                .bold()
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}