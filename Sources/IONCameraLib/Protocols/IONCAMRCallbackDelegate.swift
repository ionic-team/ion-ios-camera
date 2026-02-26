/// Delegate for the callback return calls for the plugin
public protocol IONCAMRCallbackDelegate: AnyObject {
    /// Callback to be triggered.
    /// - Parameters:
    ///   - result: The text to be returned in case of success.
    ///   - error: The error to be returned in case of error.
    func callback(result: String?, error: IONCAMRError?)
}

/// Provides accelerators for callbacks.
extension IONCAMRCallbackDelegate {
    /// Triggers the callback when there's an error
    /// - Parameter error: Error to be thrown
    func callback(error: IONCAMRError) {
        self.callback(result: nil, error: error)
    }
    
    /// Triggers the callback when there's a success text
    /// - Parameter result: Text to be returned
    func callback(result: String) {
        self.callback(result: result, error: nil)
    }
}
