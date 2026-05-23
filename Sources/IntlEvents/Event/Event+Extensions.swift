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
        guard params3 != "utf8" else { return params0 }

        guard let data = Data(base64Encoded: params0) else { return params0 }
        return String(data: data, encoding: .utf16LittleEndian) ?? params0
    }
}
