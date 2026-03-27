protocol IONCAMRDefaultOptionsDelegate: AnyObject {
    var returnMetadata: Bool { get set }
}

protocol IONCAMRSaveToGalleryOptionsDelegate: IONCAMRDefaultOptionsDelegate {
    var saveToGallery: Bool { get set }
}

protocol IONCAMREditMediaTypeOptionsDelegate: IONCAMRDefaultOptionsDelegate {
    var mediaType: IONCAMRMediaType { get set }
    var allowEdit: Bool { get set }
}
