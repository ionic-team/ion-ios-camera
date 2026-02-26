@testable import OSCameraLib

class IONCAMRFlowResultsDelegateMock: IONCAMRFlowResultsDelegate {
    var resultArray: [IONCAMRMediaResult]?
    var resultSingle: IONCAMRMediaResult?
    var error: IONCAMRError?
    var wasCancelled: Bool = false
    
    func didReturn(_ result: Result<Encodable, IONCAMRError>) {
        switch result {
        case .success(let value):
            self.resultArray = value as? [IONCAMRMediaResult]
            self.resultSingle = value as? IONCAMRMediaResult
        case .failure(let error):
            self.error = error
        }
    }
    
    func didCancel(_ error: IONCAMRError) {
        self.wasCancelled = true
    }
}
