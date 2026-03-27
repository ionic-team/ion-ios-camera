import UIKit

final class IONCAMRCameraManager: NSObject {
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

extension IONCAMRCameraManager: IONCAMRCameraActionDelegate {
    func takePhoto(with options: IONCAMRTakePhotoOptions) {
        flow.takePhoto(with: options)
    }

    func recordVideo(with options: IONCAMRRecordVideoOptions) {
        flow.recordVideo(with: options)
    }

    func cleanTemporaryFiles() {
        flow.cleanTemporaryFiles()
    }
}

extension IONCAMRCameraManager: IONCAMRFlowResultsHandler {
    var responseDelegate: IONCAMRCallbackDelegate? {
        delegate
    }
}
