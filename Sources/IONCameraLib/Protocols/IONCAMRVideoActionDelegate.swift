import UIKit

public protocol IONCAMRVideoActionDelegate: AnyObject {
    func playVideo(_ url: URL) async throws
}
