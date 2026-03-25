@testable import IONCameraLib

extension IONCAMRFlowBehaviour {
    func choosePicture(allowEdit: Bool) {
        let options = IONCAMRGalleryOptions(
            mediaType: .picture, allowEdit: allowEdit, allowMultipleSelection: false, andThumbnailAsData: false, returnMetadata: false
        )
        self.chooseFromGallery(with: options)
    }

    func chooseMultimedia(type mediaType: IONCAMRMediaType, allowEdit: Bool = false, allowMultipleSelection: Bool, returnMetadata: Bool, andThumbnailAsData: Bool = false) {
        let options = IONCAMRGalleryOptions(
            mediaType: mediaType,
            allowEdit: allowEdit,
            allowMultipleSelection: allowMultipleSelection,
            andThumbnailAsData: andThumbnailAsData,
            returnMetadata: returnMetadata
        )
        self.chooseFromGallery(with: options)
    }
}

extension IONCAMRMediaResult: Equatable {
    public static func == (lhs: IONCAMRMediaResult, rhs: IONCAMRMediaResult) -> Bool {
        lhs.type == rhs.type && lhs.uri == rhs.uri && lhs.thumbnail == rhs.thumbnail && lhs.metadata == rhs.metadata
    }
}

extension IONCAMRMetadata: Equatable {
    public static func == (lhs: IONCAMRMetadata, rhs: IONCAMRMetadata) -> Bool {
        lhs.size == rhs.size && lhs.resolution == rhs.resolution
        && lhs.format == rhs.format
        && lhs.duration == rhs.duration
    }
}

extension IONCAMRTakePhotoOptions {
    convenience init(quality: Int, size: IONCAMRSize? = nil, correctOrientation: Bool, encodingType: IONCAMREncodingType, saveToGallery: Bool, cameraDirection: IONCAMRDirection, allowEdit: Bool, returnMetadata: Bool) throws {
        try self.init(
            quality: quality,
            size: size,
            correctOrientation: correctOrientation,
            encodingType: encodingType,
            saveToGallery: saveToGallery,
            cameraDirection: cameraDirection,
            allowEdit: allowEdit,
            returnMetadata: returnMetadata
        )
    }
}
