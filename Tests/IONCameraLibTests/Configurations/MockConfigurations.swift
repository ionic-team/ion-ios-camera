import UIKit
@testable import IONCameraLib

struct IONCAMRPictureOptionsConfigurations {
    static let jpegEncodingType = try? IONCAMRTakePhotoOptions(
        quality: 100,
        correctOrientation: true,
        encodingType: .jpeg,
        saveToGallery: false,
        cameraDirection: .back,
        allowEdit: false,
        returnMetadata: false
    )
    static let pngEncodingType = try? IONCAMRTakePhotoOptions(
        quality: 100,
        correctOrientation: true,
        encodingType: .png,
        saveToGallery: false,
        cameraDirection: .back,
        allowEdit: false,
        returnMetadata: false
    )
    static let backCamera = try? IONCAMRTakePhotoOptions(
        quality: 100,
        correctOrientation: true,
        encodingType: .jpeg,
        saveToGallery: false,
        cameraDirection: .back,
        allowEdit: false,
        returnMetadata: false
    )
    static let frontCamera = try? IONCAMRTakePhotoOptions(
        quality: 100,
        correctOrientation: true,
        encodingType: .jpeg,
        saveToGallery: false,
        cameraDirection: .front,
        allowEdit: false,
        returnMetadata: false
    )
    static let allowEdit = try? IONCAMRTakePhotoOptions(
        quality: 100,
        correctOrientation: true,
        encodingType: .jpeg,
        saveToGallery: false,
        cameraDirection: .back,
        allowEdit: true,
        returnMetadata: false
    )
    static let saveToPhotosAlbum = try? IONCAMRTakePhotoOptions(
        quality: 100,
        correctOrientation: false,
        encodingType: .jpeg,
        saveToGallery: true,
        cameraDirection: .front,
        allowEdit: false,
        returnMetadata: false
    )
    static let qualityUnder0 = try? IONCAMRTakePhotoOptions(
        quality: -1,
        correctOrientation: false,
        encodingType: .jpeg,
        saveToGallery: false,
        cameraDirection: .back,
        allowEdit: false,
        returnMetadata: false
    )
    static let qualityOver100 = try? IONCAMRTakePhotoOptions(
        quality: 101,
        correctOrientation: false,
        encodingType: .jpeg,
        saveToGallery: false,
        cameraDirection: .back,
        allowEdit: false,
        returnMetadata: false
    )
    static let sizeSet = try? IONCAMRTakePhotoOptions(
        quality: 50,
        size: IONCAMRSizeConfigurations.sizeSet,
        correctOrientation: false,
        encodingType: .jpeg,
        saveToGallery: false,
        cameraDirection: .back,
        allowEdit: false,
        returnMetadata: false
    )
    static let allowEditLatestVersion = try? IONCAMRTakePhotoOptions(
        quality: 100,
        correctOrientation: true,
        encodingType: .jpeg,
        saveToGallery: false,
        cameraDirection: .back,
        allowEdit: true,
        returnMetadata: false
    )
    static let allowEditLatestVersionWithMetadata = try? IONCAMRTakePhotoOptions(
        quality: 100,
        correctOrientation: true,
        encodingType: .jpeg,
        saveToGallery: false,
        cameraDirection: .back,
        allowEdit: true,
        returnMetadata: true
    )
    static let noEditEncodingTypeLatestVersion = try? IONCAMRTakePhotoOptions(
        quality: 100,
        correctOrientation: true,
        encodingType: .jpeg,
        saveToGallery: false,
        cameraDirection: .back,
        allowEdit: false,
        returnMetadata: false
    )
    static let noEditLatestVersionWithMetadata = try? IONCAMRTakePhotoOptions(
        quality: 100,
        correctOrientation: true,
        encodingType: .jpeg,
        saveToGallery: false,
        cameraDirection: .back,
        allowEdit: false,
        returnMetadata: true
    )
    static let allowEditAndSaveToPhotoAlbum = try? IONCAMRTakePhotoOptions(
        quality: 100, correctOrientation: true, encodingType: .jpeg, saveToGallery: true, cameraDirection: .back, allowEdit: true, returnMetadata: false
    )
}

