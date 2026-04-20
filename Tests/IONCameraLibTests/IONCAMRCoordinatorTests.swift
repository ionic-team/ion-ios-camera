@testable import IONCameraLibCore
import XCTest

final class IONCAMRCoordinatorTests: XCTestCase {
    private var rootViewController: UIViewController!

    private var sut: IONCAMRCoordinator!
    private var mirror: IONCAMRCoordinatorMirror!

    override func setUp() {
        rootViewController = UIViewControllerConfigurations.default
        sut = IONCAMRCoordinator(rootViewController: rootViewController)
        mirror = IONCAMRCoordinatorMirror(coordinator: sut)
    }

    override func tearDown() {
        mirror = nil
        sut = nil

        rootViewController = nil
    }

    func test_defaultCoordinatorHasRootViewControllerDefined() {
        XCTAssertEqual(mirror.rootViewController, rootViewController)
        XCTAssertEqual(mirror.currentlyPresentedViewControllerArray?.isEmpty, true)
        XCTAssertEqual(mirror.screenViewController, rootViewController)
    }

    func test_whenPresentingNewViewController_isAddedToCurrentlyPresentedArray() {
        let takePictureController = UIViewControllerConfigurations.takeMedia

        sut.present(takePictureController)

        XCTAssertEqual(mirror.currentlyPresentedViewControllerArray, [takePictureController])
        XCTAssertFalse(sut.isSecondStep)
        XCTAssertEqual(mirror.screenViewController, takePictureController)
    }

    func test_whenPresentingNewViewController_andThenDismiss_CurrentlyPresentedArrayIsEmpty() {
        let takePictureController = UIViewControllerConfigurations.takeMedia

        sut.present(takePictureController)
        sut.dismiss()

        XCTAssertEqual(mirror.currentlyPresentedViewControllerArray?.isEmpty, true)
        XCTAssertEqual(mirror.screenViewController, rootViewController)
    }

    func test_whenPresentingTwoNewViewControllers_bothAreAddedToCurrentlyPresentedArray() {
        let takePictureController = UIViewControllerConfigurations.takeMedia
        let editPictureController = UIViewControllerConfigurations.editPicture

        sut.present(takePictureController)
        sut.present(editPictureController)

        XCTAssertEqual(mirror.currentlyPresentedViewControllerArray, [takePictureController, editPictureController])
        XCTAssertTrue(sut.isSecondStep)
        XCTAssertEqual(mirror.screenViewController, editPictureController)
    }

    func test_whenPresentingTwoNewViewControllers_andThenDismiss_CurrentlyPresentedArrayIsEmpty() {
        let takePictureController = UIViewControllerConfigurations.takeMedia
        let editPictureController = UIViewControllerConfigurations.editPicture

        sut.present(takePictureController)
        sut.present(editPictureController)
        sut.dismiss()

        XCTAssertEqual(mirror.currentlyPresentedViewControllerArray?.isEmpty, true)
        XCTAssertEqual(mirror.screenViewController, rootViewController)
    }
}
