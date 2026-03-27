import UIKit

/// Interface that manages and handles the Capture a Picture user interface and interaction.
protocol IONCAMRPickerDelegate: AnyObject {
    typealias IONCAMRPickerResultsDelegate = IONCAMRCancelResultsDelegate & IONCAMRResultsDelegate
    var delegate: IONCAMRPickerResultsDelegate? { get set }

    /// Verifies if camera is available for usage.
    /// - Returns: The camera's availability
    func isCameraAvailable() -> Bool
    func captureMedia(with options: IONCAMRMediaOptions, _ handler: @escaping (UIViewController) -> Void)
}
