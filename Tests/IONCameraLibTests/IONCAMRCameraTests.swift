import XCTest
@testable import IONCameraLib

extension IONCAMRMediaResult: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let typeInt = try container.decode(Int.self, forKey: .type)
        let type = try IONCAMRMediaType(from: typeInt)

        let uri = try container.decode(String.self, forKey: .uri)
        let thumbnail = try container.decode(String.self, forKey: .thumbnail)
        let metadata = try container.decodeIfPresent(IONCAMRMetadata.self, forKey: .metadata)

        self.init(type: type, uri: uri, thumbnail: thumbnail, metadata: metadata)
    }
}

extension IONCAMRMetadata: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let size = try container.decode(UInt64.self, forKey: .size)
        let duration = try container.decodeIfPresent(Int.self, forKey: .duration)
        let format = try container.decode(String.self, forKey: .format)
        let resolution = try container.decode(String.self, forKey: .resolution)
        let creationDate = try container.decode(Date.self, forKey: .creationDate)

        self.init(size: size, duration: duration, format: format, resolution: resolution, creationDate: creationDate)
    }
}

final class IONCAMRCameraTests: XCTestCase {
    private var mockDelegate: IONCAMRCallbackMock!
    private var mockFlow: IONCAMRFlowBehaviourMock!
    private var mockVideoPlayer: IONCAMRPlayerBehaviourMock!

    private var sut: IONCAMRCameraManager!
    private var editSut: IONCAMREditManager!
    private var gallerySut: IONCAMRGalleryManager!
    private var videoSut: IONCAMRVideoManager!

    override func setUp() {
        mockDelegate = IONCAMRCallbackMock()
        mockFlow = IONCAMRFlowBehaviourMock()
        mockVideoPlayer = IONCAMRPlayerBehaviourMock()

        sut = IONCAMRCameraManager(delegate: mockDelegate, flow: mockFlow)
        editSut = IONCAMREditManager(delegate: mockDelegate, flow: mockFlow)
        gallerySut = IONCAMRGalleryManager(delegate: mockDelegate, flow: mockFlow)
        videoSut = IONCAMRVideoManager(videoPlayer: mockVideoPlayer)
    }

    override func tearDown() {
        videoSut = nil
        gallerySut = nil
        editSut = nil
        sut = nil

        mockDelegate = nil
        mockFlow = nil
        mockVideoPlayer = nil
    }

    // MARK: - Take Picture Tests

    func test_whenUserPressesTakePictureButton_andCancels_returnError() {
        mockFlow.triggeredCancelTakePicture = true

        sut.takePhoto(with: IONCAMRPictureOptionsConfigurations.jpegEncodingType!)

        XCTAssertNil(mockDelegate.singleResult)
        XCTAssertEqual(mockDelegate.error, IONCAMRError.takePictureCancel)
    }

    func test_whenUserPressesTakePictureButton_andSomethingWrongHappens_returnError() {
        mockFlow.triggeredTakePicture = true
        mockFlow.error = .takePictureIssue

        sut.takePhoto(with: IONCAMRPictureOptionsConfigurations.jpegEncodingType!)

        XCTAssertNil(mockDelegate.singleResult)
        XCTAssertEqual(mockDelegate.error, mockFlow.error)
    }

    func test_whenUserPressesTakePictureButton_withSuccess_returnJPEGsBase64String() {
        mockFlow.triggeredTakePicture = true
        let pictureOptions = IONCAMRPictureOptionsConfigurations.jpegEncodingType!

        sut.takePhoto(with: pictureOptions)

        XCTAssertEqual(mockDelegate.singleResult?.thumbnail, IONCAMRPictureMock.osLogo.image.toData(with: pictureOptions)?.base64EncodedString())
        XCTAssertNil(mockDelegate.error)
    }

    func test_whenUserPressesTakePictureButton_withSuccess_returnPNGsBase64String() {
        mockFlow.triggeredTakePicture = true
        let pictureOptions = IONCAMRPictureOptionsConfigurations.pngEncodingType!

        sut.takePhoto(with: pictureOptions)

        XCTAssertEqual(mockDelegate.singleResult?.thumbnail, IONCAMRPictureMock.osLogo.image.toData(with: pictureOptions)?.base64EncodedString())
        XCTAssertNil(mockDelegate.error)
    }

