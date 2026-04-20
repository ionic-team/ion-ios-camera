@testable import IONCameraLibCore

class IONCAMRFlowResultsDelegateMock: IONCAMRFlowResultsDelegate {
    var resultArray: [IONCAMRMediaResult]?
    var resultSingle: IONCAMRMediaResult?
    var error: IONCAMRError?
    var wasCancelled = false

    private var continuation: CheckedContinuation<Void, Never>?

    func didReturn(_ result: Result<Encodable, IONCAMRError>) {
        switch result {
        case .success(let value):
            resultArray = value as? [IONCAMRMediaResult]
            resultSingle = value as? IONCAMRMediaResult
        case .failure(let error):
            self.error = error
        }
        continuation?.resume()
        continuation = nil
    }

    func didCancel(_ error: IONCAMRError) {
        wasCancelled = true
        continuation?.resume()
        continuation = nil
    }

    func waitForResult() async {
        guard resultSingle == nil, resultArray == nil, error == nil, !wasCancelled else { return }
        await withCheckedContinuation { self.continuation = $0 }
    }
}
