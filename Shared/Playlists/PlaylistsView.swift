import Defaults
import Siesta
import SwiftUI

struct PlaylistsView: View {
    @State private var selectedPlaylistID: Playlist.ID = ""

    @State private var showingNewPlaylist = false
    @State private var createdPlaylist: Playlist?

    @State private var showingEditPlaylist = false
    @State private var editedPlaylist: Playlist?

    @StateObject private var channelPlaylist = Store<ChannelPlaylist>()
    @StateObject private var userPlaylist = Store<Playlist>()

    @EnvironmentObject<AccountsModel> private var accounts
    @EnvironmentObject<PlayerModel> private var player
    @EnvironmentObject<PlaylistsModel> private var model

    @Namespace private var focusNamespace

    var items: [ContentItem] {
        var videos = currentPlaylist?.videos ?? []

        if videos.isEmpty {
            videos = userPlaylist.item?.videos ?? channelPlaylist.item?.videos ?? []

            if !player.accounts.app.userPlaylistsEndpointIncludesVideos {
                var i = 0

                for index in videos.indices {
                    var video = videos[index]
                    video.indexID = "\(i)"
                    i += 1
                    videos[index] = video
                }
            }
        }

        return ContentItem.array(of: videos)
    }

    private var resource: Resource? {
        guard let playlist = currentPlaylist else { return nil }

        let resource = player.accounts.api.playlist(playlist.id)

        if player.accounts.app.userPlaylistsUseChannelPlaylistEndpoint {
            resource?.addObserver(channelPlaylist)
        } else {
            resource?.addObserver(userPlaylist)
        }

        return resource
    }