    // MARK: - Edit Picture Tests

    func test_whenUserPressesEditPictureButton_withImage_andCancels_returnError() {
        mockFlow.triggeredEdit = false

        editSut.editPhoto(IONCAMRPictureMock.osLogo.image)

        XCTAssertNil(mockDelegate.singleResult)
        XCTAssertEqual(mockDelegate.error, IONCAMRError.editPictureCancel)
    }

    func test_whenUserPressesEditPictureButton_withImage_andSomethingWrongHappens_returnError() {
        mockFlow.error = .editPictureIssue

        editSut.editPhoto(IONCAMRPictureMock.osLogo.image)

        XCTAssertNil(mockDelegate.singleResult)
        XCTAssertEqual(mockDelegate.error, mockFlow.error)
    }

    func test_whenUserPressesEditPictureButton_withImage_withSuccess_returnsBase64String() {
        editSut.editPhoto(IONCAMRPictureMock.osLogo.image)

        XCTAssertEqual(mockDelegate.singleResult?.thumbnail, IONCAMRPictureMock.osLogoBlue.image.toData()?.base64EncodedString())
        XCTAssertNil(mockDelegate.error)
    }

    func test_whenUserPressesEditPictureButton_withURL_andCancels_returnError() {
        mockFlow.triggeredEdit = false

        editSut.editPhoto(with: IONCAMREditOptionsConfigurations.metadataWithoutSave(uri: IONCAMRPictureMock.osLogo.url.absoluteString))

        XCTAssertNil(mockDelegate.singleResult)
        XCTAssertEqual(mockDelegate.error, IONCAMRError.editPictureCancel)
    }

    func test_whenUserPressesEditPictureButton_withURL_andSomethingWrongHappens_returnError() {
        mockFlow.error = .editPictureIssue

        editSut.editPhoto(with: IONCAMREditOptionsConfigurations.metadataWithoutSave(uri: IONCAMRPictureMock.osLogo.url.absoluteString))

        XCTAssertNil(mockDelegate.singleResult)
        XCTAssertEqual(mockDelegate.error, mockFlow.error)
    }

    func test_whenUserPressesEditPictureButton_withURL_withSuccess_andReturnMetadataIsTrue_returnBase64StringWithMetadata() {
        editSut.editPhoto(with: IONCAMREditOptionsConfigurations.metadataWithoutSave(uri: IONCAMRPictureMock.osLogo.url.absoluteString))

        XCTAssertEqual(mockDelegate.singleResult, IONCAMRPictureMock.osLogoBlue.toMediaResultWithMetadata)
        XCTAssertNil(mockDelegate.error)
    }

    func test_whenUserPressesEditPictureButton_withURL_withSuccess_andReturnMetadataIsFalse_returnBase64StringWithoutMetadata() {
        editSut.editPhoto(with: IONCAMREditOptionsConfigurations.saveWithoutMetadata(uri: IONCAMRPictureMock.osLogo.url.absoluteString))

        XCTAssertEqual(mockDelegate.singleResult, IONCAMRPictureMock.osLogoBlue.toMediaResult)
        XCTAssertNil(mockDelegate.error)
    }

    // MARK: - Choose Picture Tests

    func test_whenUserPressesChoosePictureButton_andCancels_returnError() {
        mockFlow.triggeredCancelChoosePicture = true

        gallerySut.choosePicture(false)

        XCTAssertNil(mockDelegate.singleResult)
        XCTAssertEqual(mockDelegate.error, IONCAMRError.choosePictureCancel)
    }

    func test_whenUserPressesChoosePictureButton_andSomethingWrongHappens_returnError() {
        mockFlow.triggeredChoosePicture = true
        mockFlow.error = .choosePictureIssue

        gallerySut.choosePicture(false)

        XCTAssertNil(mockDelegate.singleResult)
        XCTAssertEqual(mockDelegate.error, mockFlow.error)
    }

    func test_whenUserPressesChoosePictureButton_withSuccess_returnBase64String() {
        mockFlow.triggeredChoosePicture = true

        gallerySut.choosePicture(false)

        XCTAssertEqual(mockDelegate.singleResult?.thumbnail, IONCAMRPictureMock.osLogo.image.toData()?.base64EncodedString())
        XCTAssertNil(mockDelegate.error)
    }

