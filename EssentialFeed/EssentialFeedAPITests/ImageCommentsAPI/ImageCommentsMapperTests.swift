
import XCTest
import EssentialFeed
import EssentialFeedAPI

class ImageCommentsMapperTests: XCTestCase {
    
    func test_map_throwsErrorOnNon2xxHTTPResponse() throws {
        let json = makeItemsJSON([])
        let samples = [199, 150, 300, 400, 500]
        
        try samples.enumerated().forEach { index, code in
            XCTAssertThrowsError(
                try ImageCommentsMapper.map(json, response: HTTPURLResponse(statusCode: code))
            )
        }
    }
    
    func test_map_throwsErrorOnNon2xxHTTPResponseWithInvalidJSON() throws {
        let invalidJSON = Data("invalid json".utf8)
        let samples = [200, 201, 202, 250, 299]
        
        try samples.forEach { code in
            XCTAssertThrowsError(
                try ImageCommentsMapper.map(invalidJSON, response: HTTPURLResponse(statusCode: code))
            )
        }
    }
    
    func test_map_deliverNoItems2xxResponseWithEmptyJSON() throws {
        let emptyListJSON = makeItemsJSON([])
        let samples = [200, 201, 202, 250, 299]
        
        try samples.forEach { code in
            let result = try ImageCommentsMapper.map(emptyListJSON, response: HTTPURLResponse(statusCode: code))
            XCTAssertEqual(result, [])
        }
    }
    
    func test_map_deliverItems2xxResponseWithJSON() throws {
        let item1 = makeItem(
            id: UUID(),
            message: "a message",
            createdAt: (Date(timeIntervalSince1970: 1598627222), "2020-08-28T15:07:02+00:00"),
            username: "a username"
        )
        let item2 = makeItem(
            id: UUID(),
            message: "another message",
            createdAt: (Date(timeIntervalSince1970: 1577881882), "2020-01-01T12:31:22+00:00"),
            username: "another username")
        
        let items = [item1.model, item2.model]
        
        let samples = [200, 201, 202, 250, 299]
        let json = makeItemsJSON([item1.json, item2.json])
        
        try samples.forEach { code in
            let result = try ImageCommentsMapper.map(json, response: HTTPURLResponse(statusCode: code))
            XCTAssertEqual(result, items)
        }
    }
    
    // MARK: - Helpers
    
    private func makeItem(id: UUID, message: String, createdAt: (date: Date, iso8601String: String), username: String) -> (model: ImageComment, json: [String: Any] ) {
        let model = ImageComment(
            id: id,
            message: message,
            createdAt: createdAt.date,
            username: username
        )
        
        let json: [String: Any] = [
            "id": id.uuidString,
            "message": message,
            "created_at": createdAt.iso8601String,
            "author": [
                "username": username
            ]
        ]
        
        return (model: model, json: json)
    }
    
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let itemsJSON = ["items": items]
        let json = try! JSONSerialization.data(withJSONObject: itemsJSON)
        return json
    }
}
