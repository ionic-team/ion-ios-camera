import UIKit

final class IONCAMRGalleryManager: NSObject {
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

extension IONCAMRGalleryManager: IONCAMRGalleryActionDelegate {    
    func editPicture(_ image: UIImage) {
        self.flow.editPicture(image)
    }
    
    func editPicture(from urlString: String, with options: IONCAMREditOptions) {
        self.flow.editPicture(from: urlString, with: options)
    }
    
    func chooseFromGallery(with options: IONCAMRGalleryOptions) {
        self.flow.chooseFromGallery(with: options)
    }
}

extension IONCAMRGalleryManager: IONCAMRFlowResultsDelegate {
    func didReturn(_ result: Result<any Encodable, IONCAMRError>) {
        switch result {
        case .success(let value):
            do {
                if let mediaResult = value as? IONCAMRMediaResult {
                    let mediaResultText = try self.treatSingle(mediaResult)
                    self.delegate?.callback(result: mediaResultText)
                } else if let mediaArray = value as? [IONCAMRMediaResult] {
                    let mediaArrayText = try self.treatMultiple(mediaArray)
                    self.delegate?.callback(result: mediaArrayText)
                }
            } catch let error as IONCAMRError {
                self.delegate?.callback(error: error)
            } catch {
                self.delegate?.callback(error: .generalIssue)
            }
        case .failure(let error):
            self.delegate?.callback(error: error)
        }
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
    
    func didCancel(_ error: IONCAMRError) {
        self.delegate?.callback(error: error)
    }
}
