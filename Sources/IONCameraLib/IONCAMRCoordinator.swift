import UIKit

/// Object responsible for managing the screen flow, in response to the user's interaction.
class IONCAMRCoordinator {
    /// Root view controller, from whom every view gets pushed on top of.
    private let rootViewController: UIViewController
    /// Contains all the views that were added to the coordinator.
    private var currentlyPresentedViewControllerArray: [UIViewController]
    
    /// Indicates if the user is currently on a multiple step screen.
    var isSecondStep: Bool {
        self.currentlyPresentedViewControllerArray.count > 1
    }
    
    /// Constructor.
    /// - Parameter rootViewController: Root view of the plugin.
    init(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
        self.currentlyPresentedViewControllerArray = []
    }
    
    /// Presents the passed view controller, adding it to the currently presented view controller array.
    /// - Parameter viewController: New view controller to present.
    func present(_ viewController: UIViewController) {
        let presentedViewController = self.currentlyPresentedViewControllerArray.last ?? self.rootViewController
        if (viewController.modalPresentationStyle == UIModalPresentationStyle.popover) {
            viewController.popoverPresentationController?.sourceRect = CGRectMake(presentedViewController.view.center.x, presentedViewController.view.center.y, 0, 0);
            viewController.popoverPresentationController?.sourceView = presentedViewController.view;
            viewController.popoverPresentationController?.permittedArrowDirections = [];

        }
        presentedViewController.present(viewController, animated: true)
        self.currentlyPresentedViewControllerArray.append(viewController)
    }
    
    /// Dismisses the currently presented view controllers. In case of a multiple step screen, all are dismissed.
    func dismiss() {
        self.rootViewController.dismiss(animated: true)
        self.currentlyPresentedViewControllerArray.removeAll()
    }
}
