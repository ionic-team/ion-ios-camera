import XCTest
@testable import OSCameraLib

final class IONCAMRFlowEditPictureTests: XCTestCase {
    private var resultsDelegate: IONCAMRFlowResultsDelegateMock!
    private var editorBehaviour: IONCAMREditorBehaviourMock!
    private var galleryBehaviour: IONCAMRGalleryBehaviourMock!
    private var imageFetcher: IONCAMRImageFetcherBehaviourMock!
    private var urlGenerator: IONCAMRURLGeneratorMock!

    private var sut: IONCAMRFlowBehaviour!

    override func setUp() {
        resultsDelegate = IONCAMRFlowResultsDelegateMock()
        editorBehaviour = IONCAMREditorBehaviourMock()
        galleryBehaviour = IONCAMRGalleryBehaviourMock()
        imageFetcher = IONCAMRImageFetcherBehaviourMock()
        urlGenerator = IONCAMRURLGeneratorMock()

        sut = IONCAMRFlowBehaviour(
            picker: IONCAMRPickerBehaviourMock(),
            editorBehaviour: editorBehaviour,
            galleryBehaviour: galleryBehaviour,
            permissionsBehaviour: IONCAMRPermissionsBehaviourMock(),
            thumbnailGenerator: IONCAMRThumbnailGeneratorMock(),
            metadataGetter: IONCAMRMetadataGetterMock(),
            imageFetcher: imageFetcher,
            urlGenerator: urlGenerator,
            coordinator: IONCAMRCoordinatorMock(rootViewController: UIViewControllerConfigurations.default)
        )
        sut.delegate = resultsDelegate
    }

    override func tearDown() {
        sut = nil

        urlGenerator = nil
        imageFetcher = nil
        galleryBehaviour = nil
        editorBehaviour = nil
        resultsDelegate = nil
    }

    func test_editPictureOnAURL_whenSomethingWrongOccurs_returnError() {
        imageFetcher.callShouldSucceed = false

        sut.editPicture(from: IONCAMRPictureMock.osLogo.url.absoluteString, with: IONCAMREditOptionsConfigurations.noSaveNorMetadata)

        XCTAssertNil(resultsDelegate.resultSingle)
        XCTAssertEqual(resultsDelegate.error, IONCAMRError.fetchImageFromURLFailed)
    }

    func test_editPictureOnAURL_whenSaveToGallerySetToFalse_andReturnMetadataSetToFalse_whenSuccessful_returnEditedAsset() {
        urlGenerator.urlToReturn = IONCAMRPictureMock.osLogoBlue.url

        sut.editPicture(from: IONCAMRPictureMock.osLogo.url.absoluteString, with: IONCAMREditOptionsConfigurations.noSaveNorMetadata)

        editorBehaviour.didEndSuccessfullyEditPictureHandler()

        XCTAssertNil(resultsDelegate.error)
        XCTAssertEqual(resultsDelegate.resultSingle, IONCAMRPictureMock.osLogoBlue.toMediaResult)
        XCTAssertEqual(sut.temporaryURLArray.map(\.absoluteString), [resultsDelegate.resultSingle!.uri])
        XCTAssertFalse(galleryBehaviour.isSaved)
    }

    func test_editPictureOnAURL_whenSaveToGallerySetToTrue_whenSuccessful_returnEditedAsset() {
        urlGenerator.urlToReturn = IONCAMRPictureMock.osLogoBlue.url

        sut.editPicture(from: IONCAMRPictureMock.osLogo.url.absoluteString, with: IONCAMREditOptionsConfigurations.saveWithoutMetadata)

        editorBehaviour.didEndSuccessfullyEditPictureHandler()

        XCTAssertNil(resultsDelegate.error)
        XCTAssertEqual(resultsDelegate.resultSingle, IONCAMRPictureMock.osLogoBlue.toMediaResult)
        XCTAssertEqual(sut.temporaryURLArray.map(\.absoluteString), [resultsDelegate.resultSingle!.uri])
        XCTAssertTrue(galleryBehaviour.isSaved)
    }

    func test_editPictureOnAURL_whenReturnMetadataSetToTrue_whenSuccessful_returnEditedAsset() {
        urlGenerator.urlToReturn = IONCAMRPictureMock.osLogoBlue.url

        sut.editPicture(from: IONCAMRPictureMock.osLogo.url.absoluteString, with: IONCAMREditOptionsConfigurations.metadataWithoutSave)

        editorBehaviour.didEndSuccessfullyEditPictureHandler()

        XCTAssertNil(resultsDelegate.error)
        XCTAssertEqual(resultsDelegate.resultSingle, IONCAMRPictureMock.osLogoBlue.toMediaResultWithMetadata)
        XCTAssertEqual(sut.temporaryURLArray.map(\.absoluteString), [resultsDelegate.resultSingle!.uri])
        XCTAssertFalse(galleryBehaviour.isSaved)
    }
}
