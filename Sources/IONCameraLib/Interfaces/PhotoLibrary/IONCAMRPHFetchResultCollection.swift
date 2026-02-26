import Photos

struct IONCAMRPHFetchResultCollection: RandomAccessCollection, Equatable {
    typealias Element = PHAsset
    typealias Index = Int
    
    var fetchResult: PHFetchResult<PHAsset>
    
    var endIndex: Int { self.fetchResult.count }
    var startIndex: Int { 0 }
    
    subscript(position: Int) -> PHAsset {
        self.fetchResult.object(at: self.fetchResult.count - position - 1)
    }
}

extension IONCAMRPHFetchResultCollection {
    var startElement: PHAsset { self.fetchResult[self.startIndex] }
    var endElement: PHAsset { self.fetchResult[self.endIndex - 1] }
}
