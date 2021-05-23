
import XCTest
import EssentialFeed
import EssentialFeedAPI

class FeedItemsMapperTests: XCTestCase {
    
    func test_map_throwsErrorOnNon200HTTPResponse() throws {
        let json = makeItemsJSON([])
        let samples = [199, 201, 300, 400, 500]
        
        try samples.forEach { code in
            XCTAssertThrowsError(
                try FeedItemsMapper.map(json, response: HTTPURLResponse(statusCode: code))
            )
        }
    }
    
    func test_map_throwsErrorOn200ResponseWithInvalidJSON() {
        let invalidJSON = Data("invalid json".utf8)
        
        XCTAssertThrowsError(
            try FeedItemsMapper.map(invalidJSON, response: HTTPURLResponse(statusCode: 200))
        )
    }
    
    func test_map_deliverNoItems200ResponseWithEmptyJSON() throws {
        let emptyListJSON = makeItemsJSON([])
        
        let result = try FeedItemsMapper.map(emptyListJSON, response: HTTPURLResponse(statusCode: 200))
        
        XCTAssertEqual(result, [])
    }
    
    func test_map_deliverItems200ResponseWithJSON() throws {
        let item1 = makeItem(id: UUID(), description: nil, location: nil, imageURL: URL(string: "https://any.com")!)
        let item2 = makeItem(id: UUID(), description: "some description", location: "some location", imageURL: URL(string: "https://any2.com")!)
        
        let items = [item1.model, item2.model]
        let json = makeItemsJSON([item1.json, item2.json])
        
        let result = try FeedItemsMapper.map(json, response: HTTPURLResponse(statusCode: 200))
        XCTAssertEqual(result, items)
    }
    
    // MARK: - Helpers
    
    private func makeItem(id: UUID, description: String?, location: String?, imageURL: URL) -> (model: FeedImage, json: [String: Any] ) {
        let model = FeedImage(
            id: id,
            description: description,
            location: location,
            url: imageURL
        )
        
        let json = [
            "id": model.id.uuidString,
            "description": model.description,
            "location": model.location,
            "image": model.url.absoluteString,
        ].compactMapValues { $0 }
        
        return (model: model, json: json)
    }
}
