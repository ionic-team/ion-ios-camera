import Foundation

extension Data {
    func createImageTemporaryPath(with pathExtension: String? = nil) throws -> URL {
        let imageURL = URL.tempFilePath(for: .picture, with: pathExtension ?? self.fileExtension)
        try self.write(to: imageURL)
        return imageURL
    }
}

private extension Data {
    static let jpegMimeTypeSignature: String = "image/jpeg"
    static let pngMimeTypeSignature: String = "image/png"
    
    static let mimeTypeSignatures: [UInt8: String] = [
        0xFF: Self.jpegMimeTypeSignature,
        0x89: Self.pngMimeTypeSignature
    ]
    
    var mimeType: String {
        var bytes: UInt8 = 0
        copyBytes(to: &bytes, count: 1)
        return Self.mimeTypeSignatures[bytes] ?? "application/octet-stream"
    }
    
    var fileExtension: String {
        switch self.mimeType {
        case Self.jpegMimeTypeSignature: return IONCAMREncodingType.jpeg.description
        case Self.pngMimeTypeSignature: return IONCAMREncodingType.png.description
        default: return "unknown"
        }
    }
}
