import Photos
import UniformTypeIdentifiers
import UIKit

/// Contains all method that converts `IONCAMRMediaOptions` properties into a native SDK equivalent
extension IONCAMRMediaOptions {
    /// Converts the `direction` property into a `UIImagePickerController.CameraDevice`.
    /// - Returns: The resulting equivalent
    var cameraDevice: UIImagePickerController.CameraDevice {
        switch self.direction {
        case .front: return .front
        case .back: return .rear
        }
    }
}

extension IONCAMRMediaType: Hashable {
    var stringArray: [String] {
        self.transform(basedOn: [IONCAMRMediaType.picture: UTType.image, .video: .movie])
            .map(\.identifier)
    }
    
    var phAssetArray: [PHAssetMediaType] {
        self.transform(basedOn: [IONCAMRMediaType.picture: PHAssetMediaType.image, .video: .video])
    }

    private func transform<T>(basedOn map: [Self: T]) -> [T] {
        map.reduce(into: [T]()) { partialResult, currentOption in
            if self.contains(currentOption.key) {
                partialResult.append(currentOption.value)
            }
        }
    }
}
