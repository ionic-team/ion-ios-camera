import Photos
import UIKit

final class IONCAMRFlowBehaviour: NSObject, IONCAMRFlowDelegate {
    /// Responsible for handling and enabling the image picker behaviour.
    private let picker: IONCAMRPickerDelegate
    /// Responsible for handling and enabling the editing picker behaviour.
    private let editorBehaviour: IONCAMREditorDelegate
    /// Responsible for handling and enabling the gallery management behaviour.
    private let galleryBehaviour: IONCAMRGalleryDelegate
    /// Responsible for verifying the device's authorisation to its camera. It also handles the required flow to enable this authorisation.
    private let permissionsBehaviour: IONCAMRPermissionsDelegate
    private let thumbnailGenerator: IONCAMRThumbnailGeneratorDelegate
    private let metadataGetter: IONCAMRMetadataGetterDelegate
    private let imageFetcher: IONCAMRImageFetcherDelegate
    private let urlGenerator: IONCAMRURLGeneratorDelegate

    /// Handles the result of interacting with the flow interface.
    weak var delegate: IONCAMRFlowResultsDelegate?
    /// Object responsible for managing the user interface screens and respective flow.
    var coordinator: IONCAMRCoordinator
    var temporaryURLArray: [URL] = []

    private var options: IONCAMRDefaultOptionsDelegate?

    /// Constructor method.
    /// - Parameters:
    ///   - picker: Handles the picker behaviour.
    ///   - editorBehaviour: Handles the editing behaviour.
    ///   - galleryBehaviour: Handles the gallery behaviour.
    ///   - coordinator: User interface flow coordinator.
    init(
        picker: IONCAMRPickerDelegate,
        editorBehaviour: IONCAMREditorDelegate,
        galleryBehaviour: IONCAMRGalleryDelegate,
        permissionsBehaviour: IONCAMRPermissionsDelegate,
        thumbnailGenerator: IONCAMRThumbnailGeneratorDelegate,
        metadataGetter: IONCAMRMetadataGetterDelegate,
        imageFetcher: IONCAMRImageFetcherDelegate,
        urlGenerator: IONCAMRURLGeneratorDelegate,
        coordinator: IONCAMRCoordinator
    ) {
        self.picker = picker
        self.editorBehaviour = editorBehaviour
        self.galleryBehaviour = galleryBehaviour
        self.coordinator = coordinator
        self.permissionsBehaviour = permissionsBehaviour
        self.thumbnailGenerator = thumbnailGenerator
        self.metadataGetter = metadataGetter
        self.imageFetcher = imageFetcher
        self.urlGenerator = urlGenerator
        super.init()

        self.picker.delegate = self
        self.editorBehaviour.delegate = self
        self.galleryBehaviour.delegate = self
    }

    convenience init(coordinator: IONCAMRCoordinator) {
        let pickerBehaviour = IONCAMRPickerBehaviour()
        let editorBehaviour = IONCAMREditorBehaviour()
        let mediaResultGenerator = IONCAMRMediaResultGenerator()
        let galleryBehaviour = IONCAMRGalleryBehaviour(metadataGetter: mediaResultGenerator)
        let permissionsBehaviour = IONCAMRPermissionsBehaviour(coordinator: coordinator)

        self.init(
            picker: pickerBehaviour,
            editorBehaviour: editorBehaviour,
            galleryBehaviour: galleryBehaviour,
            permissionsBehaviour: permissionsBehaviour,
            thumbnailGenerator: mediaResultGenerator,
            metadataGetter: mediaResultGenerator,
            imageFetcher: mediaResultGenerator,
            urlGenerator: mediaResultGenerator,
            coordinator: coordinator
        )
    }

    func takePhoto(with options: IONCAMRTakePhotoOptions) {
        captureMedia(with: options)
    }

    func recordVideo(with options: IONCAMRRecordVideoOptions) {
        captureMedia(with: options)
    }

    private func captureMedia(with mediaOptions: IONCAMRMediaOptions) {
        permissionsBehaviour.checkForCamera { [weak self] authorised in
            guard let self else { return }
            guard authorised else {
                delegate?.didFailed(type: IONCAMRMediaResult.self, with: .cameraAccess)
                return
            }

            guard picker.isCameraAvailable() else {
                delegate?.didFailed(type: IONCAMRMediaResult.self, with: .cameraAvailability)
                return
            }

            options = mediaOptions
            picker.captureMedia(with: mediaOptions) { [weak self] viewController in
                self?.present(viewController)
            }
        }
    }

