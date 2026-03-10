import XCTest
@testable import OSCameraLib

final class IONCAMRFlowTests: XCTestCase {
    private var singleResult: IONCAMRMediaResult?
    private var multipleResult: [IONCAMRMediaResult]?
    private var error: IONCAMRError?
    private var cancel: Bool = false

    private var mockPicker: IONCAMRPickerBehaviourMock!
    private var mockMetadata: IONCAMRMetadataGetterMock!
    private var mockGallery: IONCAMRGalleryBehaviourMock!
    private var mockEditor: IONCAMREditorBehaviourMock!
    private var mockCoordinator: IONCAMRCoordinatorMock!
    private var mockPermissions: IONCAMRPermissionsBehaviourMock!
    private var mockThumbnailGenerator: IONCAMRThumbnailGeneratorMock!
    private var mockImageFetcher: IONCAMRImageFetcherBehaviourMock!
    private var mockURLGenerator: IONCAMRURLGeneratorMock!

    var sut: IONCAMRFlowBehaviour!

    override func setUp() {
        mockPicker = IONCAMRPickerBehaviourMock()
        mockMetadata = IONCAMRMetadataGetterMock()
        mockGallery = IONCAMRGalleryBehaviourMock()
        mockEditor = IONCAMREditorBehaviourMock()
        mockCoordinator = IONCAMRCoordinatorMock(rootViewController: UIViewControllerConfigurations.default)
        mockPermissions = IONCAMRPermissionsBehaviourMock()
        mockThumbnailGenerator = IONCAMRThumbnailGeneratorMock()
        mockImageFetcher = IONCAMRImageFetcherBehaviourMock()
        mockURLGenerator = IONCAMRURLGeneratorMock()

        sut = IONCAMRFlowBehaviour(
            picker: mockPicker,
            editorBehaviour: mockEditor,
            galleryBehaviour: mockGallery,
            permissionsBehaviour: mockPermissions,
            thumbnailGenerator: mockThumbnailGenerator,
            metadataGetter: mockMetadata,
            imageFetcher: mockImageFetcher,
            urlGenerator: mockURLGenerator,
            coordinator: mockCoordinator
        )
        sut.delegate = self
    }

    override func tearDownWithError() throws {
        sut = nil

        mockURLGenerator = nil
        mockImageFetcher = nil
        mockThumbnailGenerator = nil
        mockPermissions = nil
        mockCoordinator = nil
        mockEditor = nil
        mockGallery = nil
        mockMetadata = nil
        mockPicker = nil
    }
}

// MARK: - Take Picture Tests
extension IONCAMRFlowTests {
    func test_takePicture_butNoCameraAvailable_returnError() {
        mockPicker.cameraAvailable = false

        sut.captureMedia(with: IONCAMRPictureOptionsConfigurations.jpegEncodingType!)

        XCTAssertNil(singleResult)
        XCTAssertEqual(error, .cameraAvailability)
    }

    func test_takePicture_butNoCameraAccess_returnError() {
        mockPermissions.authorised = false

        sut.captureMedia(with: IONCAMRPictureOptionsConfigurations.jpegEncodingType!)

        XCTAssertNil(singleResult)
        XCTAssertEqual(error, .cameraAccess)
    }

    func test_takePicture_butErrorOccurred_returnError() {
        let pickerError = IONCAMRError.takePictureIssue

        sut.captureMedia(with: IONCAMRPictureOptionsConfigurations.allowEdit!)
        mockPicker.didEndTakePictureHandler(with: pickerError)

        XCTAssertNil(singleResult)
        XCTAssertEqual(error, pickerError)
    }

    func test_takePicture_butCancels_delegatesToDidCancel() {
        sut.captureMedia(with: IONCAMRPictureOptionsConfigurations.jpegEncodingType!)
        mockPicker.didCancelTakePicture()

        XCTAssertNil(singleResult)
        XCTAssertNil(error)
        XCTAssertTrue(cancel)
    }

