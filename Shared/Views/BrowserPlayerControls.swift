import Foundation
import SDWebImageSwiftUI
import SwiftUI

struct BrowserPlayerControls<Content: View, Toolbar: View>: View {
    enum Context {
        case browser, player
    }

    let content: Content
    let toolbar: Toolbar?

    init(
        context _: Context? = nil,
        @ViewBuilder toolbar: @escaping () -> Toolbar? = { nil },
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.content = content()
        self.toolbar = toolbar()
    }

    init(
        context: Context? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) where Toolbar == EmptyView {
        self.init(context: context, toolbar: { EmptyView() }, content: content)
    }

    var body: some View {
        #if os(tvOS)
            return content
        #else
            // TODO: remove
            #if DEBUG
                if #available(iOS 15.0, macOS 12.0, *) {
                    Self._printChanges()
                }
            #endif

            return ZStack(alignment: .bottomLeading) {
                content
                    .frame(maxHeight: .infinity)

                #if !os(tvOS)
                    VStack(spacing: 0) {
                        #if os(iOS)
                            toolbar
                                .frame(height: 35)
                                .frame(maxWidth: .infinity)
                                .borderTop(height: 0.4, color: Color("ControlsBorderColor"))
                                .modifier(ControlBackgroundModifier())
                        #endif

                        ControlsBar(fullScreen: .constant(false))
                            .edgesIgnoringSafeArea(.bottom)
                    }
                #endif
            }
        #endif
    }
}

struct PlayerControlsView_Previews: PreviewProvider {
    static var previews: some View {
        BrowserPlayerControls(context: .player, toolbar: {
            Button("Button") {}
        }) {
            BrowserPlayerControls {
                VStack {
                    Spacer()
                    TextField("A", text: .constant("abc"))
                    Text("Test string")
                    Text("Test string 2")
                    Text("Test string 3")
                    Spacer()
                }
            }
            .offset(y: -100)
        }
        .injectFixtureEnvironmentObjects()
    }
}
