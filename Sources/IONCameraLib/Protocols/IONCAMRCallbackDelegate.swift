/// Delegate for the callback return calls for the plugin
public protocol IONCAMRCallbackDelegate: AnyObject {
    func callback(error: IONCAMRError)
    func callback(result: IONCAMRMediaResult)
    func callback(result: [IONCAMRMediaResult])
}
