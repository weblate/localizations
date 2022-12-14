import AVFAudio
import Defaults
import MediaPlayer
import SDWebImage
import SDWebImagePINPlugin
import SDWebImageWebPCoder
import Siesta
import SwiftUI

struct ContentView: View {
    @EnvironmentObject<AccountsModel> private var accounts
    @EnvironmentObject<CommentsModel> private var comments
    @EnvironmentObject<InstancesModel> private var instances
    @EnvironmentObject<NavigationModel> private var navigation
    @EnvironmentObject<PlayerModel> private var player
    @EnvironmentObject<PlaylistsModel> private var playlists
    @EnvironmentObject<RecentsModel> private var recents
    @EnvironmentObject<SearchModel> private var search
    @EnvironmentObject<SettingsModel> private var settings
    @EnvironmentObject<SubscriptionsModel> private var subscriptions
    @EnvironmentObject<ThumbnailsModel> private var thumbnailsModel

    @EnvironmentObject<MenuModel> private var menu

    #if os(iOS)
        @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif

    @State private var playerInitialized = false

    var playerControls: PlayerControlsModel { .shared }

    let persistenceController = PersistenceController.shared

    var body: some View {
        Group {
            #if os(iOS)
                if horizontalSizeClass == .compact {
                    AppTabNavigation()
                } else {
                    AppSidebarNavigation()
                }
            #elseif os(macOS)
                AppSidebarNavigation()
            #elseif os(tvOS)
                TVNavigationView()
                    .environmentObject(settings)
            #endif
        }
        .onChange(of: accounts.current) { _ in
            subscriptions.load(force: true)
            playlists.load(force: true)
        }
        .onChange(of: accounts.signedIn) { _ in
            subscriptions.load(force: true)
            playlists.load(force: true)
        }
        .environmentObject(accounts)
        .environmentObject(comments)
        .environmentObject(instances)
        .environmentObject(navigation)
        .environmentObject(player)
        .environmentObject(playlists)
        .environmentObject(recents)
        .environmentObject(search)
        .environmentObject(subscriptions)
        .environmentObject(thumbnailsModel)

        #if os(iOS)
            .overlay(videoPlayer)
            .sheet(isPresented: $navigation.presentingShareSheet) {
                if let shareURL = navigation.shareURL {
                    ShareSheet(activityItems: [shareURL])
                }
            }
        #endif

            // iOS 14 has problem with multiple sheets in one view
            // but it's ok when it's in background
            .background(
                EmptyView().sheet(isPresented: $navigation.presentingWelcomeScreen) {
                    WelcomeScreen()
                        .environmentObject(accounts)
                        .environmentObject(navigation)
                }
            )
        #if !os(tvOS)
            .onOpenURL {
                OpenURLHandler(
                    accounts: accounts,
                    navigation: navigation,
                    recents: recents,
                    player: player,
                    search: search,
                    navigationStyle: navigationStyle
                ).handle($0)
            }
            .background(
                EmptyView().sheet(isPresented: $navigation.presentingAddToPlaylist) {
                    AddToPlaylistView(video: navigation.videoToAddToPlaylist)
                        .environmentObject(playlists)
                }
            )
            .background(
                EmptyView().sheet(isPresented: $navigation.presentingPlaylistForm) {
                    PlaylistFormView(playlist: $navigation.editedPlaylist)
                        .environmentObject(accounts)
                        .environmentObject(playlists)
                }
            )
            .background(
                EmptyView().sheet(isPresented: $navigation.presentingSettings) {
                    SettingsView()
                        .environmentObject(accounts)
                        .environmentObject(instances)
                        .environmentObject(settings)
                        .environmentObject(navigation)
                        .environmentObject(player)
                }
            )
        #endif
            .background(playerViewInitialize)
            .alert(isPresented: $navigation.presentingAlert) { navigation.alert }
    }

    var navigationStyle: NavigationStyle {
        #if os(iOS)
            return horizontalSizeClass == .compact ? .tab : .sidebar
        #elseif os(tvOS)
            return .tab
        #else
            return .sidebar
        #endif
    }

    @ViewBuilder var videoPlayer: some View {
        if player.presentingPlayer {
            playerView
                .transition(.asymmetric(insertion: .identity, removal: .move(edge: .bottom)))
                .zIndex(3)
        } else if player.activeBackend == .appleAVPlayer {
            #if os(iOS)
                playerView.offset(y: UIScreen.main.bounds.height)
            #endif
        }
    }

    var playerView: some View {
        VideoPlayerView()
            .environmentObject(accounts)
            .environmentObject(comments)
            .environmentObject(instances)
            .environmentObject(navigation)
            .environmentObject(player)
            .environmentObject(playerControls)
            .environmentObject(playlists)
            .environmentObject(recents)
            .environmentObject(subscriptions)
            .environmentObject(thumbnailsModel)
            .environment(\.navigationStyle, navigationStyle)
    }

    @ViewBuilder var playerViewInitialize: some View {
        if !playerInitialized {
            VideoPlayerView()
                .scaleEffect(0.00001)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        playerInitialized = true
                    }
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .injectFixtureEnvironmentObjects()
    }
}
