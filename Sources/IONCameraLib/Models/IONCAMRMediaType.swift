public struct IONCAMRMediaType: OptionSet {
    public typealias RawValue = Int

    public var rawValue: RawValue

    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }

    public static let picture = Self(rawValue: 1 << 0)
    public static let video = Self(rawValue: 1 << 1)
    public static let both: IONCAMRMediaType = [.picture, .video]
}

extension IONCAMRMediaType {
    enum IONCAMRMediaTypeEnum: Int {
        case picture = 0
        case video
        case both
    }

    enum IONCAMRMediaTypeError: Error {
        case unknownType
    }

    var enumerator: IONCAMRMediaTypeEnum {
        get throws {
            switch self {
            case .picture: return .picture
            case .video: return .video
            case .both: return .both
            default: throw IONCAMRMediaTypeError.unknownType
            }
        }
    }

    public init(from enumValue: Int) throws {
        guard let enumerator = IONCAMRMediaTypeEnum(rawValue: enumValue) else { throw IONCAMRMediaTypeError.unknownType }

        switch enumerator {
        case .picture: self = .picture
        case .video: self = .video
        case .both: self = .both
        }
    }
}

extension IONCAMRMediaType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .picture: "image"
        case .video: "video"
        default: ""
        }
    }
}
