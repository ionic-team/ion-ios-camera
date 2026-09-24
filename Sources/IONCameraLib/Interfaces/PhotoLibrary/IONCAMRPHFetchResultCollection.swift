import Photos

struct IONCAMRPHFetchResultCollection: RandomAccessCollection, Equatable {
    typealias Element = PHAsset
    typealias Index = Int

    var fetchResult: PHFetchResult<PHAsset>

    var endIndex: Int {
        fetchResult.count
    }

    var startIndex: Int {
        0
    }

    subscript(position: Int) -> PHAsset {
        fetchResult.object(at: position)
    }
}
