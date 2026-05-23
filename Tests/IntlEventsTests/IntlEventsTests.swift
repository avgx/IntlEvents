import Foundation
import Testing
import IntlWireFormat
@testable import IntlEvents

enum FixtureSupport {
    static func decode<T: Decodable>(_ name: String) throws -> T {
        guard let url = Bundle.module.url(forResource: name, withExtension: "json") else {
            throw NSError(domain: "Fixture", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing \(name).json"])
        }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(T.self, from: data)
    }
}

@Test func decodesBasicEvents() throws {
    let events: [Event] = try FixtureSupport.decode("events-basic")
    #expect(events.count == 1)
    #expect(events[0].text == "Test event")
    #expect(events[0].objectId == "CAM:1")
}

@Test func decodesEventsMissingTimestamp() throws {
    let events: [Event] = try FixtureSupport.decode("events-missing-ts")
    #expect(events[0].ts == nil)
}

@Test func lprPlateDecoding() throws {
    let events: [Event] = try FixtureSupport.decode("events-lpr-plate")
    #expect(events[0].plate == "A123BC")
}

@Test func eventApiQueryIncludesFilters() {
    let past = Date(timeIntervalSince1970: 0)
    let future = Date(timeIntervalSince1970: 86_400)
    let request = EventApi.list(
        from: past,
        to: future,
        limit: 50,
        objectId: "CAM:1",
        action: "MOTION"
    )

    #expect(request.path == "secure/events")
    #expect(request.query?.contains(where: { $0.0 == "objectId" && $0.1 == "CAM:1" }) == true)
    #expect(request.query?.contains(where: { $0.0 == "action" && $0.1 == "MOTION" }) == true)
    #expect(request.query?.contains(where: { $0.0 == "count" && $0.1 == "50" }) == true)
}