    func test_takePicture_withAllowEditEnabled_butErrorOccurred_returnError() {
        let editorError = IONCAMRError.editPictureIssue

        sut.captureMedia(with: IONCAMRPictureOptionsConfigurations.allowEdit!)
        mockPicker.didEndSuccessfullyTakePictureHandler()
        mockEditor.didEndEditPictureHandler(with: editorError)

        XCTAssertNil(singleResult)
        XCTAssertEqual(error, editorError)
    }

    func test_takePicture_withAllowEditEnabled_butCancels_delegatesToDidCancel() {
        sut.captureMedia(with: IONCAMRPictureOptionsConfigurations.allowEdit!)
        mockPicker.didEndSuccessfullyTakePictureHandler()
        mockEditor.didCancelEditPicture()

        XCTAssertNil(singleResult)
        XCTAssertNil(error)
        XCTAssertTrue(cancel)
    }

    func test_takePicture_oldVersion_withAllowEditEnabled_isSuccessful_returnEditedImage() {
        let options = IONCAMRPictureOptionsConfigurations.allowEdit!
        mockCoordinator.hasTwoSteps = true

        sut.captureMedia(with: options)
        mockPicker.didEndSuccessfullyTakePictureHandler()
        mockEditor.didEndSuccessfullyEditPictureHandler()

        XCTAssertEqual(singleResult?.thumbnail, IONCAMRPictureMock.osLogoBlue.image.toData(with: options)?.base64EncodedString())
        XCTAssertEqual(singleResult?.uri, "")
        XCTAssertNil(singleResult?.metadata)
        XCTAssertNil(error)
        XCTAssertFalse(mockGallery.isSaved)
    }

    func test_takePicture_oldVersion_withAllowEditEnabled_isSuccessful_andSavedIntoPhotoLibrary_returnEditedImage() {
        let options = IONCAMRPictureOptionsConfigurations.allowEditAndSaveToPhotoAlbum!
        mockCoordinator.hasTwoSteps = true

        sut.captureMedia(with: options)
        mockPicker.didEndSuccessfullyTakePictureHandler()
        mockEditor.didEndSuccessfullyEditPictureHandler()

        XCTAssertEqual(singleResult?.thumbnail, IONCAMRPictureMock.osLogoBlue.image.toData(with: options)?.base64EncodedString())
        XCTAssertEqual(singleResult?.uri, "")
        XCTAssertNil(singleResult?.metadata)
        XCTAssertNil(error)
        XCTAssertTrue(mockGallery.isSaved)
    }

    func test_takePicture_newVersion_withAllowEditEnabled_isSuccessful_returnEditedImage() {
        let options = IONCAMRPictureOptionsConfigurations.allowEditLatestVersion!
        mockCoordinator.hasTwoSteps = true
        mockURLGenerator.urlToReturn = IONCAMRPictureMock.osLogoBlue.url

        sut.captureMedia(with: options)
        mockPicker.didEndSuccessfullyTakePictureHandler()
        mockEditor.didEndSuccessfullyEditPictureHandler()

        XCTAssertEqual(singleResult, IONCAMRPictureMock.osLogoBlue.toMediaResult)
        XCTAssertNil(error)
        XCTAssertEqual(sut.temporaryURLArray.map(\.absoluteString), [singleResult!.uri])
    }

    func test_takePicture_newVersion_withAllowEditEnabled_isSuccessful_returnEditedImageWithMetadata() {
        let options = IONCAMRPictureOptionsConfigurations.allowEditLatestVersionWithMetadata!
        mockCoordinator.hasTwoSteps = true
        mockURLGenerator.urlToReturn = IONCAMRPictureMock.osLogoBlue.url

        sut.captureMedia(with: options)
        mockPicker.didEndSuccessfullyTakePictureHandler()
        mockEditor.didEndSuccessfullyEditPictureHandler()

        XCTAssertEqual(singleResult, IONCAMRPictureMock.osLogoBlue.toMediaResultWithMetadata)
        XCTAssertNil(error)
        XCTAssertEqual(sut.temporaryURLArray.map(\.absoluteString), [singleResult!.uri])
    }

