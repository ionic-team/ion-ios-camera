import XCTest
@testable import IONCameraLib

final class IONCAMRFactoryTests: XCTestCase {
    func test_whenCreateWrapperIsTriggered_CreatesIONCAMRCameraObject() {
        let result = IONCAMRFactory.createCameraManagerWrapper(withDelegate: self, and: UIViewControllerConfigurations.default)
        XCTAssertTrue(result is IONCAMRCameraManager)
    }
}

extension IONCAMRFactoryTests: IONCAMRCallbackDelegate {
    func callback(error: IONCAMRError) {}
    func callback(result: IONCAMRMediaResult) {}
    func callback(result: [IONCAMRMediaResult]) {}
}
