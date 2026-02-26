import XCTest
@testable import OSCameraLib

final class IONCAMRFactoryTests: XCTestCase {
    func test_whenCreateWrapperIsTriggered_CreatesIONCAMRCameraObject() {
        let result = IONCAMRFactory.createCameraWrapper(withDelegate: self, and: UIViewControllerConfigurations.default)
        XCTAssertTrue(result is IONCAMRCamera)
    }
}

extension IONCAMRFactoryTests: IONCAMRCallbackDelegate {
    func callback(result: String?, error: IONCAMRError?) {
        print("Just return it...")
    }
}
