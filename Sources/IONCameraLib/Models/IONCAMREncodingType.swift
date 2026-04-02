/// Format for the resulting encoded image.
public enum IONCAMREncodingType: Int, Decodable, CustomStringConvertible {
    case jpeg = 0
    case png

    public var description: String {
        switch self {
        case .jpeg: "jpg"
        case .png: "png"
        }
    }
}
