/// Triggers the results of interacting with the `IONCAMRFlowDelegate`implementation's behaviour objects (picker, edit, gallery).
protocol IONCAMRFlowResultsDelegate: AnyObject {
    /// Method triggered when the user could finish, with or without success, the behaviour.
    /// - Parameter result: Returned object to who implements this object. It returns a base64 encoding text if successful or an error otherwise.
    func didReturn(_ result: Result<any Encodable, IONCAMRError>)
    /// Method triggered when the behaviour's interaction ended with the user cancelling it.
    /// - Parameter error: Error associated with the cancelled action.
    func didCancel(_ error: IONCAMRError)
}

extension IONCAMRFlowResultsDelegate {
    func didFailed(type: any Encodable.Type, with error: IONCAMRError) {
        let result: Result<any Encodable, IONCAMRError> = .failure(error)
        didReturn(result)
    }

    func didSucceed(with result: any Encodable) {
        didReturn(.success(result))
    }
}
