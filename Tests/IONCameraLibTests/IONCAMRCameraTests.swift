import XCTest
@testable import OSCameraLib

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

    private var sut: IONCAMRCamera!

    override func setUp() {
        mockDelegate = IONCAMRCallbackMock()
        mockFlow = IONCAMRFlowBehaviourMock()
        mockVideoPlayer = IONCAMRPlayerBehaviourMock()

        sut = IONCAMRCamera(delegate: mockDelegate, flow: mockFlow, videoPlayer: mockVideoPlayer)
    }

    override func tearDown() {
        sut = nil

        mockDelegate = nil
        mockFlow = nil
        mockVideoPlayer = nil
    }

    // MARK: - Take Picture Tests

    func test_whenUserPressesTakePictureButton_andCancels_returnError() {
        mockFlow.triggeredCancelTakePicture = true

        sut.captureMedia(with: IONCAMRPictureOptionsConfigurations.jpegEncodingType!)

        XCTAssertNil(mockDelegate.successText)
        XCTAssertEqual(mockDelegate.error, IONCAMRError.takePictureCancel)
    }

    func test_whenUserPressesTakePictureButton_andSomethingWrongHappens_returnError() {
        mockFlow.triggeredTakePicture = true
        mockFlow.error = .takePictureIssue

        sut.captureMedia(with: IONCAMRPictureOptionsConfigurations.jpegEncodingType!)

        XCTAssertNil(mockDelegate.successText)
        XCTAssertEqual(mockDelegate.error, mockFlow.error)
    }

    func test_whenUserPressesTakePictureButton_withSuccess_returnJPEGsBase64String() {
        mockFlow.triggeredTakePicture = true
        let pictureOptions = IONCAMRPictureOptionsConfigurations.jpegEncodingType!

        sut.captureMedia(with: pictureOptions)

        XCTAssertEqual(mockDelegate.successText, IONCAMRPictureMock.osLogo.image.toData(with: pictureOptions)?.base64EncodedString())
        XCTAssertNil(mockDelegate.error)
    }

    func test_whenUserPressesTakePictureButton_withSuccess_returnPNGsBase64String() {
        mockFlow.triggeredTakePicture = true
        let pictureOptions = IONCAMRPictureOptionsConfigurations.pngEncodingType!

        sut.captureMedia(with: pictureOptions)

        XCTAssertEqual(mockDelegate.successText, IONCAMRPictureMock.osLogo.image.toData(with: pictureOptions)?.base64EncodedString())
        XCTAssertNil(mockDelegate.error)
    }

    // MARK: - Edit Picture Tests

    func test_whenUserPressesEditPictureButton_withImage_andCancels_returnError() {
        mockFlow.triggeredEdit = false

        sut.editPicture(IONCAMRPictureMock.osLogo.image)

        XCTAssertNil(mockDelegate.successText)
        XCTAssertEqual(mockDelegate.error, IONCAMRError.editPictureCancel)
    }

    func test_whenUserPressesEditPictureButton_withImage_andSomethingWrongHappens_returnError() {
        mockFlow.error = .editPictureIssue

        sut.editPicture(IONCAMRPictureMock.osLogo.image)

        XCTAssertNil(mockDelegate.successText)
        XCTAssertEqual(mockDelegate.error, mockFlow.error)
    }

    func test_whenUserPressesEditPictureButton_withImage_withSuccess_returnsBase64String() {
        sut.editPicture(IONCAMRPictureMock.osLogo.image)

        XCTAssertEqual(mockDelegate.successText, IONCAMRPictureMock.osLogoBlue.image.toData()?.base64EncodedString())
        XCTAssertNil(mockDelegate.error)
    }

    func test_whenUserPressesEditPictureButton_withURL_andCancels_returnError() {
        mockFlow.triggeredEdit = false

        sut.editPicture(
            from: IONCAMRPictureMock.osLogo.url.absoluteString, with: IONCAMREditOptionsConfigurations.metadataWithoutSave
        )

        XCTAssertNil(mockDelegate.successText)
        XCTAssertEqual(mockDelegate.error, IONCAMRError.editPictureCancel)
    }

    func test_whenUserPressesEditPictureButton_withURL_andSomethingWrongHappens_returnError() {
        mockFlow.error = .editPictureIssue

        sut.editPicture(
            from: IONCAMRPictureMock.osLogo.url.absoluteString, with: IONCAMREditOptionsConfigurations.metadataWithoutSave
        )

        XCTAssertNil(mockDelegate.successText)
        XCTAssertEqual(mockDelegate.error, mockFlow.error)
    }

    func test_whenUserPressesEditPictureButton_withURL_withSuccess_andReturnMetadataIsTrue_returnBase64StringWithMetadata() throws {
        sut.editPicture(
            from: IONCAMRPictureMock.osLogo.url.absoluteString, with: IONCAMREditOptionsConfigurations.metadataWithoutSave
        )

        let successText = mockDelegate.successText ?? ""
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let mediaResultData = successText.data(using: .utf8) ?? .init()
        let mediaResult = try decoder.decode(IONCAMRMediaResult.self, from: mediaResultData)

        XCTAssertEqual(mediaResult, IONCAMRPictureMock.osLogoBlue.toMediaResultWithMetadata)
        XCTAssertNil(mockDelegate.error)
    }

    func test_whenUserPressesEditPictureButton_withURL_withSuccess_andReturnMetadataIsFalse_returnBase64StringWithoutMetadata() throws {
        sut.editPicture(
            from: IONCAMRPictureMock.osLogo.url.absoluteString, with: IONCAMREditOptionsConfigurations.saveWithoutMetadata
        )

        let successText = mockDelegate.successText ?? ""
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let mediaResultData = successText.data(using: .utf8) ?? .init()
        let mediaResult = try decoder.decode(IONCAMRMediaResult.self, from: mediaResultData)

        XCTAssertEqual(mediaResult, IONCAMRPictureMock.osLogoBlue.toMediaResult)
        XCTAssertNil(mockDelegate.error)
    }

    // MARK: - Choose Picture Tests

    func test_whenUserPressesChoosePictureButton_andCancels_returnError() {
        mockFlow.triggeredCancelChoosePicture = true

        sut.choosePicture(false)

        XCTAssertNil(mockDelegate.successText)
        XCTAssertEqual(mockDelegate.error, IONCAMRError.choosePictureCancel)
    }

    func test_whenUserPressesChoosePictureButton_andSomethingWrongHappens_returnError() {
        mockFlow.triggeredChoosePicture = true
        mockFlow.error = .choosePictureIssue

        sut.choosePicture(false)

        XCTAssertNil(mockDelegate.successText)
        XCTAssertEqual(mockDelegate.error, mockFlow.error)
    }

    func test_whenUserPressesChoosePictureButton_withSuccess_returnBase64String() {
        mockFlow.triggeredChoosePicture = true

        sut.choosePicture(false)

        XCTAssertEqual(mockDelegate.successText, IONCAMRPictureMock.osLogo.image.toData()?.base64EncodedString())
        XCTAssertNil(mockDelegate.error)
    }

    // MARK: - Capture Video Tests

    func test_whenUserPressesCaptureVideoButton_andCancels_returnError() {
        mockFlow.triggeredCancelVideo = true

        sut.captureMedia(with: IONCAMRVideoOptionsConfigurations.video)

        XCTAssertNil(mockDelegate.successText)
        XCTAssertEqual(mockDelegate.error, IONCAMRError.captureVideoCancel)
    }

    func test_whenUserPressesCaptureVideoButton_andSomethingWrongHappens_returnError() {
        mockFlow.triggeredCaptureVideo = true
        mockFlow.error = .captureVideoIssue

        sut.captureMedia(with: IONCAMRVideoOptionsConfigurations.video)

        XCTAssertNil(mockDelegate.successText)
        XCTAssertEqual(mockDelegate.error, mockFlow.error)
    }

    func test_whenUserPressesCaptureVideoButton_withSuccess_returnURLandThumbnail() throws {
        mockFlow.triggeredCaptureVideo = true

        sut.captureMedia(with: IONCAMRVideoOptionsConfigurations.video)

        let mediaResult = IONCAMRVideoMock.first.toMediaResult
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let mediaResultData = try encoder.encode(mediaResult)
        let mediaResultString = String(data: mediaResultData, encoding: .utf8) ?? ""

        XCTAssertEqual(mockDelegate.successText, mediaResultString)
        XCTAssertNil(mockDelegate.error)
    }

    func test_whenUserPressesCaptureVideoButton_withSuccess_whenTemporaryFilesIsExecuted_arrayIsEmpty() {
        mockFlow.triggeredCaptureVideo = true

        sut.captureMedia(with: IONCAMRVideoOptionsConfigurations.video)

        XCTAssertEqual(mockFlow.temporaryURLArray, [IONCAMRVideoMock.first.url])

        sut.cleanTemporaryFiles()

        XCTAssertEqual(mockFlow.temporaryURLArray.count, 0)
    }

    func test_whenUserPressesCaptureVideoButton_withSuccess_andReturnMetadataIsTrue_returnVideoInfoWithMetadata() throws {
        mockFlow.triggeredCaptureVideo = true

        sut.captureMedia(with: IONCAMRVideoOptionsConfigurations.withMetadata)

        let successText = mockDelegate.successText ?? ""
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let mediaResultData = successText.data(using: .utf8) ?? .init()
        let mediaResult = try decoder.decode(IONCAMRMediaResult.self, from: mediaResultData)

        XCTAssertEqual(mediaResult, IONCAMRVideoMock.first.toMediaResultWithMetadata)
        XCTAssertNil(mockDelegate.error)
        XCTAssertEqual(mockFlow.temporaryURLArray, [IONCAMRVideoMock.first.url])
    }

    // MARK: - Choose Multimedia Tests

    func test_whenUserPressesChooseMultimediaButton_andCancels_returnError() {
        mockFlow.triggeredCancelChooseMultimedia = true

        sut.chooseMultimedia(.both, true, false, and: false)

        XCTAssertNil(mockDelegate.successText)
        XCTAssertEqual(mockDelegate.error, IONCAMRError.chooseMultimediaCancel)
    }

    func test_whenUserPressesChooseMultimediaButton_andSomethingWrongHappens_returnError() {
        mockFlow.triggeredChooseMultimedia = true
        mockFlow.error = .chooseMultimediaIssue

        sut.chooseMultimedia(.both, true, false, and: false)

        XCTAssertNil(mockDelegate.successText)
        XCTAssertEqual(mockDelegate.error, mockFlow.error)
    }

    func test_whenUserPressesChooseMultimediaButton_withSuccess_andBothFilesArePictures_returnPictures() {
        mockFlow.triggeredChooseMultimedia = true

        sut.chooseMultimedia(.picture, true, false, and: false)

        XCTAssertEqual(mockDelegate.successText?.isEmpty, false)
        XCTAssertNil(mockDelegate.error)
    }

    func test_whenUserPressesChooseMultimediaButton_withSuccess_andBothFilesArePicture_andReturnMetadaIsTrue_returnPicturesWithMetadata() throws {
        mockFlow.triggeredChooseMultimedia = true

        sut.chooseMultimedia(.picture, true, true, and: false)

        let successText = mockDelegate.successText ?? ""
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let mediaResultData = successText.data(using: .utf8) ?? .init()
        let mediaResult = try decoder.decode([IONCAMRMediaResult].self, from: mediaResultData)

        XCTAssertEqual(mediaResult, [IONCAMRPictureMock.osLogo.toMediaResultWithMetadata, IONCAMRPictureMock.osLogoRotated.toMediaResultWithMetadata])
        XCTAssertNil(mockDelegate.error)
    }

    func test_whenUserPressesChooseMultimediaButton_withSuccess_andBothFilesAreVideo_returnVideos() {
        mockFlow.triggeredChooseMultimedia = true

        sut.chooseMultimedia(.video, true, false, and: false)

        XCTAssertEqual(mockDelegate.successText?.isEmpty, false)
        XCTAssertNil(mockDelegate.error)
    }

    func test_whenUserPressesChooseMultimediaButton_withSuccess_andBothFilesAreVideo_andReturnMetadataIsTrue_returnVideosWithMetadata() throws {
        mockFlow.triggeredChooseMultimedia = true

        sut.chooseMultimedia(.video, true, true, and: false)

        let successText = mockDelegate.successText ?? ""
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let mediaResultData = successText.data(using: .utf8) ?? .init()
        let mediaResult = try decoder.decode([IONCAMRMediaResult].self, from: mediaResultData)

        XCTAssertEqual(mediaResult, [IONCAMRVideoMock.first.toMediaResultWithMetadata, IONCAMRVideoMock.second.toMediaResultWithMetadata])
        XCTAssertNil(mockDelegate.error)
    }

    func test_whenUserPressesChooseMultimediaButton_withSuccess_andFilesArePictureAndVideo_returnPictureAndVideo() {
        mockFlow.triggeredChooseMultimedia = true

        sut.chooseMultimedia(.both, true, false, and: false)

        XCTAssertEqual(mockDelegate.successText?.isEmpty, false)
        XCTAssertNil(mockDelegate.error)
    }

    func test_whenUserPressesChooseMultimediaButton_withSuccess_andFilesArePictureAndVideo_andReturnMetadataIsTrue_returnPictureAndVideoWithMetadata() throws {
        mockFlow.triggeredChooseMultimedia = true

        sut.chooseMultimedia(.both, true, true, and: false)

        let successText = mockDelegate.successText ?? ""
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let mediaResultData = successText.data(using: .utf8) ?? .init()
        let mediaResult = try decoder.decode([IONCAMRMediaResult].self, from: mediaResultData)

        XCTAssertEqual(mediaResult, [IONCAMRPictureMock.osLogo.toMediaResultWithMetadata, IONCAMRVideoMock.first.toMediaResultWithMetadata])
        XCTAssertNil(mockDelegate.error)
    }

    // MARK: - Play Video Tests

    func test_whenUserPressesPlayVideoButton_butVideoCantBePlayed_returnError() async {
        mockVideoPlayer.isVideoPlayable = false

        await assertThrowsAsyncError(try await sut.playVideo(IONCAMRVideoMock.first.url))
    }

    func test_whenUserPressesPlayVideoButton_withSuccess_videoIsPlayed() async throws {
        mockVideoPlayer.isVideoPlayable = true

        try await sut.playVideo(IONCAMRVideoMock.first.url)
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