struct IONCAMRRecordVideoOptionsConfigurations {
    static let video = IONCAMRRecordVideoOptions(saveToGallery: false, returnMetadata: false, isPersistent: true)
    static let saveToPhotosAlbum = IONCAMRRecordVideoOptions(saveToGallery: true, returnMetadata: false, isPersistent: true)
    static let withMetadata = IONCAMRRecordVideoOptions(saveToGallery: false, returnMetadata: true, isPersistent: true)
    static let videoTemporary = IONCAMRRecordVideoOptions(saveToGallery: false, returnMetadata: false, isPersistent: false)
    static let saveToPhotosAlbumTemporary = IONCAMRRecordVideoOptions(saveToGallery: true, returnMetadata: false, isPersistent: false)
}

struct IONCAMREditOptionsConfigurations {
    static func noSaveNorMetadata(uri: String = "") -> IONCAMRPhotoEditOptions {
        IONCAMRPhotoEditOptions(uri: uri, saveToGallery: false, returnMetadata: false)
    }
    static func saveWithoutMetadata(uri: String = "") -> IONCAMRPhotoEditOptions {
        IONCAMRPhotoEditOptions(uri: uri, saveToGallery: true, returnMetadata: false)
    }
    static func metadataWithoutSave(uri: String = "") -> IONCAMRPhotoEditOptions {
        IONCAMRPhotoEditOptions(uri: uri, saveToGallery: false, returnMetadata: true)
    }
}

struct IONCAMRSizeConfigurations {
    static let sizeSet = try? IONCAMRSize(width: 50, height: 150)
}

struct UIViewControllerConfigurations {
    static let `default` = UIViewController()
    static let takeMedia = UIViewController()
    static let editPicture = UIViewController()
    static let chooseFromGallery = UIViewController()
}

class IONCAMRPictureMock {
    let image: UIImage
    let url: URL
    let thumbnail: String
    let metadata: IONCAMRMetadata?

    init(image: UIImage, url: URL, thumbnail: String, metadata: IONCAMRMetadata) {
        self.image = image
        self.url = url
        self.thumbnail = thumbnail
        self.metadata = metadata
    }

    static let osLogo = IONCAMRPictureMock(
        image: UIImage(named: "outsystems_logo", in: .module, compatibleWith: nil)!,
        url: URL(string: "oslogo_picture.jpeg")!,
        thumbnail: "oslogo_picture_thumbnail",
        metadata: IONCAMRMetadataOptions.photoMetadata
    )
    static let osLogoBlue = IONCAMRPictureMock(
        image: UIImage(named: "outsystems_logo_blue", in: .module, compatibleWith: nil)!,
        url: URL(string: "oslogoblue_picture.jpeg")!,
        thumbnail: "oslogoblue_picture_thumbnail",
        metadata: IONCAMRMetadataOptions.photoMetadata
    )
    static let osLogoRotated = IONCAMRPictureMock(
        image: UIImage(named: "outsystems_logo_rotated", in: .module, compatibleWith: nil)!,
        url: URL(string: "oslogorotated_picture.jpeg")!,
        thumbnail: "oslogorotated_picture_thumbnail",
        metadata: IONCAMRMetadataOptions.photoMetadata
    )

    var toMediaResult: IONCAMRMediaResult { .init(pictureWith: self.url.absoluteString, self.thumbnail) }
    var toMediaResultWithMetadata: IONCAMRMediaResult { .init(pictureWith: self.url.absoluteString, self.thumbnail, and: self.metadata) }
}

