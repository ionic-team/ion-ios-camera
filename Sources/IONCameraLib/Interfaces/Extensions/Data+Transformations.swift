import Foundation

extension Data {
    func createImageTemporaryPath(with pathExtension: String? = nil) throws -> URL {
        let imageURL = URL.tempFilePath(for: .picture, with: pathExtension ?? fileExtension)
        try write(to: imageURL)
        return imageURL
    }
}

extension Data {
    fileprivate static let jpegMimeTypeSignature = "image/jpeg"
    fileprivate static let pngMimeTypeSignature = "image/png"

    fileprivate static let mimeTypeSignatures: [UInt8: String] = [
        0xFF: Self.jpegMimeTypeSignature,
        0x89: Self.pngMimeTypeSignature
    ]

    private var mimeType: String {
        var bytes: UInt8 = 0
        copyBytes(to: &bytes, count: 1)
        return Self.mimeTypeSignatures[bytes] ?? "application/octet-stream"
    }

    private var fileExtension: String {
        switch mimeType {
        case Self.jpegMimeTypeSignature: IONCAMREncodingType.jpeg.description
        case Self.pngMimeTypeSignature: IONCAMREncodingType.png.description
        default: "unknown"
        }
    }
}
