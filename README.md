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
pod 'IONCameraLib', '~> 1.0.4'
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
    private var cameraManager: IONCAMRCameraManager?
    private var galleryManager: IONCAMRGalleryManager?
    private var editManager: IONCAMREditManager?
    private var videoManager: IONCAMRVideoManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupManagers()
    }
    
    private func setupManagers() {
        cameraManager = IONCAMRCameraManager(delegate: self, viewController: self)
        galleryManager = IONCAMRGalleryManager(delegate: self, viewController: self)
        editManager = IONCAMREditManager(delegate: self, viewController: self)
        videoManager = IONCAMRVideoManager(delegate: self, viewController: self)
    }
    
    // Take a photo
    func capturePhoto() {
        do {
            let photoOptions = try IONCAMRTakePhotoOptions(
                quality: 80,
                size: IONCAMRSize(width: 1024, height: 768),
                correctOrientation: true,
                encodingType: .jpeg,
                saveToPhotoAlbum: false,
                direction: .back,
                allowEdit: true,
                returnMetadata: false,
                latestVersion: true
            )
            cameraManager?.takePhoto(with: photoOptions)
        } catch {
            print("Error creating photo options: \(error)")
        }
    }
    
    // Record a video  
    func recordVideo() {
        let videoOptions = IONCAMRRecordVideoOptions(
            saveToPhotoAlbum: false,
            returnMetadata: false
        )
        cameraManager?.recordVideo(with: videoOptions)
    }
    
    // Choose from gallery
    func chooseFromGallery() {
        let galleryOptions = IONCAMRGalleryOptions(
            mediaType: .picture,
            allowEdit: true,
            allowMultipleSelection: false,
            andThumbnailAsData: false,
            returnMetadata: false
        )
        galleryManager?.chooseFromGallery(with: galleryOptions)
    }
    
    // Edit an image
    func editImage(_ image: UIImage) {
        editManager?.editPicture(image)
    }
    
    // Edit image from URL
    func editImageFromURL(_ urlString: String) {
        let editOptions = IONCAMREditOptions(
            saveToPhotoAlbum: false,
            returnMetadata: false
        )
        editManager?.editPicture(from: urlString, with: editOptions)
    }
    
    // Clean temporary files
    func cleanupTemporaryFiles() {
        cameraManager?.cleanTemporaryFiles()
    }
}

// MARK: - IONCAMRCallbackDelegate
extension ViewController: IONCAMRCallbackDelegate {
    func callback(result: String?, error: IONCAMRError?) {
        if let error = error {
            print("Error: \(error)")
        } else if let result = result {
            print("Success: \(result)")
            // Parse JSON result to get media information
            if let data = result.data(using: .utf8) {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        print("Media result: \(json)")
                    }
                } catch {
                    print("Failed to parse result JSON")
                }
            }
        }
    }
}
```

### Video Playback

```swift
// Play video using the IONCAMRVideoManager
class VideoPlayerViewController: UIViewController {
    private var videoManager: IONCAMRVideoManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        videoManager = IONCAMRVideoManager(delegate: self, viewController: self)
    }
    
    func playVideo(from url: URL) {
        Task {
            do {
                try await videoManager?.playVideo(url)
            } catch {
                print("Failed to play video: \(error)")
            }
        }
    }
}

extension VideoPlayerViewController: IONCAMRCallbackDelegate {
    func callback(result: String?, error: IONCAMRError?) {
        if let error = error {
            print("Video playback error: \(error)")
        } else if let result = result {
            print("Video playback result: \(result)")
        }
    }
}
```

### Advanced Usage Examples

```swift
// Multiple selection from gallery
func selectMultiplePhotos() {
    let galleryOptions = IONCAMRGalleryOptions(
        mediaType: .picture,
        allowEdit: false,
        allowMultipleSelection: true,
        andThumbnailAsData: true,
        returnMetadata: true
    )
    galleryManager?.chooseFromGallery(with: galleryOptions)
}

// High quality photo with custom size
func takeHighQualityPhoto() {
    do {
        let photoOptions = try IONCAMRTakePhotoOptions(
            quality: 100,
            size: IONCAMRSize(width: 2048, height: 1536),
            correctOrientation: true,
            encodingType: .jpeg,
            saveToPhotoAlbum: true,
            direction: .front,
            allowEdit: false,
            returnMetadata: true,
            latestVersion: true
        )
        cameraManager?.takePhoto(with: photoOptions)
    } catch {
        print("Error creating high quality photo options: \(error)")
    }
}

// Video recording with save to album
func recordVideoToAlbum() {
    let videoOptions = IONCAMRRecordVideoOptions(
        saveToPhotoAlbum: true,
        returnMetadata: true
    )
    cameraManager?.recordVideo(with: videoOptions)
}
```

## Key Components

### Manager Classes

- **`IONCAMRCameraManager`**: Handle photo capture and video recording
- **`IONCAMRGalleryManager`**: Choose media from photo gallery
- **`IONCAMREditManager`**: Edit photos and images  
- **`IONCAMRVideoManager`**: Play videos

### Configuration Options

- **`IONCAMRTakePhotoOptions`**: Configure photo capture settings
- **`IONCAMRRecordVideoOptions`**: Configure video recording settings
- **`IONCAMRGalleryOptions`**: Configure gallery selection behavior
- **`IONCAMREditOptions`**: Configure image editing settings

### Callback Protocol

All managers use the `IONCAMRCallbackDelegate` protocol for results:

```swift
public protocol IONCAMRCallbackDelegate: AnyObject {
    func callback(result: String?, error: IONCAMRError?)
}
```

Results are returned as JSON strings containing `IONCAMRMediaResult` objects with media information including file paths, thumbnails, and metadata.

### Error Handling

The library provides comprehensive error handling through `IONCAMRError` enum:

```swift
extension ViewController: IONCAMRCallbackDelegate {
    func callback(result: String?, error: IONCAMRError?) {
        if let error = error {
            switch error {
            case .cameraAccess:
                // Handle camera permission issues
                showPermissionAlert()
            case .photoLibraryAccess:
                // Handle gallery permission issues
                showPhotoLibraryPermissionAlert()
            case .takePictureCancel, .editPictureCancel, .chooseMultimediaCancel:
                // Handle user cancellations
                print("Operation was cancelled by user")
            case .invalidImageData:
                // Handle invalid image data
                showErrorAlert("Invalid image selected")
            default:
                // Handle other errors
                showErrorAlert("An error occurred: \(error.localizedDescription)")
            }
        } else if let result = result {
            // Handle successful result
            processMediaResult(result)
        }
    }
}
```

## Permissions

The library requires the following permissions in your app's `Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to take photos and record videos.</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access to choose and save media files.</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>This app needs permission to save photos and videos to your library.</string>
```

The library includes a `PrivacyInfo.xcprivacy` file that documents the required privacy permissions according to Apple's requirements.

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
