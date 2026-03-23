import UIKit

public enum IONCAMRPresentationStyle : String, Codable {
    case fullScreen
    case popover

    var uiModalPresentationStyle: UIModalPresentationStyle {
        switch self {
        case .fullScreen:
            return .fullScreen
        case .popover:
            return .popover
        }
    }
}
