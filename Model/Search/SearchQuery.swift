import Defaults
import Foundation

final class SearchQuery: ObservableObject {
    enum Date: String, CaseIterable, Identifiable {
        case any, hour, today, week, month, year

        var id: SearchQuery.Date.RawValue {
            rawValue
        }

        var name: String {
            switch self {
            case .any:
                return NSLocalizedString("Any", tableName: "Localizable", bundle: .main, comment: "Video date filter in search")
            case .hour:
                return NSLocalizedString("Hour", tableName: "Localizable", bundle: .main, comment: "Video date filter in search")
            case .today:
                return NSLocalizedString("Today", tableName: "Localizable", bundle: .main, comment: "Video date filter in search")
            case .week:
                return NSLocalizedString("Week", tableName: "Localizable", bundle: .main, comment: "Video date filter in search")
            case .month:
                return NSLocalizedString("Month", tableName: "Localizable", bundle: .main, comment: "Video date filter in search")
            case .year:
                return NSLocalizedString("Year", tableName: "Localizable", bundle: .main, comment: "Video date filter in search")
            }
        }
    }

    enum Duration: String, CaseIterable, Identifiable {
        case any, short, long

        var id: SearchQuery.Duration.RawValue {
            rawValue
        }

        var name: String {
            switch self {
            case .any:
                return NSLocalizedString("Any", tableName: "Localizable", bundle: .main, comment: "Video duration filter in search")
            case .short:
                return NSLocalizedString("Short", tableName: "Localizable", bundle: .main, comment: "Video duration filter in search")
            case .long:
                return NSLocalizedString("Long", tableName: "Localizable", bundle: .main, comment: "Video duration filter in search")
            }
        }
    }

    enum SortOrder: String, CaseIterable, Identifiable {
        case relevance, rating, uploadDate, viewCount

        var id: SearchQuery.SortOrder.RawValue {
            rawValue
        }

        var name: String {
            switch self {
            case .relevance:
                return NSLocalizedString("Relevance", tableName: "Localizable", bundle: .main, comment: "Video sort order in search")
            case .rating:
                return NSLocalizedString("Rating", tableName: "Localizable", bundle: .main, comment: "Video sort order in search")
            case .uploadDate:
                return NSLocalizedString("Date", tableName: "Localizable", bundle: .main, comment: "Video sort order in search")
            case .viewCount:
                return NSLocalizedString("Views", tableName: "Localizable", bundle: .main, comment: "Video sort order in search")
            }
        }

        var parameter: String {
            switch self {
            case .uploadDate:
                return "upload_date"
            case .viewCount:
                return "view_count"
            default:
                return rawValue
            }
        }
    }

    @Published var query: String
    @Published var sortBy: SearchQuery.SortOrder = .relevance
    @Published var date: SearchQuery.Date? = .month
    @Published var duration: SearchQuery.Duration?

    init(query: String = "", sortBy: SearchQuery.SortOrder = .relevance, date: SearchQuery.Date? = nil, duration: SearchQuery.Duration? = nil) {
        self.query = query
        self.sortBy = sortBy
        self.date = date
        self.duration = duration
    }

    var isEmpty: Bool {
        query.isEmpty
    }
}
