@testable import IONCameraLibCore
import XCTest

final class IONCAMRMediaTypeTests: XCTestCase {
    func test_whenAPictureIsPassed_createIONCAMRMediaTypePictureObject() throws {
        let mediaType = try IONCAMRMediaType(from: IONCAMRMediaType.IONCAMRMediaTypeEnum.picture.rawValue)

        XCTAssertEqual(mediaType, .picture)
    }

    func test_whenAVideoIsPassed_createIONCAMRMediaTypeVideoObject() throws {
        let mediaType = try IONCAMRMediaType(from: IONCAMRMediaType.IONCAMRMediaTypeEnum.video.rawValue)

        XCTAssertEqual(mediaType, .video)
    }

    func test_whenBothPictureAndVideoArePassed_createIONCAMRMediaTypeBothObject() throws {
        let mediaType = try IONCAMRMediaType(from: IONCAMRMediaType.IONCAMRMediaTypeEnum.both.rawValue)

        XCTAssertEqual(mediaType, .both)
    }

    func test_whenInvalidValueIsPassed_returnError() {
        XCTAssertThrowsError(try IONCAMRMediaType(from: 99)) {
            XCTAssertEqual($0 as? IONCAMRMediaType.IONCAMRMediaTypeError, .unknownType)
        }
    }
}