    func test_takePicture_oldVersion_isSuccessful_returnImage() {
        let options = IONCAMRPictureOptionsConfigurations.jpegEncodingType!

        sut.captureMedia(with: options)
        mockPicker.didEndSuccessfullyTakePictureHandler()

        XCTAssertEqual(singleResult?.thumbnail, IONCAMRPictureMock.osLogo.image.toData(with: options)?.base64EncodedString())
        XCTAssertEqual(singleResult?.uri, "")
        XCTAssertNil(singleResult?.metadata)
        XCTAssertNil(error)
        XCTAssertFalse(mockGallery.isSaved)
    }

    func test_takePicture_oldVersion_isSuccessful_andSavedIntoPhotoLibrary_returnImage() {
        mockGallery.pleaseSave = true
        let options = IONCAMRPictureOptionsConfigurations.saveToPhotosAlbum!

        sut.captureMedia(with: options)
        mockPicker.didEndSuccessfullyTakePictureHandler()

        XCTAssertEqual(singleResult?.thumbnail, IONCAMRPictureMock.osLogo.image.toData(with: options)?.base64EncodedString())
        XCTAssertEqual(singleResult?.uri, "")
        XCTAssertNil(singleResult?.metadata)
        XCTAssertNil(error)
        XCTAssertTrue(mockGallery.isSaved)
    }

    func test_takePicture_newVersion_isSuccessful_returnImage() {
        let options = IONCAMRPictureOptionsConfigurations.noEditEncodingTypeLatestVersion!
        mockURLGenerator.urlToReturn = IONCAMRPictureMock.osLogo.url

        sut.captureMedia(with: options)
        mockPicker.didEndSuccessfullyTakePictureHandler()

        XCTAssertEqual(singleResult, IONCAMRPictureMock.osLogo.toMediaResult)
        XCTAssertNil(error)
        XCTAssertEqual(sut.temporaryURLArray.map(\.absoluteString), [singleResult!.uri])
    }

    func test_takePicture_newVersion_isSuccessful_returnImageWithMetadata() {
        let options = IONCAMRPictureOptionsConfigurations.noEditLatestVersionWithMetadata!
        mockURLGenerator.urlToReturn = IONCAMRPictureMock.osLogo.url

        sut.captureMedia(with: options)
        mockPicker.didEndSuccessfullyTakePictureHandler()

        XCTAssertEqual(singleResult, IONCAMRPictureMock.osLogo.toMediaResultWithMetadata)
        XCTAssertNil(error)
        XCTAssertEqual(sut.temporaryURLArray.map(\.absoluteString), [singleResult!.uri])
    }
}

// MARK: - Edit Picture Tests
extension IONCAMRFlowTests {
    func test_editPicture_butErrorOccurs_returnError() {
        let editorError = IONCAMRError.editPictureIssue

        sut.editPicture(IONCAMRPictureMock.osLogo.image)
        mockEditor.didEndEditPictureHandler(with: editorError)

        XCTAssertNil(singleResult)
        XCTAssertEqual(error, editorError)
    }

    func test_editPicture_butCancels_delegatesToDidCancel() {
        sut.editPicture(IONCAMRPictureMock.osLogo.image)
        mockEditor.didCancelEditPicture()

        XCTAssertNil(singleResult)
        XCTAssertNil(error)
        XCTAssertTrue(cancel)
    }

    func test_editPicture_isSuccessful_returnImage() {
        sut.editPicture(IONCAMRPictureMock.osLogo.image)
        mockEditor.didEndSuccessfullyEditPictureHandler()

        XCTAssertEqual(singleResult?.thumbnail, IONCAMRPictureMock.osLogoBlue.image.toData()?.base64EncodedString())
        XCTAssertNil(error)
        XCTAssertFalse(mockGallery.isSaved)
    }
}

