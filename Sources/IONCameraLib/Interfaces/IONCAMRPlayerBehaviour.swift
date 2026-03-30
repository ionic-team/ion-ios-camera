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
        // Resolve the URL in case the app sandbox path has changed
        let resolvedURL = try resolveVideoURL(url)
        let asset = AVAsset(url: resolvedURL)

        let isPlayable: Bool = if #available(iOS 15, *) {
            try await asset.load(.isPlayable)
        } else {
            asset.isPlayable
        }

        if isPlayable {
            DispatchQueue.main.async {
                let player = AVPlayer(url: resolvedURL)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                self.coordinator.present(playerViewController)

                player.play()
            }
        } else {
            throw IONCAMRError.playVideoIssue
        }
    }

    private func resolveVideoURL(_ url: URL) throws -> URL {
        // Check if the file exists at the given URL
        if FileManager.default.fileExists(atPath: url.path) {
            return url
        }

        // If not, try to reconstruct the path using the current Documents directory
        // This handles cases where the app sandbox path has changed
        let fileName = url.lastPathComponent
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let reconstructedURL = documentsURL
            .appendingPathComponent(videosDirectoryName, isDirectory: true)
            .appendingPathComponent(fileName)

        // Verify the reconstructed path exists
        guard FileManager.default.fileExists(atPath: reconstructedURL.path) else {
            throw IONCAMRError.fileNotFound
        }

        return reconstructedURL
    }
}

extension AVPlayerViewController {
    override open func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.post(name: .CAMRAVPlayerVCDismissNotification, object: nil)
    }
}

extension Notification.Name {
    static let CAMRAVPlayerVCDismissNotification = Notification.Name("DismissAVPlayerViewController")
}