struct IONCAMRMetadataOptions {
    static let videoMetadata = IONCAMRMetadata(size: 1200, duration: 20, format: "mp4", resolution: "1920x1080", creationDate: Date())
    static let photoMetadata = IONCAMRMetadata(size: 120, format: "jpeg", resolution: "1920x1080", creationDate: Date())
}

struct IONCAMRVideoMock {
    let url: URL
    let thumbnail: String
    let metadata: IONCAMRMetadata?

    static let first = IONCAMRVideoMock(
        url: URL(string: "saved_first_video_url.mov")!,
        thumbnail: "saved_first_video_thumbnail",
        metadata: IONCAMRMetadataOptions.videoMetadata
    )
    static let second = IONCAMRVideoMock(
        url: URL(string: "saved_second_video_url.mov")!,
        thumbnail: "saved_second_video_thumbnail",
        metadata: IONCAMRMetadataOptions.videoMetadata
    )

    var toMediaResult: IONCAMRMediaResult { .init(videoWith: self.url.absoluteString, self.thumbnail) }
    var toMediaResultWithMetadata: IONCAMRMediaResult { .init(videoWith: self.url.absoluteString, self.thumbnail, and: self.metadata) }
}

class IONCAMRCallbackMock: IONCAMRCallbackDelegate {
    var singleResult: IONCAMRMediaResult?
    var arrayResult: [IONCAMRMediaResult]?
    var error: IONCAMRError?

    func callback(error: IONCAMRError) {
        self.error = error
    }

    func callback(result: IONCAMRMediaResult) {
        self.singleResult = result
    }

    func callback(result: [IONCAMRMediaResult]) {
        self.arrayResult = result
    }
}

class IONCAMRPermissionsBehaviourMock: IONCAMRPermissionsDelegate {
    var coordinator: IONCAMRCoordinator = IONCAMRCoordinatorMock(rootViewController: UIViewControllerConfigurations.default)
    var authorised: Bool = true

    func checkForCamera(_ handler: @escaping (Bool) -> Void) {
        handler(self.authorised)
    }

    func checkForPhotoLibrary(_ handler: @escaping (Bool) -> Void) {
        handler(self.authorised)
    }
}

class IONCAMRMetadataGetterMock: IONCAMRMetadataGetterDelegate {
    func getImageMetadata(from image: UIImage, and url: URL) throws -> IONCAMRMetadata {
        IONCAMRMetadataOptions.photoMetadata
    }

    func getVideoMetadata(from url: URL) async throws -> IONCAMRMetadata {
        IONCAMRMetadataOptions.videoMetadata
    }
}

class IONCAMRFlowBehaviourMock: IONCAMRFlowDelegate {
    var coordinator: IONCAMRCoordinator = IONCAMRCoordinatorMock(rootViewController: UIViewControllerConfigurations.default)
    var delegate: IONCAMRFlowResultsDelegate?
    var temporaryURLArray: [URL] = []
    var triggeredTakePicture: Bool = false
    var triggeredCancelTakePicture: Bool = false

    var triggeredChoosePicture: Bool = false
    var triggeredCancelChoosePicture: Bool = false

    var triggeredCaptureVideo: Bool = false
    var triggeredCancelVideo: Bool = false

    var triggeredChooseMultimedia: Bool = false
    var triggeredCancelChooseMultimedia: Bool = false

    var triggeredEdit: Bool = true
    var error: IONCAMRError?

    func takePhoto(with options: IONCAMRTakePhotoOptions) {
        if self.triggeredCancelTakePicture {
            self.delegate?.didCancel(.takePictureCancel)
        } else if self.triggeredTakePicture {
            if let error = error {
                self.delegate?.didFailed(type: IONCAMRMediaResult.self, with: error)
            } else {
                let mediaResult = IONCAMRMediaResult(pictureWith: IONCAMRPictureMock.osLogo.image.toData(with: options)!.base64EncodedString())
                self.delegate?.didSucceed(with: mediaResult)
            }
        }
    }

