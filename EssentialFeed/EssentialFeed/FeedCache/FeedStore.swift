
import Foundation

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> ()
    typealias InsertionCompletion = (Error?) -> ()
    
    func deleteCachedFeed(completion: @escaping(DeletionCompletion))
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping (Error?) -> ())
}
