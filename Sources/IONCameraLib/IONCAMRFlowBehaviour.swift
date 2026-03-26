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
        self.permissionsBehaviour.checkForCamera { [weak self] authorised in
            guard let self = self else { return }
            guard authorised else {
                self.delegate?.didFailed(type: IONCAMRMediaResult.self, with: .cameraAccess)
                return
            }
            
            guard self.picker.isCameraAvailable() else {
                self.delegate?.didFailed(type: IONCAMRMediaResult.self, with: .cameraAvailability)
                return
            }
            
            self.options = mediaOptions
            self.picker.captureMedia(with: mediaOptions) { [weak self] viewController in
                self?.present(viewController)
            }
        }
    }
    
    func editPhoto(_ image: UIImage) {
        self.editorBehaviour.editPicture(image) { [weak self] viewController in
            self?.present(viewController)
        }
    }
    
    func editPhoto(with options: IONCAMRPhotoEditOptions) {
        guard let image = self.imageFetcher.retrieveImage(from: options.uri) else {
            self.delegate?.didFailed(type: IONCAMRMediaResult.self, with: .fetchImageFromURLFailed)
            return
        }
        
        self.options = options
        self.editorBehaviour.editPicture(image) { [weak self] viewController in
            self?.present(viewController)
        }
    }
    
    func chooseFromGallery(with options: IONCAMRGalleryOptions) {
        self.permissionsBehaviour.checkForPhotoLibrary { [weak self] authorised in
            guard let self = self else { return }
            
            guard authorised else {
                // the type is indifferent as the flow will be the same
                self.delegate?.didFailed(type: IONCAMRMediaResult.self, with: .photoLibraryAccess)
                return
            }
            
            self.options = options
            self.galleryBehaviour.chooseFromGallery(with: options) { [weak self] viewController in
                self?.present(viewController)
            }
        }
    }
    
    func cleanTemporaryFiles() {
        self.temporaryURLArray.forEach { try? $0.deleteTemporaryPath() }
        self.temporaryURLArray.removeAll()
    }
}

extension IONCAMRFlowBehaviour: IONCAMRCancelResultsDelegate {
    func didCancel(_ object: AnyObject) {
        if object === self.picker, let mediaOptions = self.options as? IONCAMREditMediaTypeOptionsDelegate {
            switch mediaOptions.mediaType {
            case .picture:
                self.delegate?.didCancel(.takePictureCancel)
            case .video:
                self.delegate?.didCancel(.captureVideoCancel)
            case .both:
                self.delegate?.didCancel(.chooseMultimediaCancel)
            default: break  // not supposed to get here
            }
        } else if object === self.editorBehaviour {
            self.delegate?.didCancel(.editPictureCancel)
        } else if object === self.galleryBehaviour {
            self.delegate?.didCancel(.choosePictureCancel)
        }
        self.coordinator.dismiss()
        self.options = nil
    }
}

extension IONCAMRFlowBehaviour: IONCAMRResultsDelegate {
    func didReturn(_ object: AnyObject, with result: Result<IONCAMRResultItem, IONCAMRError>) async {
        if object === self.picker {
            await self.pickerDidReturn(result)
        } else if object === self.editorBehaviour {
            self.editorDidReturn(result)
        } else if object === self.galleryBehaviour {
            self.galleryDidReturnSingle(result)
        }
    }
}

extension IONCAMRFlowBehaviour: IONCAMRMultipleResultsDelegate {
    func didReturn(_ result: Result<[IONCAMRMediaResult], IONCAMRError>) {
        self.galleryDidReturnMultiple(result)
    }
}

private extension IONCAMRFlowBehaviour {
    /// Push a new view controller into the navigation stack, through the `coordinator` object.
    /// - Parameter viewController: View Controller to push.
    func present(_ viewController: UIViewController) {
        DispatchQueue.main.async {
            self.coordinator.present(viewController)
        }
    }
    
    /// Enum containing error related with image transformation.
    enum IONCAMRMultimediaError: Error {
        case mediaOptionsConversion, mediaResultCreation, stringConversion, thumbnailGeneratorIssue, treatmentIssue
    }
    
