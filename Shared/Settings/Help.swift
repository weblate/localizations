import Foundation
import SwiftUI

struct Help: View {
    static let wikiURL = URL(string: "https://github.com/yattee/yattee/wiki")!
    static let matrixURL = URL(string: "https://tinyurl.com/matrix-yattee")!
    static let discordURL = URL(string: "https://yattee.stream/discord")!
    static let issuesURL = URL(string: "https://github.com/yattee/yattee/issues")!
    static let milestonesURL = URL(string: "https://github.com/yattee/yattee/milestones")!
    static let donationsURL = URL(string: "https://github.com/yattee/yattee/wiki/Donations")!
    static let contributingURL = URL(string: "https://github.com/yattee/yattee/wiki/Contributing")!

    @Environment(\.openURL) private var openURL

    var body: some View {
        Group {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    Section {
                        header(NSLocalizedString("I am lost", tableName: "Localizable", bundle: .main, comment: ""))

                        Text("You can find information about using Yattee in the Wiki pages.")
                            .padding(.bottom, 8)

                        helpItemLink(NSLocalizedString("Wiki", tableName: "Localizable", bundle: .main, comment: ""), url: Self.wikiURL, systemImage: "questionmark.circle")
                            .padding(.bottom, 8)
                    }

                    Spacer()

                    Section {
                        header(NSLocalizedString("I want to ask a question", tableName: "Localizable", bundle: .main, comment: ""))

                        Text("Discussions take place in Discord and Matrix. It's a good spot for general questions.")
                            .padding(.bottom, 8)

                        helpItemLink(NSLocalizedString("Discord Server", tableName: "Localizable", bundle: .main, comment: ""), url: Self.discordURL, systemImage: "message")
                            .padding(.bottom, 8)
                        helpItemLink(NSLocalizedString("Matrix Channel", tableName: "Localizable", bundle: .main, comment: ""), url: Self.matrixURL, systemImage: "message")
                            .padding(.bottom, 8)
                    }

                    Spacer()

                    Section {
                        header(NSLocalizedString("I found a bug /", tableName: "Localizable", bundle: .main, comment: ""))
                        header(NSLocalizedString("I have a feature request", tableName: "Localizable", bundle: .main, comment: ""))

                        Text("Bugs and great feature ideas can be sent to the GitHub issues tracker. ")
                        Text("If you are reporting a bug, include all relevant details (especially: app\u{00a0}version, used device and system version, steps to reproduce).")
                        Text("If you are interested what's coming in future updates, you can track project Milestones.")
                            .padding(.bottom, 8)

                        VStack(alignment: .leading, spacing: 8) {
                            helpItemLink(NSLocalizedString("Issues Tracker", tableName: "Localizable", bundle: .main, comment: ""), url: Self.issuesURL, systemImage: "ladybug")
                            helpItemLink(NSLocalizedString("Milestones", tableName: "Localizable", bundle: .main, comment: ""), url: Self.milestonesURL, systemImage: "list.star")
                        }
                        .padding(.bottom, 8)
                    }

                    Spacer()

                    Section {
                        header(NSLocalizedString("I like this app!", tableName: "Localizable", bundle: .main, comment: ""))

                        Text("That's nice to hear. It is fun to deliver apps other people want to use. You can consider donating to the project or help by contributing to new features development.")
                            .padding(.bottom, 8)

                        VStack(alignment: .leading, spacing: 8) {
                            helpItemLink(NSLocalizedString("Donations", tableName: "Localizable", bundle: .main, comment: ""), url: Self.donationsURL, systemImage: "dollarsign.circle")
                            helpItemLink(NSLocalizedString("Contributing", tableName: "Localizable", bundle: .main, comment: ""), url: Self.contributingURL, systemImage: "hammer")
                        }
                        .padding(.bottom, 8)
                    }
                }
                #if os(iOS)
                .padding(.horizontal)
                #endif
            }
        }
        #if os(tvOS)
        .frame(maxWidth: 1000)
        #else
        .frame(maxWidth: .infinity, alignment: .leading)
        #endif
        .navigationTitle("Help")
    }

    func header(_ text: String) -> some View {
        Text(text)
            .fontWeight(.bold)
            .font(.title3)
            .padding(.bottom, 6)
    }

    func helpItemLink(_ label: String, url: URL, systemImage: String) -> some View {
        Group {
            #if os(tvOS)
                VStack {
                    Button {} label: {
                        HStack(spacing: 8) {
                            Image(systemName: systemImage)
                            Text(label)
                        }
                        .font(.system(size: 25).bold())
                    }

                    Text(url.absoluteString)
                }
                .frame(maxWidth: .infinity)
            #else
                Button {
                    openURL(url)
                } label: {
                    Label(label, systemImage: systemImage)
                }
            #endif
        }
    }
}

struct Help_Previews: PreviewProvider {
    static var previews: some View {
        Help()
    }
}
