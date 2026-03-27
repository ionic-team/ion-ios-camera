import UIKit

final class IONCAMRVideoManager: NSObject {
    private let videoPlayer: IONCAMRPlayerDelegate

    init(videoPlayer: IONCAMRPlayerDelegate) {
        self.videoPlayer = videoPlayer
        super.init()
    }

    convenience init(delegate: IONCAMRCallbackDelegate, viewController: UIViewController) {
        let coordinator = IONCAMRCoordinator(rootViewController: viewController)
        let videoPlayerBehaviour = IONCAMRPlayerBehaviour(coordinator: coordinator)

        self.init(videoPlayer: videoPlayerBehaviour)
    }
}

extension IONCAMRVideoManager: IONCAMRVideoActionDelegate {
    func playVideo(_ url: URL) async throws {
        try await videoPlayer.playVideo(url)
    }
}
