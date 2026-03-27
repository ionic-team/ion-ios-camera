import UIKit

/// Interface that manages and handles all plugin actions flow, whether the operation as one or more steps.
protocol IONCAMRFlowDelegate: AnyObject {
    /// Handles the result of interacting with the flow interface. This is to be triggered by the result delegates from all the behaviours this object
    /// uses.
    var delegate: IONCAMRFlowResultsDelegate? { get set }
    /// Object responsible for managing the user interface screens and respective flow.
    var coordinator: IONCAMRCoordinator { get set }

    var temporaryURLArray: [URL] { get set }

    func takePhoto(with options: IONCAMRTakePhotoOptions)
    func recordVideo(with options: IONCAMRRecordVideoOptions)

    /// Triggers the user interface that manages the editing a picture feature.
    /// - Parameter image: Image to be edited.
    func editPhoto(_ image: UIImage)
    func editPhoto(with options: IONCAMRPhotoEditOptions)
    func chooseFromGallery(with options: IONCAMRGalleryOptions)

    func cleanTemporaryFiles()
}
