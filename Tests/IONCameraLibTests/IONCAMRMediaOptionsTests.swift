import UniformTypeIdentifiers
import XCTest
@testable import OSCameraLib

final class IONCAMRMediaOptionsTests: XCTestCase {
    func test_whenQualitySetWithValueUnderZero_returnNil() {
        let pictureOptions = IONCAMRPictureOptionsConfigurations.qualityUnder0
        XCTAssertNil(pictureOptions)
    }

    func test_whenQualitySetWithValueOverHundred_returnNil() {
        let pictureOptions = IONCAMRPictureOptionsConfigurations.qualityOver100
        XCTAssertNil(pictureOptions)
    }

    func test_whenSizeSet_useIt() {
        let pictureOptions = IONCAMRPictureOptionsConfigurations.sizeSet

        XCTAssertEqual(pictureOptions?.mediaType, .picture)
        XCTAssertEqual(pictureOptions?.quality, 50)
        XCTAssertEqual(pictureOptions?.size?.width, 50)
        XCTAssertEqual(pictureOptions?.size?.height, 150)
    }

    func test_whenCameraIsSetToBack_useUIImagePickerControllerCameraDeviceRear() {
        let pictureOptions = IONCAMRPictureOptionsConfigurations.backCamera

        XCTAssertEqual(pictureOptions?.mediaType, .picture)
        XCTAssertEqual(pictureOptions?.cameraDevice, .rear)
    }

    func test_whenCameraIsSetToFront_useUIImagePickerControllerCameraDeviceFront() {
        let pictureOptions = IONCAMRPictureOptionsConfigurations.frontCamera

        XCTAssertEqual(pictureOptions?.mediaType, .picture)
        XCTAssertEqual(pictureOptions?.cameraDevice, .front)
    }

    func test_whenSettingPictureOptions_uiImagePickerControllerMediaTypesShouldReturnImage() {
        let pictureOptions = IONCAMRPictureOptionsConfigurations.allowEdit

        XCTAssertEqual(pictureOptions?.mediaType, .picture)
        XCTAssertEqual(pictureOptions?.mediaType.phAssetArray, [.image])
        XCTAssertEqual(pictureOptions?.mediaType.stringArray, [UTType.image.identifier])
    }

    func test_whenSettingVideoOptions_uiImagePickerControllerMediaTypesShouldReturnMovie() {
        let videoOptions = IONCAMRRecordVideoOptionsConfigurations.video

        XCTAssertEqual(videoOptions.mediaType, .video)
        XCTAssertEqual(videoOptions.mediaType.phAssetArray, [.video])
        XCTAssertEqual(videoOptions.mediaType.stringArray, [UTType.movie.identifier])
    }
}
