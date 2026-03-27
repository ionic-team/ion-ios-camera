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
        fetchResult.object(at: fetchResult.count - position - 1)
    }
}

extension IONCAMRPHFetchResultCollection {
    var startElement: PHAsset {
        fetchResult[startIndex]
    }

    var endElement: PHAsset {
        fetchResult[endIndex - 1]
    }
}