// MARK: - Choose a Picture Tests
extension IONCAMRFlowTests {
    func test_choosePicture_butNoAccessToPhotoLibrary_returnError() {
        mockPermissions.authorised = false

        sut.choosePicture(allowEdit: false)

        XCTAssertNil(singleResult)
        XCTAssertEqual(error, .photoLibraryAccess)
    }

    func test_choosePicture_butErrorOccured_returnError() {
        let galleryError = IONCAMRError.choosePictureIssue

        sut.choosePicture(allowEdit: false)
        mockGallery.didEndChoosePictureHandler(with: galleryError)

        XCTAssertNil(singleResult)
        XCTAssertEqual(error, galleryError)
    }

    func test_choosePicture_butCancels_delegatesToDidCancel() {
        sut.choosePicture(allowEdit: false)
        mockGallery.didCancelChoosePicture()

        XCTAssertNil(singleResult)
        XCTAssertNil(error)
        XCTAssertTrue(cancel)
    }

    func test_choosePicture_withAllowEditEnabled_butErrorOccured_returnError() {
        let editorError = IONCAMRError.editPictureIssue

        sut.choosePicture(allowEdit: true)
        mockGallery.didEndSuccessfullyChoosePictureHandler()
        mockEditor.didEndEditPictureHandler(with: editorError)

        XCTAssertNil(singleResult)
        XCTAssertEqual(error, editorError)
    }

    func test_choosePicture_withAllowEditEnabled_butCancels_delegatesToDidCancel() {
        sut.choosePicture(allowEdit: true)
        mockGallery.didEndSuccessfullyChoosePictureHandler()
        mockEditor.didCancelEditPicture()

        XCTAssertNil(singleResult)
        XCTAssertNil(error)
        XCTAssertTrue(cancel)
    }

    func test_choosePicture_withAllowEditEnabled_isSuccessful_returnImage() {
        mockCoordinator.hasTwoSteps = true

        sut.choosePicture(allowEdit: true)
        mockGallery.didEndSuccessfullyChoosePictureHandler()
        mockEditor.didEndSuccessfullyEditPictureHandler()

        XCTAssertEqual(singleResult?.thumbnail, IONCAMRPictureMock.osLogoBlue.image.toData()?.base64EncodedString())
        XCTAssertNil(error)
    }

    func test_choosePicture_isSuccessful_returnImage() {
        sut.choosePicture(allowEdit: false)
        mockGallery.didEndSuccessfullyChoosePictureHandler()

        XCTAssertEqual(singleResult?.thumbnail, IONCAMRPictureMock.osLogo.image.toData()?.base64EncodedString())
        XCTAssertNil(error)
    }
}

// MARK: - Capture Video Tests
extension IONCAMRFlowTests {
    func test_captureVideo_butNoCameraAvailable_returnError() {
        mockPicker.cameraAvailable = false

        sut.captureMedia(with: IONCAMRRecordVideoOptionsConfigurations.video)

        XCTAssertNil(singleResult)
        XCTAssertEqual(error, .cameraAvailability)
    }

    func test_captureVideo_butNoCameraAccess_returnError() {
        mockPermissions.authorised = false

        sut.captureMedia(with: IONCAMRRecordVideoOptionsConfigurations.video)

        XCTAssertNil(singleResult)
        XCTAssertEqual(error, .cameraAccess)
    }

    func test_captureVideo_butErrorOccured_returnError() {
        let pickerError = IONCAMRError.captureVideoIssue

        sut.captureMedia(with: IONCAMRRecordVideoOptionsConfigurations.video)
        mockPicker.didEndCaptureVideoHandler(with: pickerError)

        XCTAssertNil(singleResult)
        XCTAssertEqual(error, pickerError)
    }

    func test_captureVideo_butCancels_delegatesToDidCancel() {
        sut.captureMedia(with: IONCAMRRecordVideoOptionsConfigurations.video)
        mockPicker.didCancelCaptureVideo()

        XCTAssertNil(singleResult)
        XCTAssertNil(error)
        XCTAssertTrue(cancel)
    }

