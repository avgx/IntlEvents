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
    #expect(events[0].timestamp != nil)
}

@Test func decodesEventsMissingTimestamp() throws {
    let events: [Event] = try FixtureSupport.decode("events-missing-ts")
    #expect(events[0].ts == nil)
    #expect(events[0].timestamp == nil)
}

@Test func lprPlateDecoding() throws {
    let events: [Event] = try FixtureSupport.decode("events-lpr-plate")
    #expect(events[0].plate == "A123BC")
}

@Test func lprPlateDecodingUtf8() throws {
    let events: [Event] = try FixtureSupport.decode("events-lpr-plate-utf8")
    #expect(events[0].plate == "A9999999")
}

@Test func lprPlateDecodingUnicode() throws {
    let events: [Event] = try FixtureSupport.decode("events-lpr-plate-unicode")
    #expect(events[0].plate == "A9999999")
}

@Test func cameraAccessPointUsesLinkedObjectOwner() {
    let event = Event(
        id: "{1}",
        objectId: "ULPR:1",
        text: "LP recognized",
        action: "NUMBER_DETECTED",
        camId: ""
    )
    let owners = ["ULPR:1": "CAM:1"]
    #expect(event.cameraAccessPoint(linkedObjectOwners: owners) == "CAM:1")
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

    #expect(request.query == nil)
    #expect(request.path.hasPrefix("secure/events?"))
    #expect(request.path.contains("objectId=CAM:1"))
    #expect(request.path.contains("action=MOTION"))
    #expect(request.path.contains("count=50"))
    #expect(request.path.contains("from=\(Timestamp.percentEncodedQueryValue(Timestamp.formatEventQuery(past)))"))
    #expect(request.path.contains("to=\(Timestamp.percentEncodedQueryValue(Timestamp.formatEventQuery(future)))"))
}

@Test func eventApiFeedPath() {
    let request = EventApi.feed()
    #expect(request.path == "secure/ws/events")
    #expect(request.method == .get)
}

@Test func primaryCameraAccessPointPrefersCamId() {
    let event = Event(
        id: "{1}",
        objectId: "ULPR:1",
        text: "Plate",
        action: "NUMBER_DETECTED",
        camId: "CAM:2"
    )
    #expect(event.primaryCameraAccessPoint == "CAM:2")
}

@Test func primaryCameraAccessPointFallsBackToObjectId() {
    let event = Event(
        id: "{2}",
        objectId: "CAM:1",
        text: "Motion"
    )
    #expect(event.primaryCameraAccessPoint == "CAM:1")
}

@Test func cardSubtitleSkipsDuplicatePlate() throws {
    let events: [Event] = try FixtureSupport.decode("events-lpr-plate")
    #expect(events[0].plate == "A123BC")
    #expect(events[0].cardSubtitle == nil)
}
