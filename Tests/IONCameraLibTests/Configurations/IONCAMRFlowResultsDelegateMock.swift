@testable import IONCameraLib

class IONCAMRFlowResultsDelegateMock: IONCAMRFlowResultsDelegate {
    var resultArray: [IONCAMRMediaResult]?
    var resultSingle: IONCAMRMediaResult?
    var error: IONCAMRError?
    var wasCancelled: Bool = false

    private var continuation: CheckedContinuation<Void, Never>?

    func didReturn(_ result: Result<Encodable, IONCAMRError>) {
        switch result {
        case .success(let value):
            self.resultArray = value as? [IONCAMRMediaResult]
            self.resultSingle = value as? IONCAMRMediaResult
        case .failure(let error):
            self.error = error
        }
        self.continuation?.resume()
        self.continuation = nil
    }

    func didCancel(_ error: IONCAMRError) {
        self.wasCancelled = true
        self.continuation?.resume()
        self.continuation = nil
    }

    func waitForResult() async {
        guard resultSingle == nil, resultArray == nil, error == nil, !wasCancelled else { return }
        await withCheckedContinuation { self.continuation = $0 }
    }
}
