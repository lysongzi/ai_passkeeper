import Foundation

enum AccountFieldValidator {
    static func isValidEmail(_ value: String) -> Bool {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return true }

        let pattern = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
        return trimmed.range(of: pattern, options: [.regularExpression, .caseInsensitive]) != nil
    }

    static func isValidPhoneNumber(_ value: String) -> Bool {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return true }

        let cleaned = trimmed.replacingOccurrences(of: #"[\s\-\(\)]"#, with: "", options: .regularExpression)
        let allowed = CharacterSet(charactersIn: "+0123456789")

        return cleaned.count >= 6 &&
            cleaned.count <= 20 &&
            cleaned.unicodeScalars.allSatisfy(allowed.contains)
    }
}