    func editPhoto(_ image: UIImage) {
        editorBehaviour.editPicture(image) { [weak self] viewController in
            self?.present(viewController)
        }
    }

    func editPhoto(with options: IONCAMRPhotoEditOptions) {
        guard let image = imageFetcher.retrieveImage(from: options.uri) else {
            delegate?.didFailed(type: IONCAMRMediaResult.self, with: .fetchImageFromURLFailed)
            return
        }

        self.options = options
        editorBehaviour.editPicture(image) { [weak self] viewController in
            self?.present(viewController)
        }
    }

    func chooseFromGallery(with options: IONCAMRGalleryOptions) {
        permissionsBehaviour.checkForPhotoLibrary { [weak self] authorised in
            guard let self else { return }

            guard authorised else {
                // the type is indifferent as the flow will be the same
                delegate?.didFailed(type: IONCAMRMediaResult.self, with: .photoLibraryAccess)
                return
            }

            self.options = options
            galleryBehaviour.chooseFromGallery(with: options) { [weak self] viewController in
                self?.present(viewController)
            }
        }
    }

    func cleanTemporaryFiles() {
        temporaryURLArray.forEach { try? $0.deleteTemporaryPath() }
        temporaryURLArray.removeAll()
    }
}

extension IONCAMRFlowBehaviour: IONCAMRCancelResultsDelegate {
    func didCancel(_ object: AnyObject) {
        if object === picker, let mediaOptions = options as? IONCAMREditMediaTypeOptionsDelegate {
            switch mediaOptions.mediaType {
            case .picture:
                delegate?.didCancel(.takePictureCancel)
            case .video:
                delegate?.didCancel(.captureVideoCancel)
            case .both:
                delegate?.didCancel(.chooseMultimediaCancel)
            default: break // not supposed to get here
            }
        } else if object === editorBehaviour {
            delegate?.didCancel(.editPictureCancel)
        } else if object === galleryBehaviour {
            delegate?.didCancel(.chooseMultimediaCancel)
        }
        coordinator.dismiss()
        options = nil
    }
}

extension IONCAMRFlowBehaviour: IONCAMRResultsDelegate {
    func didReturn(_ object: AnyObject, with result: Result<IONCAMRResultItem, IONCAMRError>) async {
        if object === picker {
            await pickerDidReturn(result)
        } else if object === editorBehaviour {
            await editorDidReturn(result)
        } else if object === galleryBehaviour {
            galleryDidReturnSingle(result)
        }
    }
}

extension IONCAMRFlowBehaviour: IONCAMRMultipleResultsDelegate {
    func didReturn(_ result: Result<[IONCAMRMediaResult], IONCAMRError>) {
        galleryDidReturnMultiple(result)
    }
}

extension IONCAMRFlowBehaviour {
    /// Push a new view controller into the navigation stack, through the `coordinator` object.
    /// - Parameter viewController: View Controller to push.
    private func present(_ viewController: UIViewController) {
        DispatchQueue.main.async {
            self.coordinator.present(viewController)
        }
    }

    /// Enum containing error related with image transformation.
    fileprivate enum IONCAMRMultimediaError: Error {
        case mediaOptionsConversion, mediaResultCreation, stringConversion, thumbnailGeneratorIssue, treatmentIssue
    }

    private func convertToMediaResult(
        _ image: UIImage,
        with options: IONCAMRTakePhotoOptions? = nil,
        separateReturnTypeBasedOn returnComplexVersion: Bool,
        and returnMetadata: Bool,
        savedToGallery: Bool? = nil
    ) throws
        -> IONCAMRMediaResult {
        guard let imageResult = image.toData(with: options) else { throw IONCAMRMultimediaError.treatmentIssue }

        let result: IONCAMRMediaResult
        if returnComplexVersion {
            guard let imageURL = urlGenerator.url(for: imageResult, withEncodingType: options?.encodingType),
                  let imageThumbnail = thumbnailGenerator.getBase64String(from: image, with: options?.size, and: options?.quality)
            else { throw IONCAMRMultimediaError.mediaResultCreation }

            temporaryURLArray += [imageURL]

            var metadata: IONCAMRMetadata?
            if returnMetadata {
                metadata = try? metadataGetter.getImageMetadata(from: image, and: imageURL)
            }

            result = IONCAMRMediaResult(pictureWith: imageURL.absoluteString, imageThumbnail, and: metadata, saved: savedToGallery)
        } else {
            result = IONCAMRMediaResult(pictureWith: imageResult.base64EncodedString(), saved: savedToGallery)
        }

        return result
    }