    // MARK: - Capture Video Tests

    func test_whenUserPressesCaptureVideoButton_andCancels_returnError() {
        mockFlow.triggeredCancelVideo = true

        sut.recordVideo(with: IONCAMRRecordVideoOptionsConfigurations.video)

        XCTAssertNil(mockDelegate.singleResult)
        XCTAssertEqual(mockDelegate.error, IONCAMRError.captureVideoCancel)
    }

    func test_whenUserPressesCaptureVideoButton_andSomethingWrongHappens_returnError() {
        mockFlow.triggeredCaptureVideo = true
        mockFlow.error = .captureVideoIssue

        sut.recordVideo(with: IONCAMRRecordVideoOptionsConfigurations.video)

        XCTAssertNil(mockDelegate.singleResult)
        XCTAssertEqual(mockDelegate.error, mockFlow.error)
    }

    func test_whenUserPressesCaptureVideoButton_withSuccess_returnURLandThumbnail() {
        mockFlow.triggeredCaptureVideo = true

        sut.recordVideo(with: IONCAMRRecordVideoOptionsConfigurations.video)

        XCTAssertEqual(mockDelegate.singleResult, IONCAMRVideoMock.first.toMediaResult)
        XCTAssertNil(mockDelegate.error)
    }

    func test_whenUserPressesCaptureVideoButton_withSuccess_whenTemporaryFilesIsExecuted_arrayIsEmpty() {
        mockFlow.triggeredCaptureVideo = true

        sut.recordVideo(with: IONCAMRRecordVideoOptionsConfigurations.video)

        XCTAssertEqual(mockFlow.temporaryURLArray, [IONCAMRVideoMock.first.url])

        sut.cleanTemporaryFiles()

        XCTAssertEqual(mockFlow.temporaryURLArray.count, 0)
    }

    func test_whenUserPressesCaptureVideoButton_withSuccess_andReturnMetadataIsTrue_returnVideoInfoWithMetadata() {
        mockFlow.triggeredCaptureVideo = true

        sut.recordVideo(with: IONCAMRRecordVideoOptionsConfigurations.withMetadata)

        XCTAssertEqual(mockDelegate.singleResult, IONCAMRVideoMock.first.toMediaResultWithMetadata)
        XCTAssertNil(mockDelegate.error)
        XCTAssertEqual(mockFlow.temporaryURLArray, [IONCAMRVideoMock.first.url])
    }

    // MARK: - Choose Multimedia Tests

    func test_whenUserPressesChooseMultimediaButton_andCancels_returnError() {
        mockFlow.triggeredCancelChooseMultimedia = true

        gallerySut.chooseFromGallery(with: IONCAMRGalleryOptions(mediaType: .both, allowEdit: true, allowMultipleSelection: true, andThumbnailAsData: false, returnMetadata: false))

        XCTAssertNil(mockDelegate.arrayResult)
        XCTAssertEqual(mockDelegate.error, IONCAMRError.chooseMultimediaCancel)
    }

    func test_whenUserPressesChooseMultimediaButton_andSomethingWrongHappens_returnError() {
        mockFlow.triggeredChooseMultimedia = true
        mockFlow.error = .chooseMultimediaIssue

        gallerySut.chooseFromGallery(with: IONCAMRGalleryOptions(mediaType: .both, allowEdit: true, allowMultipleSelection: true, andThumbnailAsData: false, returnMetadata: false))

        XCTAssertNil(mockDelegate.arrayResult)
        XCTAssertEqual(mockDelegate.error, mockFlow.error)
    }

    func test_whenUserPressesChooseMultimediaButton_withSuccess_andBothFilesArePictures_returnPictures() {
        mockFlow.triggeredChooseMultimedia = true

        gallerySut.chooseFromGallery(with: IONCAMRGalleryOptions(mediaType: .picture, allowEdit: true, allowMultipleSelection: true, andThumbnailAsData: false, returnMetadata: false))

        XCTAssertEqual(mockDelegate.arrayResult?.isEmpty, false)
        XCTAssertNil(mockDelegate.error)
    }

