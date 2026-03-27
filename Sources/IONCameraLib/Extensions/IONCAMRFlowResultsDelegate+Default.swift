import Foundation

protocol IONCAMRFlowResultsHandler: IONCAMRFlowResultsDelegate {
    var responseDelegate: IONCAMRCallbackDelegate? { get }
}

extension IONCAMRFlowResultsHandler {
    func didReturn(_ result: Result<any Encodable, IONCAMRError>) {
        switch result {
        case .success(let value):
            if let mediaResult = value as? IONCAMRMediaResult {
                responseDelegate?.callback(result: mediaResult)
            } else if let mediaArray = value as? [IONCAMRMediaResult] {
                responseDelegate?.callback(result: mediaArray)
            }
        case .failure(let error):
            responseDelegate?.callback(error: error)
        }
    }

    func didCancel(_ error: IONCAMRError) {
        responseDelegate?.callback(error: error)
    }
}