    func recordVideo(with options: IONCAMRRecordVideoOptions) {
        if self.triggeredCancelVideo {
            self.delegate?.didCancel(.captureVideoCancel)
        } else if self.triggeredCaptureVideo {
            if let error = error {
                self.delegate?.didFailed(type: IONCAMRMediaResult.self, with: error)
            } else {
                let video = IONCAMRVideoMock.first
                self.temporaryURLArray += [video.url]
                let mediaResult = options.returnMetadata ? video.toMediaResultWithMetadata : video.toMediaResult
                self.delegate?.didSucceed(with: mediaResult)
            }
        }
    }

    func editPhoto(_ image: UIImage) {
        if self.triggeredEdit {
            if let error = self.error {
                self.delegate?.didFailed(type: IONCAMRMediaResult.self, with: error)
            } else {
                let mediaResult = IONCAMRMediaResult(pictureWith: IONCAMRPictureMock.osLogoBlue.image.toData()!.base64EncodedString())
                self.delegate?.didSucceed(with: mediaResult)
            }
        } else {
            self.delegate?.didCancel(.editPictureCancel)
        }
    }

    func editPhoto(with options: IONCAMRPhotoEditOptions) {
        if self.triggeredEdit {
            if let error = self.error {
                self.delegate?.didFailed(type: IONCAMRMediaResult.self, with: error)
            } else {
                let pictureToReturn = IONCAMRPictureMock.osLogoBlue
                self.delegate?.didSucceed(with: options.returnMetadata ? pictureToReturn.toMediaResultWithMetadata : pictureToReturn.toMediaResult)
            }
        } else {
            self.delegate?.didCancel(.editPictureCancel)
        }
    }

    func chooseFromGallery(with options: IONCAMRGalleryOptions) {
        if self.triggeredCancelChoosePicture {
            self.delegate?.didCancel(.choosePictureCancel)
        } else if self.triggeredCancelChooseMultimedia {
            self.delegate?.didCancel(.chooseMultimediaCancel)
        } else if self.triggeredChoosePicture {
            if let error = self.error {
                self.delegate?.didFailed(type: IONCAMRMediaResult.self, with: error)
            } else {
                let mediaResult = IONCAMRMediaResult(pictureWith: IONCAMRPictureMock.osLogo.image.toData()!.base64EncodedString())
                self.delegate?.didSucceed(with: mediaResult)
            }
        } else if self.triggeredChooseMultimedia {
            if let error = self.error {
                self.delegate?.didFailed(type: [IONCAMRMediaResult].self, with: error)
            } else {
                let mediaArray: [IONCAMRMediaResult]
                switch options.mediaType {
                case .picture:
                    if options.returnMetadata {
                        mediaArray = [IONCAMRPictureMock.osLogo.toMediaResultWithMetadata, IONCAMRPictureMock.osLogoRotated.toMediaResultWithMetadata]
                    } else {
                        mediaArray = [IONCAMRPictureMock.osLogo.toMediaResult, IONCAMRPictureMock.osLogoRotated.toMediaResult]
                    }
                case .video:
                    if options.returnMetadata {
                        mediaArray = [IONCAMRVideoMock.first.toMediaResultWithMetadata, IONCAMRVideoMock.second.toMediaResultWithMetadata]
                    } else {
                        mediaArray = [IONCAMRVideoMock.first.toMediaResultWithMetadata, IONCAMRVideoMock.second.toMediaResultWithMetadata]
                    }
                case .both:
                    if options.returnMetadata {
                        mediaArray = [IONCAMRPictureMock.osLogo.toMediaResultWithMetadata, IONCAMRVideoMock.first.toMediaResultWithMetadata]
                    } else {
                        mediaArray = [IONCAMRPictureMock.osLogo.toMediaResult, IONCAMRVideoMock.first.toMediaResult]
                    }

                default: mediaArray = []
                }

                self.delegate?.didSucceed(with: mediaArray)
            }
        }
    }