    /// Apply all the user defined transformations to the resulting image.
    /// - Parameters:
    ///   - image: Image to treat.
    ///   - options: User defined options with the transformations to apply to the image.
    private func treat(_ image: UIImage, with options: IONCAMRTakePhotoOptions) async throws -> IONCAMRMediaResult {
        var savedToGallery = false
        if options.saveToGallery {
            savedToGallery = await galleryBehaviour.saveToGallery(image)
        }
        return try convertToMediaResult(
            image,
            with: options,
            separateReturnTypeBasedOn: true,
            and: options.returnMetadata,
            savedToGallery: savedToGallery
        )
    }

    /// Return type allows us to return a single `IONCAMRMediaResult` (for `ChoosePictureGallery`) or an array of it (for `ChooseFromGallery`).
    private func treat(_ image: UIImage, with options: IONCAMRGalleryOptions) throws -> any Encodable {
        let result = try convertToMediaResult(image, separateReturnTypeBasedOn: options.thumbnailAsData, and: options.returnMetadata)

        return options.thumbnailAsData ? [result] : result
    }

    private func treat(_ url: URL, with options: IONCAMRRecordVideoOptions, _ completion: @escaping (IONCAMRMediaResult?) -> Void) {
        // Only add to temporaryURLArray if video is not persistent
        if !options.isPersistent {
            temporaryURLArray += [url]
        }

        Task {
            var saved = false
            if options.saveToGallery {
                saved = await self.galleryBehaviour.saveToGallery(url)
            }
            thumbnailGenerator.getImage(from: url) { image in
                guard let image, let data = image.defaultVideoThumbnailData
                else { return completion(nil) }

                if options.returnMetadata {
                    Task {
                        let metadata = try? await self.metadataGetter.getVideoMetadata(from: url)
                        let result = IONCAMRMediaResult(videoWith: url.absoluteString, data, and: metadata, saved: saved)
                        completion(result)
                    }
                } else {
                    let result = IONCAMRMediaResult(videoWith: url.absoluteString, data, saved: saved)
                    completion(result)
                }
            }
        }
    }
}

// MARK: Picker Related Extension

extension IONCAMRFlowBehaviour {
    private func imagePickerDidReturn(_ image: UIImage) async throws -> IONCAMRMediaResult? {
        var result: IONCAMRMediaResult?

        guard let pictureOptions = options as? IONCAMRTakePhotoOptions else { throw IONCAMRMultimediaError.mediaOptionsConversion }
        if !pictureOptions.allowEdit {
            guard let treatedImage = try? await treat(image, with: pictureOptions) else { throw IONCAMRMultimediaError.treatmentIssue }
            result = treatedImage
        }

        return result
    }

    private func videoPickerDidReturn(_ url: URL, _ completion: @escaping (IONCAMRMediaResult?) -> Void) {
        guard let videoOptions = options as? IONCAMRRecordVideoOptions else { return completion(nil) }
        treat(url, with: videoOptions, completion)
    }

    /// Method triggered when the user could finish, with or without success, the picker behaviour.
    /// - Parameter result: Returned object to who implements this object. It returns a base64 encoding text if successful or an error otherwise.
    func pickerDidReturn(_ result: Result<IONCAMRResultItem, IONCAMRError>) async {
        func didFailed(withError error: IONCAMRError) {
            delegate?.didFailed(type: IONCAMRMediaResult.self, with: error)
        }

        var canDismiss = true
        defer {
            if canDismiss {
                self.coordinator.dismiss()
                self.options = nil
            }
        }

        switch result {
        case .success(let item):
            switch item {
            case .picture(let image):
                do {
                    guard let mediaResult = try await imagePickerDidReturn(image) else {
                        canDismiss = false
                        editPhoto(image)
                        return
                    }
                    delegate?.didSucceed(with: mediaResult)
                } catch {
                    didFailed(withError: .takePictureIssue)
                }
            case .video(let url):
                videoPickerDidReturn(url) { [weak self] mediaResult in
                    self?.options = nil
                    guard let mediaResult else { return didFailed(withError: .captureVideoIssue) }
                    self?.delegate?.didSucceed(with: mediaResult)
                }
            }
        case .failure(let error):
            options = nil
            didFailed(withError: error)
        }
    }
}

