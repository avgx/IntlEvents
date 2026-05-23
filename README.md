# IntlEvents

Swift package for event listing and event helpers. HTTP descriptors use [RequestResponse](https://github.com/avgx/RequestResponse); wire types (`Event`, `AccessPoint`, `Timestamp`) come from [IntlWireFormat](https://github.com/avgx/IntlWireFormat).

For topology and cameras, see [IntlConfiguration](https://github.com/avgx/IntlConfiguration).

## Project layout

```
Sources/IntlEvents/
├── API/              EventApi
└── Event/            Event+Extensions (params, camIds, plate)

Tests/IntlEventsTests/
├── Resources/        JSON fixtures
└── IntlEventsTests.swift
```

## Requirements

- Swift 6.1+
- iOS 15+, macOS 13+, tvOS 17+, visionOS 1+

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/avgx/IntlEvents", from: "1.0.0"),
],
targets: [
    .target(name: "MyApp", dependencies: ["IntlEvents"]),
]
```

Also add **RequestResponse** and your HTTP client in the app target.

## Quick start

```swift
import IntlEvents
import IntlWireFormat
import RequestResponse

let events: [Event] = try await http.send(
    EventApi.list(
        from: past,
        to: now,
        limit: 200,
        objectId: "CAM:1",
        action: "MOTION"
    )
).value

for event in events {
    print(event.text, event.camIds())
    if let plate = event.plate { print(plate) }
}
```

## HTTP API descriptors

| Enum | Method | Path |
|------|--------|------|
| `EventApi` | `list(from:to:limit:objectId:action:)` | `GET secure/events` |

Query uses `Timestamp.utc` for `from` / `to`. Login and password are not included — use Basic Auth at the HTTP layer.

## Event helpers

| Property / method | Description |
|-------------------|-------------|
| `params` | Non-empty `params0`…`params3` values |
| `paramsDescription` | Space-joined params |
| `camIds()` | `camId` split by comma into `[AccessPoint]` |
| `plate` | LPR plate when `action == NUMBER_DETECTED` (utf-8 plain or base64 utf-16LE) |

## Tests

```bash
swift test
```

Fixtures under `Tests/IntlEventsTests/Resources/`.

## License

See [LICENSE](LICENSE).
