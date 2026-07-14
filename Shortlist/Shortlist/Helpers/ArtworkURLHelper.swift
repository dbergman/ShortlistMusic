import Foundation

enum ArtworkURLHelper {
    private static let fileExtensions = ["jpg", "jpeg", "png"]

    static func resizedURLString(_ urlString: String, size: Int) -> String {
        guard urlString.contains("mzstatic.com") else { return urlString }

        for fileExtension in fileExtensions {
            let numericPattern = "/\\d+x\\d+bb\\.\(fileExtension)"
            if let range = urlString.range(of: numericPattern, options: .regularExpression) {
                return urlString.replacingCharacters(in: range, with: "/\(size)x\(size)bb.\(fileExtension)")
            }
        }

        for fileExtension in fileExtensions {
            let templatePattern = "/\\{w\\}x\\{h\\}bb\\.\(fileExtension)"
            if let range = urlString.range(of: templatePattern, options: .regularExpression) {
                return urlString.replacingCharacters(in: range, with: "/\(size)x\(size)bb.\(fileExtension)")
            }
        }

        return urlString
    }

    static func url(from urlString: String?, size: Int) -> URL? {
        guard let urlString, !urlString.isEmpty else { return nil }
        let resized = resizedURLString(urlString, size: size)
        return URL(string: resized)
    }

    static func url(from url: URL?, size: Int) -> URL? {
        guard let url else { return nil }
        return self.url(from: url.absoluteString, size: size)
    }
}