// MARK: - Editor Related Extension

extension IONCAMRFlowBehaviour {
    private func imageEditorDidReturn(_ image: UIImage) async throws -> any Encodable {
        if coordinator.isSecondStep {
            if let pictureOptions = options as? IONCAMRTakePhotoOptions {
                return try await treat(image, with: pictureOptions)
            }
            if let galleryOptions = options as? IONCAMRGalleryOptions {
                return try treat(image, with: galleryOptions)
            }

            throw IONCAMRMultimediaError.treatmentIssue
        }

        var separator = false
        var returnMetadata = false
        var savedToGallery = false
        if let options = options as? IONCAMRSaveToGalleryOptionsDelegate {
            separator = true
            returnMetadata = options.returnMetadata

            if options.saveToGallery {
                savedToGallery = await galleryBehaviour.saveToGallery(image)
            }
        }

        return try convertToMediaResult(image, separateReturnTypeBasedOn: separator, and: returnMetadata, savedToGallery: savedToGallery)
    }

    /// Method triggered when the user could finish, with or without success, the editor behaviour.
    /// - Parameter result: Returned object to who implements this object. It returns a base64 encoding text if successful or an error otherwise.
    func editorDidReturn(_ result: Result<IONCAMRResultItem, IONCAMRError>) async {
        func didFailed(with error: IONCAMRError = .editPictureIssue) {
            delegate?.didFailed(type: IONCAMRMediaResult.self, with: error)
        }

        defer { self.coordinator.dismiss() }

        switch result {
        case .success(let item):
            if case .picture(let image) = item {
                do {
                    let result = try await imageEditorDidReturn(image)
                    delegate?.didSucceed(with: result)
                } catch {
                    if let ionError = error as? IONCAMRError {
                        didFailed(with: ionError)
                    } else {
                        didFailed()
                    }
                }
            }
        case .failure(let error):
            options = nil
            didFailed(with: error)
        }
    }
}

// MARK: - Gallery Related Extension

extension IONCAMRFlowBehaviour {
    private func galleryDidReturnSingle(_ result: Result<IONCAMRResultItem, IONCAMRError>) {
        func didFailed(with error: IONCAMRError = .choosePictureIssue) {
            delegate?.didFailed(type: IONCAMRMediaResult.self, with: error)
        }

        var canDismiss = true
        defer {
            if canDismiss {
                self.coordinator.dismiss()
                self.options = nil
            }
        }

        switch result {
        case .success(let item):
            if case .picture(let image) = item {
                guard let options = options as? IONCAMREditMediaTypeOptionsDelegate else { return didFailed() }

                if !options.allowEdit {
                    guard let result = image.toData()?.base64EncodedString() else { return didFailed() }
                    let mediaResult = IONCAMRMediaResult(pictureWith: result)
                    delegate?.didSucceed(with: mediaResult)
                } else {
                    canDismiss = false
                    editPhoto(image)
                }
            }
        case .failure(let error):
            didFailed(with: error)
        }
    }

    private func galleryDidReturnMultiple(_ result: Result<[IONCAMRMediaResult], IONCAMRError>) {
        func didFailed(with error: IONCAMRError = .chooseMultimediaIssue) {
            delegate?.didFailed(type: [IONCAMRMediaResult].self, with: error)
        }

        var canDismiss = true
        defer {
            if canDismiss {
                self.coordinator.dismiss()
                self.options = nil
            }
        }

        switch result {
        case .success(let items):
            guard let options = options as? IONCAMRGalleryOptions else { return didFailed() }

            if options.allowEdit, options.mediaType == .picture, !options.allowMultipleSelection {
                guard let mediaResult = items.first, let image = imageFetcher.retrieveImage(from: mediaResult.uri)?.fixOrientation()
                else { return didFailed(with: .fetchImageFromURLFailed) }

                canDismiss = false
                editPhoto(image)
            } else {
                delegate?.didSucceed(with: items)
            }
        case .failure(let error):
            didFailed(with: error)
        }
    }
}
