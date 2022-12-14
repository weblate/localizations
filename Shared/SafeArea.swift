import Foundation
import UIKit

struct SafeArea {
    static var insets: UIEdgeInsets {
        let keyWindow = scene?.windows.first { $0.isKeyWindow }

        return keyWindow?.safeAreaInsets ?? .init()
    }

    static var verticalInset: Double {
        insets.top + insets.bottom
    }

    static var horizontalInsets: Double {
        insets.left + insets.right
    }

    static var scene: UIWindowScene? {
        UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first
    }
}
