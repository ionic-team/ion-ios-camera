import UIKit

protocol IONCAMRCancelResultsDelegate: AnyObject {
    /// Method triggered when the behaviour's interaction ended with the user cancelling it.
    /// - Parameter object: Behaviour that triggered the operation`
    func didCancel(_ object: AnyObject)
}

protocol IONCAMRMultipleResultsDelegate: AnyObject {
    func didReturn(_ result: Result<[IONCAMRMediaResult], IONCAMRError>)
}

protocol IONCAMRResultsDelegate: AnyObject {
    func didReturn(_ object: AnyObject, with result: Result<IONCAMRResultItem, IONCAMRError>) async
}

enum IONCAMRResultItem {
    case picture(_ image: UIImage)
    case video(_ url: URL)
}
