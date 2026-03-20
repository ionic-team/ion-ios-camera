/// Format for the resulting encoded image.
public enum IONCAMREncodingType: Int, Decodable, CustomStringConvertible {
    case jpeg = 0
    case png
    
    public var description: String {
        switch self {
        case .jpeg: return "jpeg"
        case .png: return "png"
        }
    }
}
