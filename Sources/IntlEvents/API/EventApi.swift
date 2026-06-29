import Foundation
import IntlWireFormat
import RequestResponse

public enum EventApi {
    /// Lists Intellect events in a time range.
    public static func list(
        from past: Date,
        to future: Date,
        limit: Int = 200,
        objectId: AccessPoint? = nil,
        action: String? = nil
    ) -> Request<[Event]> {
        var queryPairs: [(String, String)] = [
            ("count", String(limit)),
            ("from", Timestamp.formatEventQuery(past)),
            ("to", Timestamp.formatEventQuery(future)),
        ]

        if let objectId {
            queryPairs.append(("objectId", objectId))
        }
        if let action {
            queryPairs.append(("action", action))
        }

        let query = queryPairs
            .map { name, value in
                "\(Timestamp.percentEncodedQueryValue(name))=\(Timestamp.percentEncodedQueryValue(value))"
            }
            .joined(separator: "&")

        return Request(path: "secure/events?\(query)", method: .get, query: nil)
    }

    /// WebSocket descriptor for the live events feed.
    public static func feed() -> Request<Void> {
        Request(path: "secure/ws/events", method: .get, query: nil)
    }
}
