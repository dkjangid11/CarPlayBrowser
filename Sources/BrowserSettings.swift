import Foundation

/// Small wrapper around UserDefaults shared by the phone UI and the CarPlay scene.
enum BrowserSettings {
    static let defaultHomeURL = URL(string: "https://www.youtube.com")!

    private static let homeURLKey = "homeURL"
    private static let lastURLKey = "lastURL"

    /// The page CarPlay opens when there is no page to resume.
    static var homeURL: URL {
        get { storedURL(forKey: homeURLKey) ?? defaultHomeURL }
        set { UserDefaults.standard.set(newValue.absoluteString, forKey: homeURLKey) }
    }

    /// The last page that finished loading in CarPlay, restored on reconnect.
    static var lastURL: URL? {
        get { storedURL(forKey: lastURLKey) }
        set { UserDefaults.standard.set(newValue?.absoluteString, forKey: lastURLKey) }
    }

    /// Turns user input such as "youtube.com" into a valid http(s) URL, or nil if it isn't one.
    static func normalizedURL(from text: String) -> URL? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        let withScheme = trimmed.contains("://") ? trimmed : "https://" + trimmed
        guard let url = URL(string: withScheme),
              let scheme = url.scheme?.lowercased(),
              scheme == "http" || scheme == "https",
              let host = url.host, !host.isEmpty else { return nil }
        return url
    }

    private static func storedURL(forKey key: String) -> URL? {
        guard let string = UserDefaults.standard.string(forKey: key) else { return nil }
        return URL(string: string)
    }
}
