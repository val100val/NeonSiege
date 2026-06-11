import SwiftUI
import SpriteKit

@main
struct NeonSiegeApp: App {
    var body: some Scene {
        WindowGroup {
            GameContainerView()
                #if os(macOS)
                .frame(minWidth: 960, minHeight: 570)
                #endif
        }
        #if os(macOS)
        .defaultSize(width: 1280, height: 760)
        #endif
    }
}

struct GameContainerView: View {
    @State private var scene: SKScene = {
        #if os(iOS)
        let bounds = UIScreen.main.bounds.size
        let size = CGSize(width: max(bounds.width, bounds.height),
                          height: min(bounds.width, bounds.height))
        let scene = MenuScene(size: size)
        #else
        // Fixed logical canvas; platformScaleMode (.aspectFit) letterboxes on resize.
        let scene = MenuScene(size: CGSize(width: 1280, height: 760))
        #endif
        return scene
    }()

    var body: some View {
        SpriteView(scene: scene, options: [.ignoresSiblingOrder])
            .ignoresSafeArea()
            #if os(iOS)
            .statusBarHidden(true)
            .persistentSystemOverlays(.hidden)
            .onAppear {
                UIApplication.shared.isIdleTimerDisabled = true
            }
            #endif
    }
}
