import Alamofire
import Defaults
import Foundation
import Logging
import SwiftyJSON

final class SponsorBlockAPI: ObservableObject {
    static let categories = ["sponsor", "selfpromo", "intro", "outro", "interaction", "music_offtopic"]

    let logger = Logger(label: "stream.yattee.app.sb")

    @Published var videoID: String?
    @Published var segments = [Segment]()

    static func categoryDescription(_ name: String) -> String? {
        guard Self.categories.contains(name) else {
            return nil
        }

        switch name {
        case "sponsor":
            return NSLocalizedString("Sponsor", tableName: "Localizable", bundle: .main, comment: "SponsorBlock category name")
        case "selfpromo":
            return NSLocalizedString("Self-promotion", tableName: "Localizable", bundle: .main, comment: "SponsorBlock category name")
        case "intro":
            return NSLocalizedString("Intro", tableName: "Localizable", bundle: .main, comment: "SponsorBlock category name")
        case "outro":
            return NSLocalizedString("Outro", tableName: "Localizable", bundle: .main, comment: "SponsorBlock category name")
        case "interaction":
            return NSLocalizedString("Interaction", tableName: "Localizable", bundle: .main, comment: "SponsorBlock category name")
        case "music_offtopic":
            return NSLocalizedString("Offtopic in Music Videos", tableName: "Localizable", bundle: .main, comment: "SponsorBlock category name")
        default:
            return name.capitalized
        }
    }

    static func categoryDetails(_ name: String) -> String? {
        guard Self.categories.contains(name) else {
            return nil
        }

        switch name {
        case "sponsor":
            return NSLocalizedString("Part of a video promoting a product or service not directly related to the creator. " +
                "The creator will receive payment or compensation in the form of money or free products.", tableName: "Localizable", bundle: .main, comment: "")

        case "selfpromo":
            return NSLocalizedString("Promoting a product or service that is directly related to the creator themselves. " +
                "This usually includes merchandise or promotion of monetized platforms.", tableName: "Localizable", bundle: .main, comment: "")

        case "intro":
            return NSLocalizedString("Segments typically found at the start of a video that include an animation, " +
                "still frame or clip which are also seen in other videos by the same creator.", tableName: "Localizable", bundle: .main, comment: "")

        case "outro":
            return NSLocalizedString("Typically near or at the end of the video when the credits pop up and/or endcards are shown.", tableName: "Localizable", bundle: .main, comment: "")

        case "interaction":
            return NSLocalizedString("Explicit reminders to like, subscribe or interact with them on any paid or free platform(s) (e.g. click on a video).", tableName: "Localizable", bundle: .main, comment: "")

        case "music_offtopic":
            return NSLocalizedString("For videos which feature music as the primary content.", tableName: "Localizable", bundle: .main, comment: "")

        default:
            return nil
        }
    }

    func loadSegments(videoID: String, categories: Set<String>, completionHandler: @escaping () -> Void = {}) {
        guard !skipSegmentsURL.isNil, self.videoID != videoID else {
            completionHandler()
            return
        }

        self.videoID = videoID

        DispatchQueue.main.async { [weak self] in
            self?.requestSegments(categories: categories, completionHandler: completionHandler)
        }
    }

    private func requestSegments(categories: Set<String>, completionHandler: @escaping () -> Void = {}) {
        guard let url = skipSegmentsURL, !categories.isEmpty else {
            return
        }

        AF.request(url, parameters: parameters(categories: categories)).responseDecodable(of: JSON.self) { [weak self] response in
            guard let self = self else {
                return
            }

            switch response.result {
            case let .success(value):
                self.segments = JSON(value).arrayValue.map(SponsorBlockSegment.init).sorted { $0.end < $1.end }

                self.logger.info("loaded \(self.segments.count) SponsorBlock segments")
                self.segments.forEach {
                    self.logger.info("\($0.start) -> \($0.end)")
                }
            case let .failure(error):
                self.segments = []

                self.logger.error("failed to load SponsorBlock segments: \(error.localizedDescription)")
            }

            completionHandler()
        }
    }

    private var skipSegmentsURL: String? {
        let url = Defaults[.sponsorBlockInstance]
        return url.isEmpty ? nil : "\(url)/api/skipSegments"
    }

    private func parameters(categories: Set<String>) -> [String: String] {
        [
            "videoID": videoID!,
            "categories": JSON(Array(categories)).rawString(String.Encoding.utf8)!
        ]
    }
}
