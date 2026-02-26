import Foundation

/// All plugin errors that can be thrown
public enum IONCAMRError: Int, CustomNSError, LocalizedError {
    // MARK: - Permissions Errors
    case cameraAccess = 3
    case cameraAvailability = 8
    
    // MARK: - Take Pictures Errors
    case takePictureIssue = 11
    case takePictureArguments = 15
    case takePictureCancel = 16
    
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
            return "Couldn't access camera. Check your camera permissions and try again."
            
        case .cameraAvailability:
            return "No camera available."
        case .takePictureIssue:
            return "Couldn't capture picture."
        case .takePictureArguments:
            return "Couldn't decode the 'Take Picture' action parameters."
        case .takePictureCancel:
            return "Couldn't capture picture because the process was canceled."
            
        case .invalidImageData:
            return "The selected file contains data that isn't valid."
        case .editPictureIssue:
            return "Couldn't edit image."
        case .editPictureCancel:
            return "Couldn't edit picture because the process was canceled."
            
        case .photoLibraryAccess:
            return "Couldn't access your photo gallery because access wasn't provided. Check its permissions and try again."
        case .imageNotFound:
            return "Couldn't get image from the gallery."
        case .choosePictureIssue:
            return "Couldn't process image."
        case .choosePictureCancel:
            return "Couldn't choose picture because the process was canceled."
            
        case .captureVideoIssue:
            return "Couldn't capture video."
        case .captureVideoCancel:
            return "Couldn't capture video because the process was canceled."
            
        case .videoNotFound:
            return "Couldn't get video from the gallery."
        case .chooseMultimediaIssue:
            return "Couldn't choose media from the gallery."
        case .chooseMultimediaCancel:
            return "Couldn't choose media from the gallery because the process was canceled."
        case .fetchImageFromURLFailed:
            return "Couldn't retrieve image from the URI."
            
        case .playVideoIssue:
            return "Couldn't play video."
            
        case .invalidEncodeResultMedia:
            return "Couldn't encode the media result."
        case .generalIssue:
            return "There's an issue with the plugin."
        }
    }
}
