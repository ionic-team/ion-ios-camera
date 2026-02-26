import AVKit

final class IONCAMRPlayerBehaviour: NSObject, IONCAMRPlayerDelegate {
    /// Object responsible for managing the user interface screens and respective flow.
    var coordinator: IONCAMRCoordinator
    
    init(coordinator: IONCAMRCoordinator) {
        self.coordinator = coordinator
        super.init()
        
        NotificationCenter.default.addObserver(forName: .CAMRAVPlayerVCDismissNotification, object: nil, queue: nil) { _ in
            DispatchQueue.main.async {
                self.coordinator.dismiss()
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func playVideo(_ url: URL) async throws {
        let asset = AVAsset(url: url)
        
        let isPlayable: Bool
        if #available(iOS 15, *) {
            isPlayable = try await asset.load(.isPlayable)
        } else {
            isPlayable = asset.isPlayable
        }
        
        if isPlayable {
            DispatchQueue.main.async {
                let player = AVPlayer(url: url)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                self.coordinator.present(playerViewController)
                
                player.play()
            }
        } else {
            throw IONCAMRError.playVideoIssue
        }
    }
}

extension AVPlayerViewController {
    open override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.post(name: .CAMRAVPlayerVCDismissNotification, object: nil)
    }
}

extension Notification.Name {
    static let CAMRAVPlayerVCDismissNotification = Notification.Name("DismissAVPlayerViewController")
}
