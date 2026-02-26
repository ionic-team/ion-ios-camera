protocol IONCAMRDefaultOptionsDelegate: AnyObject {
    var returnMetadata: Bool { get set }
}

protocol IONCAMRSaveToPhotoAlbumOptionsDelegate: IONCAMRDefaultOptionsDelegate { 
    var saveToPhotoAlbum: Bool { get set }
}

protocol IONCAMREditMediaTypeOptionsDelegate: IONCAMRDefaultOptionsDelegate {
    var mediaType: IONCAMRMediaType { get set }
    var allowEdit: Bool { get set }
}