    func test_captureVideo_isSuccessful_andSaveToPhotoAlbumIsDisabled_returnVideoURLandThumbnail() {
        let videoURL = IONCAMRVideoMock.first.url
        mockThumbnailGenerator.thumbnail = IONCAMRPictureMock.osLogo.image

        sut.captureMedia(with: IONCAMRRecordVideoOptionsConfigurations.videoTemporary)
        mockPicker.didEndSuccessfullyCaptureVideoHandler()

        XCTAssertEqual(singleResult?.type, .video)
        XCTAssertEqual(singleResult?.uri, videoURL.absoluteString)
        XCTAssertEqual(singleResult?.thumbnail, mockThumbnailGenerator.thumbnail?.defaultVideoThumbnailData)
        XCTAssertNil(error)
        XCTAssertEqual(sut.temporaryURLArray, [videoURL])
        XCTAssertFalse(mockGallery.isSaved)
    }

    func test_captureVideo_isSuccessful_andSaveToPhotoAlbumIsDisabled_whenTemporaryFilesAreCleaned_temporaryFilesArrayGoesEmpty() {
        mockThumbnailGenerator.thumbnail = IONCAMRPictureMock.osLogo.image

        sut.captureMedia(with: IONCAMRRecordVideoOptionsConfigurations.video)
        mockPicker.didEndSuccessfullyCaptureVideoHandler()

        sut.cleanTemporaryFiles()

        XCTAssertTrue(sut.temporaryURLArray.isEmpty)
    }

    func test_captureVideo_isSuccessful_andSaveToPhotoAlbumIsEnabled_videoIsSavedIntoPhotoGallery() {
        let videoURL = IONCAMRVideoMock.first.url
        mockGallery.pleaseSave = true
        mockThumbnailGenerator.thumbnail = IONCAMRPictureMock.osLogoRotated.image

        sut.captureMedia(with: IONCAMRRecordVideoOptionsConfigurations.saveToPhotosAlbumTemporary)
        mockPicker.didEndSuccessfullyCaptureVideoHandler()

        XCTAssertEqual(singleResult?.type, .video)
        XCTAssertEqual(singleResult?.uri, videoURL.absoluteString)
        XCTAssertEqual(singleResult?.thumbnail, mockThumbnailGenerator.thumbnail?.defaultVideoThumbnailData)
        XCTAssertNil(error)
        XCTAssertEqual(sut.temporaryURLArray, [videoURL])
        XCTAssertTrue(mockGallery.isSaved)
    }

    func test_captureVideo_isSuccessful_andSaveToPhotoAlbumIsDisabled_andIsPersistent_returnVideoURLandThumbnail() {
        let videoURL = OSCAMRVideoMock.first.url
        mockThumbnailGenerator.thumbnail = OSCAMRPictureMock.osLogo.image

        sut.captureMedia(with: OSCAMRVideoOptionsConfigurations.video)
        mockPicker.didEndSuccessfullyCaptureVideoHandler()

        XCTAssertEqual(singleResult?.type, .video)
        XCTAssertEqual(singleResult?.uri, videoURL.absoluteString)
        XCTAssertEqual(singleResult?.thumbnail, mockThumbnailGenerator.thumbnail?.defaultVideoThumbnailData)
        XCTAssertNil(error)
        XCTAssertEqual(sut.temporaryURLArray, [])
        XCTAssertFalse(mockGallery.isSaved)
    }

    func test_captureVideo_isSuccessful_andSaveToPhotoAlbumIsEnabled_andIsPersistent_videoIsSavedIntoPhotoGallery() {
        let videoURL = OSCAMRVideoMock.first.url
        mockGallery.pleaseSave = true
        mockThumbnailGenerator.thumbnail = OSCAMRPictureMock.osLogoRotated.image

        sut.captureMedia(with: OSCAMRVideoOptionsConfigurations.saveToPhotosAlbum)
        mockPicker.didEndSuccessfullyCaptureVideoHandler()

        XCTAssertEqual(singleResult?.type, .video)
        XCTAssertEqual(singleResult?.uri, videoURL.absoluteString)
        XCTAssertEqual(singleResult?.thumbnail, mockThumbnailGenerator.thumbnail?.defaultVideoThumbnailData)
        XCTAssertNil(error)
        XCTAssertEqual(sut.temporaryURLArray, [])
        XCTAssertTrue(mockGallery.isSaved)
    }

