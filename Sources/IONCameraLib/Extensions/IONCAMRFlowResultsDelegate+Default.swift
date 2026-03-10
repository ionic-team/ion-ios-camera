import Foundation

protocol IONCAMRFlowResultsHandler: IONCAMRFlowResultsDelegate {
    var responseDelegate: IONCAMRCallbackDelegate? { get }
}

extension IONCAMRFlowResultsHandler {
    func didReturn(_ result: Result<any Encodable, IONCAMRError>) {
        switch result {
        case .success(let value):
            do {
                if let mediaResult = value as? IONCAMRMediaResult {
                    let mediaResultText = try self.treatSingle(mediaResult)
                    self.responseDelegate?.callback(result: mediaResultText)
                } else if let mediaArray = value as? [IONCAMRMediaResult] {
                    let mediaArrayText = try self.treatMultiple(mediaArray)
                    self.responseDelegate?.callback(result: mediaArrayText)
                }
            } catch let error as IONCAMRError {
                self.responseDelegate?.callback(error: error)
            } catch {
                self.responseDelegate?.callback(error: .generalIssue)
            }
        case .failure(let error):
            self.responseDelegate?.callback(error: error)
        }
    }
    
    func didCancel(_ error: IONCAMRError) {
        self.responseDelegate?.callback(error: error)
    }
    
    private func encodeToStructure<T>(_ value: T) throws -> String where T: Encodable {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let mediaResultData = try? encoder.encode(value), let mediaResultText = String(data: mediaResultData, encoding: .utf8)
        else { throw IONCAMRError.invalidEncodeResultMedia }
        return mediaResultText
    }
    
    private func treatSingle(_ value: IONCAMRMediaResult) throws -> String {
        if case .picture = value.type, value.uri.isEmpty {
            return value.thumbnail
        }
        return try self.encodeToStructure(value)
    }
    
    private func treatMultiple(_ value: [IONCAMRMediaResult]) throws -> String {
        try self.encodeToStructure(value)
    }
}
