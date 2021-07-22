import Defaults
import Foundation

struct Profile {
    var defaultStreamResolution: DefaultStreamResolution = .hd1080p

    var skippedSegmentsCategories = [String]() // SponsorBlockSegmentsProvider.categories

    // var sid = "B3_WzklziGu8JKefihLrCsTNavdj73KMiPUBfN5HW2M="
    var sid = "RpoS7YPPK2-QS81jJF9z4KSQAjmzsOnMpn84c73-GQ8="

    var cellsColumns = 3
}

enum DefaultStreamResolution: String {
    case hd720pFirstThenBest, hd1080p, hd720p, sd480p, sd360p, sd240p, sd144p

    var value: Stream.Resolution {
        switch self {
        case .hd720pFirstThenBest:
            return .hd720p
        default:
            return Stream.Resolution(rawValue: rawValue)!
        }
    }
}
