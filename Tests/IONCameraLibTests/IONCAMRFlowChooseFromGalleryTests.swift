@testable import IONCameraLib
import XCTest

/// This was introduced on May 18th 2023 on the scope of https://outsystemsrd.atlassian.net/browse/RMET-2494.
/// Despite the name, it doesn't contain the whole `Choose from Gallery` client action tests
final class IONCAMRFlowChooseFromGalleryTests: XCTestCase {
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

        let coordinator = IONCAMRCoordinatorMock(rootViewController: UIViewControllerConfigurations.default)

        sut = IONCAMRFlowBehaviour(
            picker: IONCAMRPickerBehaviourMock(),
            editorBehaviour: editorBehaviour,
            galleryBehaviour: galleryBehaviour,
            permissionsBehaviour: IONCAMRPermissionsBehaviourMock(),
            thumbnailGenerator: IONCAMRThumbnailGeneratorMock(),
            metadataGetter: IONCAMRMetadataGetterMock(),
            imageFetcher: imageFetcher,
            urlGenerator: urlGenerator,
            coordinator: coordinator
        )
        sut.delegate = resultsDelegate

        coordinator.hasTwoSteps = true
    }

    override func tearDownWithError() throws {
        sut = nil

        urlGenerator = nil
        imageFetcher = nil
        galleryBehaviour = nil
        editorBehaviour = nil
        resultsDelegate = nil
    }

    func test_chooseFromGallery_withAllowEditSetToTrue_whenAllowMultipleSelectionSetToTrue_returnPicturesWithoutGoingThroughEdit() {
        sut.chooseMultimedia(
            type: .picture, allowEdit: true, allowMultipleSelection: true, returnMetadata: false, andThumbnailAsData: true
        )
        galleryBehaviour.didEndSuccessfullyChooseMultiplePicturesHandler()

        XCTAssertFalse(editorBehaviour.hasBeenEdited)
        XCTAssertNotNil(resultsDelegate.resultArray)
        XCTAssertNil(resultsDelegate.error)
    }

    func test_chooseFromGallery_withAllowEditSetToTrue_whenMediaTypeNotSetToPicture_returnAssetWithoutGoingThroughEdit() {
        sut.chooseMultimedia(
            type: .both, allowEdit: true, allowMultipleSelection: false, returnMetadata: false, andThumbnailAsData: true
        )
        galleryBehaviour.didEndSuccessfullyChoosePictureAndVideoHandler()

        XCTAssertFalse(editorBehaviour.hasBeenEdited)
        XCTAssertNotNil(resultsDelegate.resultArray)
        XCTAssertNil(resultsDelegate.error)
    }

    func test_chooseFromGallery_withAllowEditSetToTrue_whenMediaTypeSetToPicture_andAllowMultipleSelectionSetToFalse_whenNoPictureIsReturned_returnError(
    ) {
        sut.chooseMultimedia(
            type: .picture, allowEdit: true, allowMultipleSelection: false, returnMetadata: false, andThumbnailAsData: true
        )

        galleryBehaviour.didEndSuccessfullyWithNoPicturesSelectedHandler()

        XCTAssertNil(resultsDelegate.resultArray)
        XCTAssertEqual(resultsDelegate.error, .fetchImageFromURLFailed)
    }

    func test_chooseFromGallery_withAllowEditSetToTrue_whenMediaTypeSetToPicture_andAllowMultipleSelectionSetToFalse_whenMediaResultURIDoesntContainAnImage_returnError(
    ) {
        sut.chooseMultimedia(
            type: .picture, allowEdit: true, allowMultipleSelection: false, returnMetadata: false, andThumbnailAsData: true
        )

        imageFetcher.callShouldSucceed = false
        galleryBehaviour.didEndSuccessfullyChooseSinglePictureHandler()

        XCTAssertNil(resultsDelegate.resultArray)
        XCTAssertEqual(resultsDelegate.error, .fetchImageFromURLFailed)
    }

    func test_chooseFromGallery_withAllowEditSetToTrue_whenMediaTypeSetToPicture_andAllowMultipleSelectionSetToFalse_returnEditedPicture(
    ) async throws {
        sut.chooseMultimedia(
            type: .picture, allowEdit: true, allowMultipleSelection: false, returnMetadata: false, andThumbnailAsData: true
        )

        urlGenerator.urlToReturn = IONCAMRPictureMock.osLogoBlue.url
        galleryBehaviour.didEndSuccessfullyChooseSinglePictureHandler()
        editorBehaviour.didEndSuccessfullyEditPictureHandler()
        await resultsDelegate.waitForResult()

        XCTAssertTrue(editorBehaviour.hasBeenEdited)
        XCTAssertNil(resultsDelegate.error)
        XCTAssertEqual(resultsDelegate.resultArray, [IONCAMRPictureMock.osLogoBlue.toMediaResult])
        XCTAssertEqual(sut.temporaryURLArray.map(\.absoluteString), try [XCTUnwrap(resultsDelegate.resultArray?.first?.uri)])
    }

    func test_chooseFromGallery_withAllowEditSetToTrue_whenMediaTypeSetToPicture_andAllowMultipleSelectionSetToFalse_andReturnMetadataSetToTrue_returnEditedPicture(
    ) async throws {
        urlGenerator.urlToReturn = IONCAMRPictureMock.osLogoBlue.url

        sut.chooseMultimedia(
            type: .picture, allowEdit: true, allowMultipleSelection: false, returnMetadata: true, andThumbnailAsData: true
        )
        galleryBehaviour.didEndSuccessfullyChooseSinglePictureHandler()
        editorBehaviour.didEndSuccessfullyEditPictureHandler()
        await resultsDelegate.waitForResult()

        XCTAssertTrue(editorBehaviour.hasBeenEdited)
        XCTAssertNil(resultsDelegate.error)
        XCTAssertEqual(resultsDelegate.resultArray, [IONCAMRPictureMock.osLogoBlue.toMediaResultWithMetadata])
        XCTAssertEqual(sut.temporaryURLArray.map(\.absoluteString), try [XCTUnwrap(resultsDelegate.resultArray?.first?.uri)])
    }
}