    var body: some View {
        BrowserPlayerControls(toolbar: {
            HStack {
                HStack {
                    newPlaylistButton
                        .offset(x: -10)
                    if currentPlaylist != nil {
                        editPlaylistButton
                    }
                }

                if !model.isEmpty {
                    Spacer()
                }

                HStack {
                    if model.isEmpty {
                        Text("No Playlists")
                            .foregroundColor(.secondary)
                    } else {
                        selectPlaylistButton
                            .transaction { t in t.animation = .none }
                    }
                }

                Spacer()

                if currentPlaylist != nil {
                    playButton
                        .offset(x: 10)
                }
            }
            .padding(.horizontal)
        }) {
            SignInRequiredView(title: NSLocalizedString("Playlists", tableName: "Localizable", bundle: .main, comment: "")) {
                ScrollView {
                    VStack {
                        #if os(tvOS)
                            toolbar
                        #endif
                        if currentPlaylist != nil, items.isEmpty {
                            hintText(NSLocalizedString("Playlist is empty\n\nTap and hold on a video and then \n\"Add to Playlist\"", tableName: "Localizable", bundle: .main, comment: ""))
                        } else if model.all.isEmpty {
                            hintText(NSLocalizedString("You have no playlists\n\nTap on \"New Playlist\" to create one", tableName: "Localizable", bundle: .main, comment: ""))
                        } else {
                            Group {
                                #if os(tvOS)
                                    HorizontalCells(items: items)
                                        .padding(.top, 40)
                                    Spacer()
                                #else
                                    VerticalCells(items: items)
                                        .environment(\.scrollViewBottomPadding, 70)
                                #endif
                            }
                            .environment(\.currentPlaylistID, currentPlaylist?.id)
                        }
                    }
                }
            }
        }
        .onAppear {
            model.load()
            resource?.load()
        }
        .onChange(of: accounts.current) { _ in
            model.load(force: true)
            resource?.load()
        }
        .onChange(of: currentPlaylist) { _ in
            channelPlaylist.clear()
            userPlaylist.clear()
            resource?.load()
        }
        .onChange(of: model.reloadPlaylists) { _ in
            resource?.load()
        }
        #if os(iOS)
        .refreshControl { refreshControl in
            model.load(force: true) {
                model.reloadPlaylists.toggle()
                refreshControl.endRefreshing()
            }
        }
        .backport
        .refreshable {
            DispatchQueue.main.async {
                model.load(force: true) { model.reloadPlaylists.toggle() }
            }
        }
        .navigationBarTitleDisplayMode(RefreshControl.navigationBarTitleDisplayMode)
        #endif
        #if os(tvOS)
        .fullScreenCover(isPresented: $showingNewPlaylist, onDismiss: selectCreatedPlaylist) {
            PlaylistFormView(playlist: $createdPlaylist)
                .environmentObject(accounts)
        }
        .fullScreenCover(isPresented: $showingEditPlaylist, onDismiss: selectEditedPlaylist) {
            PlaylistFormView(playlist: $editedPlaylist)
                .environmentObject(accounts)
        }
        .focusScope(focusNamespace)
        #else
        .background(
            EmptyView()
                .sheet(isPresented: $showingNewPlaylist, onDismiss: selectCreatedPlaylist) {
                    PlaylistFormView(playlist: $createdPlaylist)
                        .environmentObject(accounts)
                }
        )
        .background(
            EmptyView()
                .sheet(isPresented: $showingEditPlaylist, onDismiss: selectEditedPlaylist) {
                    PlaylistFormView(playlist: $editedPlaylist)
                        .environmentObject(accounts)
                }
        )
        #endif

        #if !os(macOS)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            model.load()
            resource?.loadIfNeeded()
        }
        #endif
        #if !os(tvOS)
        .background(
            Button("Refresh") {
                resource?.load()
            }
            .keyboardShortcut("r")
            .opacity(0)
        )
        #endif
    }

    #if os(tvOS)
        var toolbar: some View {
            HStack {
                if model.isEmpty {
                    Text("No Playlists")
                        .foregroundColor(.secondary)
                } else {
                    Text("Current Playlist")
                        .foregroundColor(.secondary)

                    selectPlaylistButton
                }

                if let playlist = currentPlaylist {
                    editPlaylistButton

                    FavoriteButton(item: FavoriteItem(section: .playlist(playlist.id)))
                        .labelStyle(.iconOnly)

                    playButton
                }

                Spacer()

                newPlaylistButton
                    .padding(.leading, 40)
            }
        }
    #endif

    func hintText(_ text: String) -> some View {
        VStack {
            Spacer()
            Text(text)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        #if os(macOS)
            .background(Color.secondaryBackground)
        #endif
    }

    func selectCreatedPlaylist() {
        guard createdPlaylist != nil else {
            return
        }

        model.load(force: true) {
            if let id = createdPlaylist?.id {
                selectedPlaylistID = id
            }

            self.createdPlaylist = nil
        }
    }

    func selectEditedPlaylist() {
        if editedPlaylist.isNil {
            selectedPlaylistID = ""
        }

        model.load(force: true) {
            self.selectedPlaylistID = editedPlaylist?.id ?? ""

            self.editedPlaylist = nil
        }
    }

    var selectPlaylistButton: some View {
        #if os(tvOS)
            Button(currentPlaylist?.title ?? "Select playlist") {
                guard currentPlaylist != nil else {
                    return
                }

                selectedPlaylistID = model.all.next(after: currentPlaylist!)?.id ?? ""
            }
            .lineLimit(1)
            .contextMenu {
                ForEach(model.all) { playlist in
                    Button(playlist.title) {
                        selectedPlaylistID = playlist.id
                    }
                }

                Button("Cancel", role: .cancel) {}
            }
        #else
            Menu {
                ForEach(model.all) { playlist in
                    Button(action: { selectedPlaylistID = playlist.id }) {
                        if playlist == currentPlaylist {
                            Label(playlist.title, systemImage: "checkmark")
                        } else {
                            Text(playlist.title)
                        }
                    }
                }
            } label: {
                Text(currentPlaylist?.title ?? "Select playlist")
                    .frame(maxWidth: 140, alignment: .center)
            }
        #endif
    }

    var editPlaylistButton: some View {
        Button(action: {
            self.editedPlaylist = self.currentPlaylist
            self.showingEditPlaylist = true
        }) {
            HStack(spacing: 8) {
                Image(systemName: "rectangle.and.pencil.and.ellipsis")
            }
        }
    }

    var newPlaylistButton: some View {
        Button(action: { self.showingNewPlaylist = true }) {
            HStack(spacing: 0) {
                Image(systemName: "plus")
                    .padding(8)
                    .contentShape(Rectangle())
                #if os(tvOS)
                    Text("New Playlist")
                #endif
            }
        }
    }

    private var playButton: some View {
        Button {
            player.play(items.compactMap(\.video))
        } label: {
            Image(systemName: "play")
                .padding(8)
                .contentShape(Rectangle())
        }
        .contextMenu {
            Button {
                player.play(items.compactMap(\.video), shuffling: true)
            } label: {
                Label("Shuffle", systemImage: "shuffle")
                    .padding(8)
                    .contentShape(Rectangle())
            }
        }
    }

    private var currentPlaylist: Playlist? {
        model.find(id: selectedPlaylistID) ?? model.all.first
    }
}

struct PlaylistsView_Provider: PreviewProvider {
    static var previews: some View {
        PlaylistsView()
            .injectFixtureEnvironmentObjects()
    }
}