    func test_captureVideo_isSuccessful_andReturnMetadataIsEnabled_returnVideoWithMetadata() {
        let video = IONCAMRVideoMock.first
        mockThumbnailGenerator.thumbnail = IONCAMRPictureMock.osLogoRotated.image

        sut.captureMedia(with: IONCAMRRecordVideoOptionsConfigurations.withMetadata)
        mockPicker.didEndSuccessfullyCaptureVideoHandler()

        // TODO: This is flaky. It's being done due to multithreading while generating video metadata.
        sleep(1)

        XCTAssertEqual(singleResult?.type, .video)
        XCTAssertEqual(singleResult?.uri, video.url.absoluteString)
        XCTAssertEqual(singleResult?.thumbnail, mockThumbnailGenerator.thumbnail?.defaultVideoThumbnailData)
        XCTAssertEqual(singleResult?.metadata, video.metadata)
        XCTAssertNil(error)
    }
}

// MARK: - Choose Multimedia Tests
extension IONCAMRFlowTests {
    func test_chooseMultimedia_butNoPhotoLibraryAccess_returnError() {
        mockPermissions.authorised = false

        sut.chooseMultimedia(type: .both, allowMultipleSelection: false, returnMetadata: false)

        XCTAssertNil(multipleResult)
        XCTAssertEqual(error, .photoLibraryAccess)
    }

    func test_chooseMultimedia_butAnErrorOccurred_returnError() {
        let galleryError = IONCAMRError.chooseMultimediaIssue

        sut.chooseMultimedia(type: .both, allowMultipleSelection: false, returnMetadata: false)
        mockGallery.didEndChooseMultimediaHandler(with: galleryError)

        XCTAssertNil(multipleResult)
        XCTAssertEqual(error, galleryError)
    }

    func test_chooseMultimedia_butCancels_delegatesToDidCancel() {
        sut.chooseMultimedia(type: .both, allowMultipleSelection: false, returnMetadata: false)
        mockGallery.didCancelChooseMultimedia()

        XCTAssertNil(multipleResult)
        XCTAssertNil(error)
        XCTAssertTrue(cancel)
    }

    func test_chooseMultimedia_aSinglePicture_returnPicture() {
        sut.chooseMultimedia(type: .picture, allowMultipleSelection: false, returnMetadata: false)
        mockGallery.didEndSuccessfullyChooseSinglePictureHandler()

        XCTAssertEqual(multipleResult, [IONCAMRPictureMock.osLogo.toMediaResult])
        XCTAssertNil(error)
    }

    func test_chooseMultimedia_aSinglePicture_withReturnMetadataEnabled_returnPictureWithMetadata() {
        sut.chooseMultimedia(type: .picture, allowMultipleSelection: false, returnMetadata: true)
        mockGallery.didEndSuccessfullyChooseSinglePictureHandler()

        XCTAssertEqual(multipleResult, [IONCAMRPictureMock.osLogo.toMediaResultWithMetadata])
        XCTAssertNil(error)
    }

    func test_chooseMultimedia_multiplePictures_returnPictures() {
        sut.chooseMultimedia(type: .picture, allowMultipleSelection: true, returnMetadata: false)
        mockGallery.didEndSuccessfullyChooseMultiplePicturesHandler()

        XCTAssertEqual(multipleResult, [IONCAMRPictureMock.osLogo.toMediaResult, IONCAMRPictureMock.osLogoRotated.toMediaResult])
        XCTAssertNil(error)
    }

