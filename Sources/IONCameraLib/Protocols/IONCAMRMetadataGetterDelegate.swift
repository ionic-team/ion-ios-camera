import UIKit

protocol IONCAMRMetadataGetterDelegate: AnyObject {
    func getVideoMetadata(from url: URL) async throws -> IONCAMRMetadata
    func getImageMetadata(from image: UIImage, and url: URL) throws -> IONCAMRMetadata
}
