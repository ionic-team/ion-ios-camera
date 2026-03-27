import SwiftUI
import UIKit

final class IONCAMREditorBehaviour: NSObject, IONCAMREditorDelegate {
    weak var delegate: IONCAMREditorResultsDelegate?

    func editPicture(_ image: UIImage, _ handler: @escaping (UIViewController) -> Void) {
        DispatchQueue.main.async {
            let isPortrait = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation.isPortrait ?? false
            let imageEditorView = IONCAMRImageEditorView(delegate: self, image: image, isPortrait: isPortrait)
            let viewController = UIHostingController(rootView: imageEditorView)
            viewController.modalPresentationStyle = .fullScreen
            handler(viewController)
        }
    }
}

extension IONCAMREditorBehaviour: IONCAMRImageEditorResultsDelegate {
    /// Method triggered when the user could finish, with or without success, the editing screen.
    /// - Parameters:
    ///   - result: Resulting image.
    ///   - error: Error occurred during the edit.
    func finishEditing(_ result: UIImage?, error: IONCAMRError?) async {
        if let image = result {
            await delegate?.didReturn(self, with: .success(.picture(image)))
        } else {
            await delegate?.didReturn(self, with: .failure(.editPictureIssue))
        }
    }

    /// Method triggered when the screen's interaction ended with the user cancelling it.
    func didCancelEdit() {
        delegate?.didCancel(self)
    }
}

protocol IONCAMRImageEditorResultsDelegate: AnyObject {
    func finishEditing(_ result: UIImage?, error: IONCAMRError?) async
    func didCancelEdit()
}

extension IONCAMRImageEditorResultsDelegate {
    func finishEditing(with result: UIImage) async {
        await finishEditing(result, error: nil)
    }

    func finishEditing(with error: IONCAMRError) async {
        await finishEditing(nil, error: error)
    }
}
