import Foundation

let videosDirectoryName = "ion_ios_camera_videos"

extension URL {
    func createVideoTemporaryPath(_ deleteTemporaryItem: Bool = true) throws -> URL {
        let copyMovieURL = URL.tempFilePath(for: .video, with: pathExtension)
        try FileManager.default.copyItem(at: self, to: copyMovieURL)
        if deleteTemporaryItem {
            try? deleteTemporaryPath(alongWithThumbnail: true)
        }
        return copyMovieURL
    }

    func createVideoPermanentPath(_ deleteTemporaryItem: Bool = true) throws -> URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let videosDir = documentsURL.appendingPathComponent(videosDirectoryName, isDirectory: true)

        // Ensure videos directory exists
        if !FileManager.default.fileExists(atPath: videosDir.path) {
            try FileManager.default.createDirectory(at: videosDir, withIntermediateDirectories: true)
        }

        let timestampMillis = Int64(Date().timeIntervalSince1970 * 1000)
        let permanentURL = videosDir
            .appendingPathComponent("video_\(timestampMillis)")
            .appendingPathExtension(pathExtension)

        try FileManager.default.copyItem(at: self, to: permanentURL)

        if deleteTemporaryItem {
            try? deleteTemporaryPath(alongWithThumbnail: true)
        }
        return permanentURL
    }

    func deleteTemporaryPath(alongWithThumbnail: Bool = false) throws {
        try FileManager.default.removeItem(at: self)
        if alongWithThumbnail { // recorded videos also generate a 'largeThumbnail' file that also needs to be removed
            var thumbnailComponents = absoluteString.split(separator: ".")
            thumbnailComponents.removeLast()
            thumbnailComponents.append("largeThumbnail")
            if let thumbnailURL = URL(string: thumbnailComponents.joined(separator: ".")) {
                try FileManager.default.removeItem(at: thumbnailURL)
            }
        }
    }

    static func tempFilePath(for mediaType: IONCAMRMediaType, with pathExtension: String) -> URL {
        let timestampMillis = Int64(Date().timeIntervalSince1970 * 1000)
        return URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .standardizedFileURL
            .appendingPathComponent("\(mediaType.description)_\(timestampMillis)")
            .appendingPathExtension(pathExtension)
    }
}

extension URL {
    var metadata: (date: Date, fileSize: UInt64)? {
        guard let resources = try? resourceValues(forKeys: [.creationDateKey, .fileSizeKey]),
              let date = resources.creationDate, let fileSize = resources.fileSize
        else { return nil }
        return (date, UInt64(fileSize))
    }
}
