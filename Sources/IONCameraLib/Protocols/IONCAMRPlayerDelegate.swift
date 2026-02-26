import Foundation

protocol IONCAMRPlayerDelegate: AnyObject {
    func playVideo(_ url: URL) async throws
}
