import Defaults
import Foundation

enum TrendingCategory: String, CaseIterable, Identifiable, Defaults.Serializable {
    case `default`, music, gaming, movies

    var id: RawValue {
        rawValue
    }

    var title: RawValue {
        switch self {
        case .default:
            return NSLocalizedString("All", tableName: "Localizable", bundle: .main, comment: "Trending category, section containing all kinds of videos")
        case .music:
            return NSLocalizedString("Music", tableName: "Localizable", bundle: .main, comment: "")
        case .gaming:
            return NSLocalizedString("Gaming", tableName: "Localizable", bundle: .main, comment: "")
        case .movies:
            return NSLocalizedString("Movies", tableName: "Localizable", bundle: .main, comment: "")
        }
    }

    var name: String {
        id == "default" ? NSLocalizedString("Trending", tableName: "Localizable", bundle: .main, comment: "") : title
    }

    var controlLabel: String {
        id == "default" ? NSLocalizedString("All", tableName: "Localizable", bundle: .main, comment: "") : title
    }
}
