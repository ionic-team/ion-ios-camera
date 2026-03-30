import Foundation

/// All plugin errors that can be thrown
public enum IONCAMRError: Int, CustomNSError, LocalizedError {
    // MARK: - Permissions Errors

    case cameraAccess = 3
    case cameraAvailability = 7

    // MARK: - Take Pictures Errors

    case takePictureCancel = 6
    case takePictureIssue = 10
    case takePictureArguments = 14

    // MARK: - Edit Picture Errors

    case invalidImageData = 8
    case editPictureIssue = 9
    case editPictureCancel = 13

    // MARK: - Choose Picture Errors

    case photoLibraryAccess = 5
    case imageNotFound = 11
    case choosePictureIssue = 12

    // MARK: - Capture Video Errors

    case captureVideoIssue = 16
    case captureVideoCancel = 17

    // MARK: - Choose Multimedia Errors

    case videoNotFound = 25
    case chooseMultimediaIssue = 18
    case chooseMultimediaCancel = 20
    case fetchImageFromURLFailed = 28

    // MARK: - Play Video Errors

    case playVideoIssue = 23

    // MARK: - General Errors

    case invalidEncodeResultMedia = 19
    case generalIssue = 26
    case fileNotFound = 27

    /// Textual description
    public var errorDescription: String? {
        switch self {
        case .cameraAccess:
            "Couldn't access camera. Check your camera permissions and try again."
        case .cameraAvailability:
            "No camera available."
        case .takePictureIssue:
            "Couldn't take photo."
        case .takePictureArguments:
            "Couldn't decode the 'Take Photo' action parameters."
        case .takePictureCancel:
            "Couldn't take photo because the process was canceled."
        case .invalidImageData:
            "The selected file contains data that isn't valid."
        case .editPictureIssue:
            "Couldn't edit image."
        case .editPictureCancel:
            "Couldn't edit photo because the process was canceled."
        case .photoLibraryAccess:
            "Couldn't access your photo gallery because access wasn't provided. Check its permissions and try again."
        case .imageNotFound:
            "Couldn't get image from the gallery."
        case .choosePictureIssue:
            "Couldn't process image."
        case .captureVideoIssue:
            "Couldn't record video."
        case .captureVideoCancel:
            "Couldn't record video because the process was canceled."
        case .videoNotFound:
            "Couldn't get video from the gallery."
        case .chooseMultimediaIssue:
            "Couldn't choose media from the gallery."
        case .chooseMultimediaCancel:
            "Couldn't choose media from the gallery because the process was canceled."
        case .fetchImageFromURLFailed:
            "Couldn't retrieve image from the URI."
        case .playVideoIssue:
            "Couldn't play video."
        case .fileNotFound:
            "The selected file doesn't exist."
        case .invalidEncodeResultMedia:
            "Couldn't encode the media result."
        case .generalIssue:
            "There's an issue with the plugin."
        }
    }
}
