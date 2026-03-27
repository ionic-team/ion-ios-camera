import UIKit

/// Class responsible to trigger the user interface and handle all user interactions required to capture a picture.
final class IONCAMRPickerBehaviour: NSObject, IONCAMRPickerDelegate {
    weak var delegate: IONCAMRPickerResultsDelegate?
    /// User defined options to apply to the picker and picture objects.
    private var mediaOptions: IONCAMRMediaOptions?

    /// Verifies if camera is available for usage.
    /// - Returns: The camera's availability
    func isCameraAvailable() -> Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    func captureMedia(with mediaOptions: IONCAMRMediaOptions, _ handler: @escaping (UIViewController) -> Void) {
        self.mediaOptions = mediaOptions
        DispatchQueue.main.async {
            let pickerController = UIImagePickerController()
            pickerController.sourceType = .camera
            pickerController.mediaTypes = mediaOptions.mediaType.stringArray
            pickerController.cameraDevice = mediaOptions.cameraDevice
            pickerController.videoQuality = .typeHigh
            pickerController.delegate = self
            pickerController.modalPresentationStyle = mediaOptions.presentationStyle.uiModalPresentationStyle
            handler(pickerController)
        }
    }
}

/// Extension that handles the responses obtained through the Image Picker user interaction.
extension IONCAMRPickerBehaviour: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        Task {
            guard let mediaType = self.mediaOptions?.mediaType else {
                await self.delegate?.didReturn(self, with: .failure(.generalIssue))
                return
            }

            let result: Result<IONCAMRResultItem, IONCAMRError>
            switch mediaType {
            case .picture:
                let image = info[.originalImage] as? UIImage
                result = self.fetchToReturn(image)
                    .flatMap { .success(.picture($0)) }
                    .flatMapError { .failure($0) }
                await self.delegate?.didReturn(self, with: result)
            case .video:
                let videoURL = info[.mediaURL] as? URL
                result = self.fetchToReturn(videoURL)
                    .flatMap { .success(.video($0)) }
                    .flatMapError { .failure($0) }
                await self.delegate?.didReturn(self, with: result)
            default: break // not supposed to get here
            }
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        delegate?.didCancel(self)
    }
}

extension IONCAMRPickerBehaviour {
    private func fetchToReturn(_ picture: UIImage?) -> Result<UIImage, IONCAMRError> {
        guard let originalImage = picture,
              let pictureOptions = mediaOptions as? IONCAMRTakePhotoOptions,
              let image = originalImage.fix(with: pictureOptions)
        else { return .failure(.takePictureIssue) }

        return .success(image)
    }

    private func fetchToReturn(_ videoURL: URL?) -> Result<URL, IONCAMRError> {
        guard let videoURL else { return .failure(.captureVideoIssue) }

        let isPersistent = (mediaOptions as? IONCAMRRecordVideoOptions)?.isPersistent ?? true

        let url: URL
        if isPersistent {
            guard let permanentURL = try? videoURL.createVideoPermanentPath() else {
                return .failure(.captureVideoIssue)
            }
            url = permanentURL
        } else {
            guard let temporaryURL = try? videoURL.createVideoTemporaryPath() else {
                return .failure(.captureVideoIssue)
            }
            url = temporaryURL
        }

        return .success(url)
    }
}