    func convertToMediaResult(_ image: UIImage, with options: IONCAMRTakePhotoOptions? = nil, separateReturnTypeBasedOn returnComplexVersion: Bool, and returnMetadata: Bool, savedToGallery: Bool? = nil) throws -> IONCAMRMediaResult {
        guard let imageResult = image.toData(with: options) else { throw IONCAMRMultimediaError.treatmentIssue }
        
        let result: IONCAMRMediaResult
        if returnComplexVersion {
            guard let imageURL = self.urlGenerator.url(for: imageResult, withEncodingType: options?.encodingType),
                  let imageThumbnail = self.thumbnailGenerator.getBase64String(from: image, with: options?.size, and: options?.quality)
            else { throw IONCAMRMultimediaError.mediaResultCreation }
            
            self.temporaryURLArray += [imageURL]
            
            var metadata: IONCAMRMetadata?
            if returnMetadata {
                metadata = try? self.metadataGetter.getImageMetadata(from: image, and: imageURL)
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
    func treat(_ image: UIImage, with options: IONCAMRTakePhotoOptions) async throws -> IONCAMRMediaResult {
        var savedToGallery = false
        if options.saveToGallery {
            savedToGallery = await self.galleryBehaviour.saveToGallery(image)
        }
        return try self.convertToMediaResult(image, with: options, separateReturnTypeBasedOn: true, and: options.returnMetadata, savedToGallery: savedToGallery)
    }
    
    /// Return type allows us to return a single `IONCAMRMediaResult` (for `ChoosePictureGallery`) or an array of it (for `ChooseFromGallery`).
    func treat(_ image: UIImage, with options: IONCAMRGalleryOptions) throws -> any Encodable {
        let result = try self.convertToMediaResult(image, separateReturnTypeBasedOn: options.thumbnailAsData, and: options.returnMetadata)
        
        return options.thumbnailAsData ? [result] : result
    }
    
    func treat(_ url: URL, with options: IONCAMRRecordVideoOptions, _ completion: @escaping (IONCAMRMediaResult?) -> Void) {
        // Only add to temporaryURLArray if video is not persistent
        if !options.isPersistent {
            self.temporaryURLArray += [url]
        }
        
        if options.saveToGallery {
            Task { await self.galleryBehaviour.saveToGallery(url) }
        }
        
        self.thumbnailGenerator.getImage(from: url) { image in
            guard let image = image, let data = image.defaultVideoThumbnailData
            else { return completion(nil) }
           
            if options.returnMetadata {
                Task { [url] in
                    let metadata = try? await self.metadataGetter.getVideoMetadata(from: url)
                    let result = IONCAMRMediaResult(videoWith: url.absoluteString, data, and: metadata)
                    completion(result)
                }
            } else {
                let result = IONCAMRMediaResult(videoWith: url.absoluteString, data)
                completion(result)
            }
        }
    }
}

// MARK: Picker Related Extension
private extension IONCAMRFlowBehaviour {
    func imagePickerDidReturn(_ image: UIImage) async throws -> IONCAMRMediaResult? {
        var result: IONCAMRMediaResult?
        
        guard let pictureOptions = self.options as? IONCAMRTakePhotoOptions else { throw IONCAMRMultimediaError.mediaOptionsConversion }
        if !pictureOptions.allowEdit {
            guard let treatedImage = try? await self.treat(image, with: pictureOptions) else { throw IONCAMRMultimediaError.treatmentIssue }
            result = treatedImage
        }
        
        return result
    }
    
    func videoPickerDidReturn(_ url: URL, _ completion: @escaping (IONCAMRMediaResult?) -> Void) {
        guard let videoOptions = self.options as? IONCAMRRecordVideoOptions else { return completion(nil) }
        self.treat(url, with: videoOptions, completion)
    }
    
    /// Method triggered when the user could finish, with or without success, the picker behaviour.
    /// - Parameter result: Returned object to who implements this object. It returns a base64 encoding text if successful or an error otherwise.
    func pickerDidReturn(_ result: Result<IONCAMRResultItem, IONCAMRError>) async {
        func didFailed(withError error: IONCAMRError) {
            self.delegate?.didFailed(type: IONCAMRMediaResult.self, with: error)
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
                    guard let mediaResult = try await self.imagePickerDidReturn(image) else {
                        canDismiss = false
                        self.editPhoto(image)
                        return
                    }
                    self.delegate?.didSucceed(with: mediaResult)
                } catch {
                    didFailed(withError: .takePictureIssue)
                }
            case .video(let url):
                self.videoPickerDidReturn(url) { [weak self] mediaResult in
                    guard let mediaResult = mediaResult else { return didFailed(withError: .captureVideoIssue) }
                    self?.delegate?.didSucceed(with: mediaResult)
                }
            }
        case .failure(let error):
            didFailed(withError: error)
        }
    }
}

// MARK: - Editor Related Extension
private extension IONCAMRFlowBehaviour {
    func imageEditorDidReturn(_ image: UIImage) async throws -> any Encodable {
        if self.coordinator.isSecondStep {
            if let pictureOptions = self.options as? IONCAMRTakePhotoOptions {
                return try await self.treat(image, with: pictureOptions)
            }
            if let galleryOptions = self.options as? IONCAMRGalleryOptions {
                return try self.treat(image, with: galleryOptions)
            }

            throw IONCAMRMultimediaError.treatmentIssue
        }

        var separator: Bool = false
        var returnMetadata: Bool = false
        var savedToGallery = false
        if let options = self.options as? IONCAMRSaveToGalleryOptionsDelegate {
            separator = true
            returnMetadata = options.returnMetadata

            if options.saveToGallery {
                savedToGallery = await self.galleryBehaviour.saveToGallery(image)
            }
        }

        return try self.convertToMediaResult(image, separateReturnTypeBasedOn: separator, and: returnMetadata, savedToGallery: savedToGallery)
    }
    
