import Foundation
import IntlWireFormat

extension Event {
    public var params: [String] {
        [params0, params1, params2, params3]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
    }

    public var paramsDescription: String {
        params.reduce(into: "") { $0 += " \($1)" }
    }

    public func camIds() -> [AccessPoint] {
        camId?
            .split(separator: ",")
            .map { String($0).trimmingCharacters(in: .whitespaces) }
            ?? []
    }

    /// LPR plate text when `action == NUMBER_DETECTED`.
    public var plate: String? {
        guard action == "NUMBER_DETECTED" else { return nil }
        guard let params0 else { return nil }
        /// Note: bug in intl for utf8. param3 == "utf8", but inside .utf16LittleEndian same as for unicode
        guard ["unicode", "utf8"].contains(params3) else { return params0 }

        guard let data = Data(base64Encoded: params0) else { return params0 }
        return String(data: data, encoding: .utf16LittleEndian) ?? params0
    }

    /// Camera for snapshot/playback: first `camId`, else `objectId` when it is a camera AP.
    public var primaryCameraAccessPoint: AccessPoint? {
        if let first = camIds().first {
            return first
        }
        if objectId.hasPrefix("CAM:") {
            return objectId
        }
        return nil
    }

    /// Like ``primaryCameraAccessPoint``, then reverse `linkedObjects` lookup (e.g. ULPR → CAM).
    public func cameraAccessPoint(linkedObjectOwners: [AccessPoint: AccessPoint]) -> AccessPoint? {
        if let direct = primaryCameraAccessPoint {
            return direct
        }
        return linkedObjectOwners[objectId]
    }

    /// Subtitle for event cards: trimmed params when they are not already shown as plate.
    public var cardSubtitle: String? {
        let trimmedParams = paramsDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedParams.isEmpty else { return nil }
        if let plate, trimmedParams == plate { return nil }
        return trimmedParams
    }
}