    func test_whenUserPressesChooseMultimediaButton_withSuccess_andBothFilesArePicture_andReturnMetadaIsTrue_returnPicturesWithMetadata() {
        mockFlow.triggeredChooseMultimedia = true

        gallerySut.chooseFromGallery(with: IONCAMRGalleryOptions(mediaType: .picture, allowEdit: true, allowMultipleSelection: true, andThumbnailAsData: false, returnMetadata: true))

        XCTAssertEqual(mockDelegate.arrayResult, [IONCAMRPictureMock.osLogo.toMediaResultWithMetadata, IONCAMRPictureMock.osLogoRotated.toMediaResultWithMetadata])
        XCTAssertNil(mockDelegate.error)
    }

    func test_whenUserPressesChooseMultimediaButton_withSuccess_andBothFilesAreVideo_returnVideos() {
        mockFlow.triggeredChooseMultimedia = true

        gallerySut.chooseFromGallery(with: IONCAMRGalleryOptions(mediaType: .video, allowEdit: true, allowMultipleSelection: true, andThumbnailAsData: false, returnMetadata: false))

        XCTAssertEqual(mockDelegate.arrayResult?.isEmpty, false)
        XCTAssertNil(mockDelegate.error)
    }

    func test_whenUserPressesChooseMultimediaButton_withSuccess_andBothFilesAreVideo_andReturnMetadataIsTrue_returnVideosWithMetadata() {
        mockFlow.triggeredChooseMultimedia = true

        gallerySut.chooseFromGallery(with: IONCAMRGalleryOptions(mediaType: .video, allowEdit: true, allowMultipleSelection: true, andThumbnailAsData: false, returnMetadata: true))

        XCTAssertEqual(mockDelegate.arrayResult, [IONCAMRVideoMock.first.toMediaResultWithMetadata, IONCAMRVideoMock.second.toMediaResultWithMetadata])
        XCTAssertNil(mockDelegate.error)
    }

    func test_whenUserPressesChooseMultimediaButton_withSuccess_andFilesArePictureAndVideo_returnPictureAndVideo() {
        mockFlow.triggeredChooseMultimedia = true

        gallerySut.chooseFromGallery(with: IONCAMRGalleryOptions(mediaType: .both, allowEdit: true, allowMultipleSelection: true, andThumbnailAsData: false, returnMetadata: false))

        XCTAssertEqual(mockDelegate.arrayResult?.isEmpty, false)
        XCTAssertNil(mockDelegate.error)
    }

    func test_whenUserPressesChooseMultimediaButton_withSuccess_andFilesArePictureAndVideo_andReturnMetadataIsTrue_returnPictureAndVideoWithMetadata() {
        mockFlow.triggeredChooseMultimedia = true

        gallerySut.chooseFromGallery(with: IONCAMRGalleryOptions(mediaType: .both, allowEdit: true, allowMultipleSelection: true, andThumbnailAsData: false, returnMetadata: true))

        XCTAssertEqual(mockDelegate.arrayResult, [IONCAMRPictureMock.osLogo.toMediaResultWithMetadata, IONCAMRVideoMock.first.toMediaResultWithMetadata])
        XCTAssertNil(mockDelegate.error)
    }

    // MARK: - Play Video Tests

    func test_whenUserPressesPlayVideoButton_butVideoCantBePlayed_returnError() async {
        mockVideoPlayer.isVideoPlayable = false

        await assertThrowsAsyncError(try await videoSut.playVideo(IONCAMRVideoMock.first.url))
    }

    func test_whenUserPressesPlayVideoButton_withSuccess_videoIsPlayed() async throws {
        mockVideoPlayer.isVideoPlayable = true

        try await videoSut.playVideo(IONCAMRVideoMock.first.url)
    }
}

private extension IONCAMRCameraTests {
    func assertThrowsAsyncError<T>(
        _ expression: @autoclosure () async throws -> T,
        _ message: @autoclosure () -> String = "",
        file: StaticString = #filePath,
        line: UInt = #line,
        _ errorHandler: (_ error: Error) -> Void = { _ in }
    ) async {
        do {
            _ = try await expression()
            let customMessage = message()
            if customMessage.isEmpty {
                XCTFail("Asynchronous call did not throw an error.", file: file, line: line)
            } else {
                XCTFail(customMessage, file: file, line: line)
            }
        } catch {
            errorHandler(error)
        }
    }
}