    func cleanTemporaryFiles() {
        self.temporaryURLArray.removeAll()
    }
}

class IONCAMRPickerBehaviourMock: IONCAMRPickerDelegate {
    weak var delegate: IONCAMRPickerResultsDelegate?
    var cameraAvailable: Bool = true

    func isCameraAvailable() -> Bool {
        self.cameraAvailable
    }

    func captureMedia(with options: IONCAMRMediaOptions, _ handler: @escaping (UIViewController) -> Void) {
        handler(UIViewControllerConfigurations.takeMedia)
    }

    // MARK: Take Picture Handlers
    func takePictureHandler(with success: Bool = true, and error: IONCAMRError? = nil) {
        if success {
            if let error = error {
                self.delegate?.didReturn(self, with: .failure(error))
            } else {
                self.delegate?.didReturn(self, with: .success(.picture(IONCAMRPictureMock.osLogo.image)))
            }
        } else {
            self.delegate?.didCancel(self)
        }
    }

    func didCancelTakePicture() {
        self.takePictureHandler(with: false, and: nil)
    }

    func didEndTakePictureHandler(with error: IONCAMRError) {
        self.takePictureHandler(with: true, and: error)
    }

    func didEndSuccessfullyTakePictureHandler() {
        self.takePictureHandler(with: true, and: nil)
    }

    // MARK: Capture Video Handlers
    func captureVideoHandler(with success: Bool = true, and error: IONCAMRError? = nil) {
        if success {
            if let error = error {
                self.delegate?.didReturn(self, with: .failure(error))
            } else {
                self.delegate?.didReturn(self, with: .success(.video(IONCAMRVideoMock.first.url)))
            }
        } else {
            self.delegate?.didCancel(self)
        }
    }

    func didCancelCaptureVideo() {
        self.captureVideoHandler(with: false, and: nil)
    }

    func didEndCaptureVideoHandler(with error: IONCAMRError) {
        self.captureVideoHandler(with: true, and: error)
    }

    func didEndSuccessfullyCaptureVideoHandler() {
        self.captureVideoHandler(with: true, and: nil)
    }
}

class IONCAMRGalleryBehaviourMock: IONCAMRGalleryDelegate {
    func saveToGallery(_ image: UIImage) async -> Bool {
        return true
    }
    
    func saveToGallery(_ fileURL: URL) async -> Bool {
        return true
    }
    
    weak var delegate: IONCAMRGalleryResultsDelegate?
    var pleaseSave: Bool = true
    var isSaved: Bool = false
    var photoLibraryAvailable: Bool = true
    var returnMetadata: Bool = false

    func saveToGallery(_ image: UIImage) {
        self.isSaved = true
    }

    func saveToGallery(_ fileURL: URL) {
        self.isSaved = true
    }

    func chooseFromGallery(with options: IONCAMRGalleryOptions, _ handler: @escaping (UIViewController) -> Void) {
        self.returnMetadata = options.returnMetadata
        handler(UIViewControllerConfigurations.chooseFromGallery)
    }

    private func choosePictureHandler(with success: Bool, and error: IONCAMRError?) {
        if success {
            if let error = error {
                self.delegate?.didReturn(self, with: .failure(error))
            } else {
                self.delegate?.didReturn(self, with: .success(.picture(IONCAMRPictureMock.osLogo.image)))
            }
        } else {
            self.delegate?.didCancel(self)
        }
    }

    func didCancelChoosePicture() {
        self.choosePictureHandler(with: false, and: nil)
    }

    func didEndChoosePictureHandler(with error: IONCAMRError) {
        self.choosePictureHandler(with: true, and: error)
    }

    func didEndSuccessfullyChoosePictureHandler() {
        self.choosePictureHandler(with: true, and: nil)
    }

