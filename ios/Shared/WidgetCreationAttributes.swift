import Foundation
import ActivityKit

// MARK: - Activity Attributes (Shared between App and Widget Extension)
public struct WidgetCreationAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var status: String
        public var progress: Double
        public var icon: String
        public var color: String
        
        public init(status: String, progress: Double, icon: String, color: String) {
            self.status = status
            self.progress = progress
            self.icon = icon
            self.color = color
        }
    }
    
    public var widgetTitle: String
    public var username: String
    
    public init(widgetTitle: String, username: String) {
        self.widgetTitle = widgetTitle
        self.username = username
    }
}

// MARK: - Portfolio Live Activity Attributes
public struct PortfolioActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var totalValue: Double
        public var dayChange: Double
        public var percentChange: Double
        public var isPositive: Bool
        public var lastUpdate: Date
        
        public init(totalValue: Double, dayChange: Double, percentChange: Double, isPositive: Bool, lastUpdate: Date) {
            self.totalValue = totalValue
            self.dayChange = dayChange
            self.percentChange = percentChange
            self.isPositive = isPositive
            self.lastUpdate = lastUpdate
        }
    }
    
    public var portfolioName: String
    public var username: String
    
    public init(portfolioName: String, username: String) {
        self.portfolioName = portfolioName
        self.username = username
    }
}

// MARK: - Analysis Live Activity Attributes  
public struct AnalysisActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var status: String
        public var progress: Double
        public var filesProcessed: Int
        public var totalFiles: Int
        
        public init(status: String, progress: Double, filesProcessed: Int, totalFiles: Int) {
            self.status = status
            self.progress = progress
            self.filesProcessed = filesProcessed
            self.totalFiles = totalFiles
        }
    }
    
    public var analysisType: String
    public var username: String
    
    public init(analysisType: String, username: String) {
        self.analysisType = analysisType
        self.username = username
    }
}