
import Foundation

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> ()
    typealias InsertionCompletion = (Error?) -> ()
    
    func deleteCachedFeed(completion: @escaping(DeletionCompletion))
    func insert(_ items: [FeedItem], timestamp: Date, completion: @escaping (Error?) -> ())
}