    private func chooseMultimediaHandler(withSuccess success: Bool, error: IONCAMRError?, andResult result: [IONCAMRMediaResult]?) {
        if success {
            if let error = error {
                self.delegate?.didReturn(.failure(error))
            } else if let result = result {
                self.delegate?.didReturn(.success(result))
            }
        } else {
            self.delegate?.didCancel(self)
        }
    }

    func didCancelChooseMultimedia() {
        self.chooseMultimediaHandler(withSuccess: false, error: nil, andResult: nil)
    }

    func didEndChooseMultimediaHandler(with error: IONCAMRError) {
        self.chooseMultimediaHandler(withSuccess: true, error: error, andResult: nil)
    }

    func didEndSuccessfullyChooseSinglePictureHandler() {
        let result: [IONCAMRMediaResult]
        if self.returnMetadata {
            result = [IONCAMRPictureMock.osLogo.toMediaResultWithMetadata]
        } else {
            result = [IONCAMRPictureMock.osLogo.toMediaResult]
        }
        self.chooseMultimediaHandler(withSuccess: true, error: nil, andResult: result)
    }

    func didEndSuccessfullyChooseMultiplePicturesHandler() {
        let result: [IONCAMRMediaResult]
        if self.returnMetadata {
            result = [IONCAMRPictureMock.osLogo.toMediaResultWithMetadata, IONCAMRPictureMock.osLogoRotated.toMediaResultWithMetadata]
        } else {
            result = [IONCAMRPictureMock.osLogo.toMediaResult, IONCAMRPictureMock.osLogoRotated.toMediaResult]
        }
        self.chooseMultimediaHandler(withSuccess: true, error: nil, andResult: result)
    }

    func didEndSuccessfullyChooseSingleVideoHandler() {
        let result: [IONCAMRMediaResult]
        if self.returnMetadata {
            result = [IONCAMRVideoMock.first.toMediaResultWithMetadata]
        } else {
            result = [IONCAMRVideoMock.first.toMediaResult]
        }
        self.chooseMultimediaHandler(withSuccess: true, error: nil, andResult: result)
    }

    func didEndSuccessfullyChooseMultipleVideosHandler() {
        let result: [IONCAMRMediaResult]
        if self.returnMetadata {
            result = [IONCAMRVideoMock.first.toMediaResultWithMetadata, IONCAMRVideoMock.second.toMediaResultWithMetadata]
        } else {
            result = [IONCAMRVideoMock.first.toMediaResult, IONCAMRVideoMock.second.toMediaResult]
        }
        self.chooseMultimediaHandler(withSuccess: true, error: nil, andResult: result)
    }

    func didEndSuccessfullyChoosePictureAndVideoHandler() {
        let result: [IONCAMRMediaResult]
        if self.returnMetadata {
            result = [IONCAMRPictureMock.osLogo.toMediaResultWithMetadata, IONCAMRVideoMock.first.toMediaResultWithMetadata]
        } else {
            result = [IONCAMRPictureMock.osLogo.toMediaResult, IONCAMRVideoMock.first.toMediaResult]
        }
        self.chooseMultimediaHandler(withSuccess: true, error: nil, andResult: result)
    }

    func didEndSuccessfullyWithNoPicturesSelectedHandler() {
        self.chooseMultimediaHandler(withSuccess: true, error: nil, andResult: [])
    }
}

class IONCAMREditorBehaviourMock: IONCAMREditorDelegate {
    weak var delegate: IONCAMREditorResultsDelegate?
    var hasBeenEdited: Bool = false

    func editPicture(_ image: UIImage, _ handler: @escaping (UIViewController) -> Void) {
        hasBeenEdited = true
        handler(UIViewControllerConfigurations.editPicture)
    }

    func editPictureHandler(with success: Bool, and error: IONCAMRError?) {
        if success {
            if let error = error {
                self.delegate?.didReturn(self, with: .failure(error))
            } else {
                self.delegate?.didReturn(self, with: .success(.picture(IONCAMRPictureMock.osLogoBlue.image)))
            }
        } else {
            self.delegate?.didCancel(self)
        }
    }

