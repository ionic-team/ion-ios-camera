import UIKit

protocol IONCAMREditorDelegate: AnyObject {
    typealias IONCAMREditorResultsDelegate = IONCAMRCancelResultsDelegate & IONCAMRResultsDelegate
    /// Handles the result of interacting with the editor interface.
    var delegate: IONCAMREditorResultsDelegate? { get set }

    /// Triggers the user interface that manages the editing a picture feature.
    /// - Parameters:
    ///   - image: Image to edit.
    ///   - handler: User interface handler, containing the view controller that should be added to the navigation stack.
    func editPicture(_ image: UIImage, _ handler: @escaping (UIViewController) -> Void)
}
