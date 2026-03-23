import Foundation

protocol IONCAMRFlowResultsHandler: IONCAMRFlowResultsDelegate {
    var responseDelegate: IONCAMRCallbackDelegate? { get }
}

extension IONCAMRFlowResultsHandler {
    func didReturn(_ result: Result<any Encodable, IONCAMRError>) {
        switch result {
        case .success(let value):
            if let mediaResult = value as? IONCAMRMediaResult {
                self.responseDelegate?.callback(result: mediaResult)
            } else if let mediaArray = value as? [IONCAMRMediaResult] {
                self.responseDelegate?.callback(result: mediaArray)
            }
        case .failure(let error):
            self.responseDelegate?.callback(error: error)
        }
    }
    
    func didCancel(_ error: IONCAMRError) {
        self.responseDelegate?.callback(error: error)
    }
}
