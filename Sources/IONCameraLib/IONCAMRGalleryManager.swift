import UIKit

final class IONCAMRGalleryManager: NSObject {
    private weak var delegate: IONCAMRCallbackDelegate?
    private let flow: IONCAMRFlowDelegate

    init(delegate: IONCAMRCallbackDelegate, flow: IONCAMRFlowDelegate) {
        self.delegate = delegate
        self.flow = flow
        super.init()
        self.flow.delegate = self
    }

    convenience init(delegate: IONCAMRCallbackDelegate, viewController: UIViewController) {
        let coordinator = IONCAMRCoordinator(rootViewController: viewController)
        let flowBehaviour = IONCAMRFlowBehaviour(coordinator: coordinator)

        self.init(delegate: delegate, flow: flowBehaviour)
    }
}

extension IONCAMRGalleryManager: IONCAMRGalleryActionDelegate {
    func chooseFromGallery(with options: IONCAMRGalleryOptions) {
        flow.chooseFromGallery(with: options)
    }
}

extension IONCAMRGalleryManager: IONCAMRFlowResultsHandler {
    var responseDelegate: IONCAMRCallbackDelegate? {
        delegate
    }
}
