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
        var query: [(String, String?)] = [
            ("count", String(limit)),
            ("from", Timestamp.utc.string(from: past)),
            ("to", Timestamp.utc.string(from: future)),
        ]

        if let objectId {
            query.append(("objectId", objectId))
        }
        if let action {
            query.append(("action", action))
        }

        return Request(path: "secure/events", method: .get, query: query)
    }
}
