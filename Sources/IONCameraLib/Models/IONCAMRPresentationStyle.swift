import UIKit

public enum IONCAMRPresentationStyle : String, Codable {
    case fullscreen
    case popover

    var uiModalPresentationStyle: UIModalPresentationStyle {
        switch self {
        case .fullscreen:
            return .fullScreen
        case .popover:
            return .popover
        }
    }
}
