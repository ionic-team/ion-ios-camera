import UIKit

final class IONCAMREditManager: NSObject {
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

extension IONCAMREditManager: IONCAMREditActionDelegate {
    func editPhoto(_ image: UIImage) {
        flow.editPhoto(image)
    }

    func editPhoto(with options: IONCAMRPhotoEditOptions) {
        flow.editPhoto(with: options)
    }
}

extension IONCAMREditManager: IONCAMRFlowResultsHandler {
    var responseDelegate: IONCAMRCallbackDelegate? {
        delegate
    }
}
