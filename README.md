# IONCameraLib

A modern, flexible and feature-rich camera and media library for iOS apps. Includes advanced photo, video, and gallery management with easy integration for Swift and UIKit projects.

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/ionic-team/ion-ios-camera.git", from: "1.0.0")
]
```

### CocoaPods

Add the following to your `Podfile`:

```ruby
pod 'IONCameraLib', '~> 1.0.0'
```

Then run:

```bash
pod install
```

## Usage

### Basic Camera Operations

```swift
import IONCameraLib

class ViewController: UIViewController {
    let cameraManager = IONCameraManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraManager.delegate = self
    }
    
    // Take a photo
    func capturePhoto() {
        let imageConfig = IONImageProcessorConfiguration()
        imageConfig.imageFormat = .jpeg
        imageConfig.jpegCompressionQuality = 0.8
        
        cameraManager.takePhoto(imageProcessorConfiguration: imageConfig) { controller in
            self.present(controller, animated: true)
        }
    }
    
    // Record a video  
    func recordVideo() {
        let videoConfig = IONVideoProcessorConfiguration()
        videoConfig.videoFormat = .mp4
        videoConfig.videoQuality = .medium
        
        cameraManager.recordVideo(videoProcessorConfiguration: videoConfig) { controller in
            self.present(controller, animated: true)
        }
    }
}

// MARK: - IONCameraManagerDelegate
extension ViewController: IONCameraManagerDelegate {
    func cameraManager(_ manager: IONCameraManager, didCaptureMediaWith result: IONMediaResult) {
        switch result.mediaType {
        case .image:
            print("Image captured: \(result.fileURL)")
        case .video:
            print("Video captured and processed: \(result.fileURL)")
        }
    }
    
    func cameraManager(_ manager: IONCameraManager, didFailWithError error: IONCameraError) {
        print("Camera error: \(error.description)")
    }
    
    func cameraManagerDidCancel(_ manager: IONCameraManager) {
        print("Camera operation cancelled")
    }
}
```

### Advanced Video Processing

```swift
// Compress an existing video
IONVideoProcessor.compressVideo(originalVideoURL, quality: .medium) { processedURL, error in
    guard let url = processedURL else {
        print("Compression failed: \(error?.description ?? "Unknown error")")
        return
    }
    print("Video compressed and saved to: \(url)")
}

// Trim video (5 to 30 seconds)
IONVideoProcessor.trimVideo(originalVideoURL, startTime: 5.0, endTime: 30.0) { trimmedURL, error in
    // Handle result...
}

// Extract thumbnail at 2 seconds
let thumbnail = IONVideoProcessor.extractThumbnail(from: videoURL, atTime: 2.0)

// Get video information
let duration = IONVideoProcessor.getVideoDuration(videoURL)
let resolution = IONVideoProcessor.getVideoResolution(videoURL)
let fileSize = IONVideoProcessor.getVideoFileSize(videoURL)
```

### Video Playback

```swift
// Play video using system player - basic
IONVideoManager.playVideo(from: videoURL) { playerController in
    present(playerController, animated: true)
}

// Play video with custom configuration
IONVideoManager.playVideo(
    from: videoURL,
    allowsPictureInPicturePlayback: false,
    showsPlaybackControls: true
) { playerController in
    present(playerController, animated: true)
}

// Create embedded video player view
let playerView = IONVideoManager.createVideoPlayerView(for: videoURL, frame: videoFrame)
containerView.addSubview(playerView)

// Check if video can be played
if IONVideoManager.canPlayVideo(at: videoURL) {
    let playbackInfo = IONVideoManager.getVideoPlaybackInfo(videoURL)
    print("Video info: \(playbackInfo ?? [:])")
}
```

## Requirements

- iOS 14.0+
- Xcode 15.0+
- Swift 5.0+

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Support

- Report issues on our [Issue Tracker](https://github.com/ionic-team/ion-ios-camera/issues)