    /// Method triggered when the user could finish, with or without success, the editor behaviour.
    /// - Parameter result: Returned object to who implements this object. It returns a base64 encoding text if successful or an error otherwise.
    func editorDidReturn(_ result: Result<IONCAMRResultItem, IONCAMRError>) {
        func didFailed(with error: IONCAMRError = .editPictureIssue) {
            self.delegate?.didFailed(type: IONCAMRMediaResult.self, with: error)
        }
        
        defer {
            self.coordinator.dismiss()
            self.options = nil
        }
        
        switch result {
        case .success(let item):
            if case .picture(let image) = item {
                Task {
                    do {
                        let result = try await imageEditorDidReturn(image)
                        self.delegate?.didSucceed(with: result)
                    } catch {
                        didFailed()
                    }
                }
            }
        case .failure(let error):
            didFailed(with: error)
        }
    }
}

// MARK: - Gallery Related Extension
private extension IONCAMRFlowBehaviour {
    func galleryDidReturnSingle(_ result: Result<IONCAMRResultItem, IONCAMRError>) {
        func didFailed(with error: IONCAMRError = .choosePictureIssue) {
            self.delegate?.didFailed(type: IONCAMRMediaResult.self, with: error)
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
                guard let options = self.options as? IONCAMREditMediaTypeOptionsDelegate else { return didFailed() }

                if !options.allowEdit {
                    guard let result = image.toData()?.base64EncodedString() else { return didFailed() }
                    let mediaResult = IONCAMRMediaResult(pictureWith: result)
                    self.delegate?.didSucceed(with: mediaResult)
                } else {
                    canDismiss = false
                    self.editPhoto(image)
                }
            }
        case .failure(let error):
            didFailed(with: error)
        }
    }
    
    func galleryDidReturnMultiple(_ result: Result<[IONCAMRMediaResult], IONCAMRError>) {
        func didFailed(with error: IONCAMRError = .chooseMultimediaIssue) {
            self.delegate?.didFailed(type: [IONCAMRMediaResult].self, with: error)
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
            guard let options = self.options as? IONCAMRGalleryOptions else { return didFailed() }

            if options.allowEdit, options.mediaType == .picture, !options.allowMultipleSelection {
                guard let mediaResult = items.first, let image = self.imageFetcher.retrieveImage(from: mediaResult.uri)?.fixOrientation()
                else { return didFailed(with: .fetchImageFromURLFailed) }
                      
                canDismiss = false
                self.editPhoto(image)
            } else {
                self.delegate?.didSucceed(with: items)
            }
        case .failure(let error):
            didFailed(with: error)
        }

    }
}
