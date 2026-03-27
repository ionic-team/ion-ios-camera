import Foundation

/// All plugin errors that can be thrown
public enum IONCAMRError: Int, CustomNSError, LocalizedError {
    // MARK: - Permissions Errors

    case cameraAccess = 3
    case cameraAvailability = 8

    // MARK: - Take Pictures Errors

    case takePictureCancel = 7
    case takePictureIssue = 11
    case takePictureArguments = 15

    // MARK: - Edit Picture Errors

    case invalidImageData = 9
    case editPictureIssue = 10
    case editPictureCancel = 14

    // MARK: - Choose Picture Errors

    case photoLibraryAccess = 6
    case imageNotFound = 12
    case choosePictureIssue = 13
    case choosePictureCancel = 20

    // MARK: - Capture Video Errors

    case captureVideoIssue = 18
    case captureVideoCancel = 19

    // MARK: - Choose Multimedia Errors

    case videoNotFound = 28
    case chooseMultimediaIssue = 21
    case chooseMultimediaCancel = 23
    case fetchImageFromURLFailed = 31

    // MARK: - Play Video Errors

    case playVideoIssue = 26

    // MARK: - General Errors

    case invalidEncodeResultMedia = 22
    case generalIssue = 29

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
            "Couldn't decode the 'Take Picture' action parameters."
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
        case .choosePictureCancel:
            "Couldn't choose picture because the process was canceled."
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
        case .invalidEncodeResultMedia:
            "Couldn't encode the media result."
        case .generalIssue:
            "There's an issue with the plugin."
        }
    }
}
