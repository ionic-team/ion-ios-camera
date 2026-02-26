import Foundation

protocol IONCAMRURLGeneratorDelegate: AnyObject {
    func url(for imageData: Data, withEncodingType encodingType: IONCAMREncodingType?) -> URL?
}
