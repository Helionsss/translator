import UIKit

final class ImageLoader {
    static let shared = ImageLoader()
    private let cache = ImageCache.shared
    private let session: URLSession

    private init() {
        let config = URLSessionConfiguration.default
        config.urlCache = URLCache(memoryCapacity: 50 * 1024 * 1024, diskCapacity: 0)
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 30
        self.session = URLSession(configuration: config)
    }

    func loadImage(from url: URL) async throws -> UIImage {
        if let cached = cache.image(for: url) {
            return cached
        }

        var request = URLRequest(url: url)
        request.cachePolicy = .returnCacheDataElseLoad

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode),
              let image = UIImage(data: data)
        else {
            throw ImageLoaderError.invalidResponse
        }

        cache.setImage(image, for: url)
        return image
    }

    func clearCache() {
        cache.removeAll()
    }
}

enum ImageLoaderError: Error {
    case invalidResponse
}