    func test_chooseMultimedia_multiplePictures_withReturnMetadataEnabled_returnPicturesWithMetadata() {
        sut.chooseMultimedia(type: .picture, allowMultipleSelection: false, returnMetadata: true)
        mockGallery.didEndSuccessfullyChooseMultiplePicturesHandler()

        XCTAssertEqual(
            multipleResult, [IONCAMRPictureMock.osLogo.toMediaResultWithMetadata, IONCAMRPictureMock.osLogoRotated.toMediaResultWithMetadata]
        )
        XCTAssertNil(error)
    }

    func test_chooseMultimedia_aSingleVideo_returnVideo() {
        sut.chooseMultimedia(type: .video, allowMultipleSelection: false, returnMetadata: false)
        mockGallery.didEndSuccessfullyChooseSingleVideoHandler()

        XCTAssertEqual(multipleResult, [IONCAMRVideoMock.first.toMediaResult])
        XCTAssertNil(error)
    }

    func test_chooseMultimedia_aSingleVideo_withReturnMetadataEnabled_returnVideoWithMetadata() {
        sut.chooseMultimedia(type: .video, allowMultipleSelection: false, returnMetadata: true)
        mockGallery.didEndSuccessfullyChooseSingleVideoHandler()

        XCTAssertEqual(multipleResult, [IONCAMRVideoMock.first.toMediaResultWithMetadata])
        XCTAssertNil(error)
    }

    func test_chooseMultimedia_multipleVideos_returnVideos() {
        sut.chooseMultimedia(type: .video, allowMultipleSelection: true, returnMetadata: false)
        mockGallery.didEndSuccessfullyChooseMultipleVideosHandler()

        XCTAssertEqual(multipleResult, [IONCAMRVideoMock.first.toMediaResult, IONCAMRVideoMock.second.toMediaResult])
        XCTAssertNil(error)
    }

    func test_chooseMultimedia_multipleVideos_withReturnMetadataEnabled_returnVideosWithMetadata() {
        sut.chooseMultimedia(type: .video, allowMultipleSelection: true, returnMetadata: true)
        mockGallery.didEndSuccessfullyChooseMultipleVideosHandler()

        XCTAssertEqual(multipleResult, [IONCAMRVideoMock.first.toMediaResultWithMetadata, IONCAMRVideoMock.second.toMediaResultWithMetadata])
        XCTAssertNil(error)
    }

    func test_chooseMultimedia_bothPicturesAndVideos_returnAssets() {
        sut.chooseMultimedia(type: .both, allowMultipleSelection: true, returnMetadata: false)
        mockGallery.didEndSuccessfullyChoosePictureAndVideoHandler()

        XCTAssertEqual(multipleResult, [IONCAMRPictureMock.osLogo.toMediaResult, IONCAMRVideoMock.first.toMediaResult])
        XCTAssertNil(error)
    }

    func test_chooseMultimedia_bothPicturesAndVideos_withReturnMetadataEnabled_returnAssets() {
        sut.chooseMultimedia(type: .both, allowMultipleSelection: true, returnMetadata: true)
        mockGallery.didEndSuccessfullyChoosePictureAndVideoHandler()

        XCTAssertEqual(multipleResult, [IONCAMRPictureMock.osLogo.toMediaResultWithMetadata, IONCAMRVideoMock.first.toMediaResultWithMetadata])
        XCTAssertNil(error)
    }
}

extension IONCAMRFlowTests: IONCAMRFlowResultsDelegate {
    func didReturn(_ result: Result<Encodable, IONCAMRError>) {
        self.singleResult = nil
        self.multipleResult = nil
        self.error = nil

        switch result {
        case .success(let value):
            self.singleResult = value as? IONCAMRMediaResult
            self.multipleResult = value as? [IONCAMRMediaResult]
        case .failure(let error):
            self.error = error
        }
    }

    func didCancel(_ error: IONCAMRError) {
        self.cancel = true
        self.singleResult = nil
        self.multipleResult = nil
        self.error = nil
    }
}