    func didCancelEditPicture() {
        self.editPictureHandler(with: false, and: nil)
    }

    func didEndEditPictureHandler(with error: IONCAMRError) {
        self.editPictureHandler(with: true, and: error)
    }

    func didEndSuccessfullyEditPictureHandler() {
        self.editPictureHandler(with: true, and: nil)
    }
}

class IONCAMRCoordinatorMock: IONCAMRCoordinator {
    var hasTwoSteps: Bool = false

    override var isSecondStep: Bool { self.hasTwoSteps }
    override func present(_ viewController: UIViewController) {}
    override func dismiss() {}
}

class MirrorObject {
    let mirror: Mirror

    init(reflecting: Any) {
        mirror = Mirror(reflecting: reflecting)
    }

    func extract<T>(variableName: StaticString = #function) -> T? {
        extract(variableName: variableName, mirror: mirror)
    }

    private func extract<T>(variableName: StaticString, mirror: Mirror?) -> T? {
        guard let mirror = mirror else {
            return nil
        }

        guard let descendant = mirror.descendant("\(variableName)") as? T else {
            return extract(variableName: variableName, mirror: mirror.superclassMirror)
        }

        return descendant
    }
}

final class IONCAMRCoordinatorMirror: MirrorObject {
    init(coordinator: IONCAMRCoordinator) {
        super.init(reflecting: coordinator)
    }

    var rootViewController: UIViewController? {
        extract()
    }

    var currentlyPresentedViewControllerArray: [UIViewController]? {
        extract()
    }

    var screenViewController: UIViewController? {
        self.currentlyPresentedViewControllerArray?.last ?? self.rootViewController
    }
}

final class IONCAMRThumbnailGeneratorMock: IONCAMRThumbnailGeneratorDelegate {
    var thumbnail: UIImage?
    var imageMap: [UIImage: String] {
        [
            IONCAMRPictureMock.osLogo.image: IONCAMRPictureMock.osLogo.thumbnail,
            IONCAMRPictureMock.osLogoBlue.image: IONCAMRPictureMock.osLogoBlue.thumbnail,
            IONCAMRPictureMock.osLogoRotated.image: IONCAMRPictureMock.osLogoRotated.thumbnail
        ]
    }

    func getImage(from videoURL: URL, _ completion: @escaping (UIImage?) -> Void) { completion(thumbnail) }
    func getBase64String(from image: UIImage, with size: IONCAMRSize?, and quality: Int?) -> String? { imageMap[image] }
}

final class IONCAMRPlayerBehaviourMock: IONCAMRPlayerDelegate {
    enum MockBehaviourError: Error {
        case videoCantBePlayed
    }

    var isVideoPlayable = true

    func playVideo(_ url: URL) async throws {
        if self.isVideoPlayable {
            print("Video playing...")
        } else {
            throw MockBehaviourError.videoCantBePlayed
        }
    }
}

final class IONCAMRImageFetcherBehaviourMock: IONCAMRImageFetcherDelegate {
    var callShouldSucceed: Bool = true
    var urlMap: [String: UIImage] {
        [
            IONCAMRPictureMock.osLogo.url.absoluteString: IONCAMRPictureMock.osLogo.image,
            IONCAMRPictureMock.osLogoBlue.url.absoluteString: IONCAMRPictureMock.osLogoBlue.image,
            IONCAMRPictureMock.osLogoRotated.url.absoluteString: IONCAMRPictureMock.osLogoRotated.image
        ]
    }

    func retrieveImage(from urlString: String) -> UIImage? { callShouldSucceed ? urlMap[urlString] : nil }
}

final class IONCAMRURLGeneratorMock: IONCAMRURLGeneratorDelegate {
    var urlToReturn: URL?

    func url(for imageData: Data, withEncodingType encodingType: IONCAMREncodingType?) -> URL? {
        urlToReturn
    }
}
