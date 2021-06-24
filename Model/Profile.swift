import Foundation

final class Profile: ObservableObject {
    let defaultStreamResolution: DefaultStreamResolution = .hd720pFirstThenBest

    let skippedSegmentsCategories = [String]() // SponsorBlockSegmentsProvider.categories

    // let sid = "B3_WzklziGu8JKefihLrCsTNavdj73KMiPUBfN5HW2M="
    let sid = "RpoS7YPPK2-QS81jJF9z4KSQAjmzsOnMpn84c73-GQ8="

    let listing = VideoListing.cells

    let cellsColumns = 3
}

enum VideoListing: String {
    case list, cells
}

enum DefaultStreamResolution: String {
    case hd720pFirstThenBest, hd1080p, hd720p, sd480p, sd360p, sd240p, sd144p

    var value: StreamResolution {
        switch self {
        case .hd720pFirstThenBest:
            return .hd720p
        default:
            return StreamResolution(rawValue: rawValue)!
        }
    }
}