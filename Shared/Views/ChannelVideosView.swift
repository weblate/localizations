import Siesta
import SwiftUI

struct ChannelVideosView: View {
    var channel: Channel?

    @State private var presentingShareSheet = false
    @State private var shareURL: URL?
    @State private var subscriptionToggleButtonDisabled = false

    @StateObject private var store = Store<Channel>()

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.navigationStyle) private var navigationStyle

    #if os(iOS)
        @Environment(\.horizontalSizeClass) private var horizontalSizeClass
        @EnvironmentObject<PlayerModel> private var player
    #endif

    @EnvironmentObject<AccountsModel> private var accounts
    @EnvironmentObject<NavigationModel> private var navigation
    @EnvironmentObject<RecentsModel> private var recents
    @EnvironmentObject<SubscriptionsModel> private var subscriptions

    @Namespace private var focusNamespace

    var presentedChannel: Channel? {
        channel ?? recents.presentedChannel
    }

    var videos: [ContentItem] {
        ContentItem.array(of: store.item?.videos ?? [])
    }

    var body: some View {
        if navigationStyle == .tab {
            NavigationView {
                BrowserPlayerControls {
                    content
                }
            }
        } else {
            BrowserPlayerControls {
                content
            }
        }
    }

    var content: some View {
        let content = VStack {
            #if os(tvOS)
                HStack {
                    Text(navigationTitle)
                        .font(.title2)
                        .frame(alignment: .leading)

                    Spacer()

                    if let channel = presentedChannel {
                        FavoriteButton(item: FavoriteItem(section: .channel(channel.id, channel.name)))
                            .labelStyle(.iconOnly)
                    }

                    if let subscribers = store.item?.subscriptionsString {
                        Text("**\(subscribers)** subscribers")
                            .foregroundColor(.secondary)
                    }

                    subscriptionToggleButton
                }
                .frame(maxWidth: .infinity)
            #endif

            VerticalCells(items: videos)
                .environment(\.inChannelView, true)
            #if os(tvOS)
                .prefersDefaultFocus(in: focusNamespace)
            #endif
        }

        #if !os(tvOS)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                if navigationStyle == .tab {
                    Button {
                        withAnimation(Constants.overlayAnimation) {
                            navigation.presentingChannel = false
                        }
                    } label: {
                        Label("Close", systemImage: "xmark")
                    }
                }
            }

            ToolbarItem {
                HStack {
                    HStack(spacing: 3) {
                        Text("\(store.item?.subscriptionsString ?? "")")
                            .fontWeight(.bold)

                        let subscribers = Text(" subscribers")
                            .allowsTightening(true)
                            .foregroundColor(.secondary)
                            .opacity(store.item?.subscriptionsString != nil ? 1 : 0)

                        #if os(iOS)
                            if navigationStyle == .sidebar {
                                subscribers
                            }
                        #else
                            subscribers
                        #endif
                    }

                    ShareButton(contentItem: contentItem)

                    subscriptionToggleButton

                    if let channel = presentedChannel {
                        FavoriteButton(item: FavoriteItem(section: .channel(channel.id, channel.name)))
                    }
                }
            }
        }
        #endif
        .onAppear {
            if navigationStyle == .tab {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    resource?.loadIfNeeded()
                }
            } else {
                resource?.loadIfNeeded()
            }
        }
        #if !os(tvOS)
        .navigationTitle(navigationTitle)
        #endif

        return Group {
            if #available(macOS 12.0, *) {
                content
                #if os(tvOS)
                .background(Color.background(scheme: colorScheme))
                #endif
                #if !os(iOS)
                .focusScope(focusNamespace)
                #endif
            } else {
                content
            }
        }
    }

    private var resource: Resource? {
        guard let channel = presentedChannel else {
            return nil
        }

        let resource = accounts.api.channel(channel.id)
        resource.addObserver(store)

        return resource
    }

    @ViewBuilder private var subscriptionToggleButton: some View {
        if let channel = presentedChannel {
            Group {
                if accounts.app.supportsSubscriptions && accounts.signedIn {
                    if subscriptions.isSubscribing(channel.id) {
                        Button {
                            subscriptionToggleButtonDisabled = true

                            subscriptions.unsubscribe(channel.id) {
                                subscriptionToggleButtonDisabled = false
                            }
                        } label: {
                            Label("Unsubscribe", systemImage: "star.circle")
                            #if os(iOS)
                                .labelStyle(.automatic)
                            #else
                                .labelStyle(.titleOnly)
                            #endif
                        }
                    } else {
                        Button {
                            subscriptionToggleButtonDisabled = true

                            subscriptions.subscribe(channel.id) {
                                subscriptionToggleButtonDisabled = false
                                navigation.sidebarSectionChanged.toggle()
                            }
                        } label: {
                            Label("Subscribe", systemImage: "circle")
                            #if os(iOS)
                                .labelStyle(.automatic)
                            #else
                                .labelStyle(.titleOnly)
                            #endif
                        }
                    }
                }
            }
            .disabled(subscriptionToggleButtonDisabled)
        }
    }

    private var contentItem: ContentItem {
        ContentItem(channel: presentedChannel)
    }

    private var navigationTitle: String {
        presentedChannel?.name ?? store.item?.name ?? "No channel"
    }
}

struct ChannelVideosView_Previews: PreviewProvider {
    static var previews: some View {
        ChannelVideosView(channel: Video.fixture.channel)
            .injectFixtureEnvironmentObjects()
    }
}
