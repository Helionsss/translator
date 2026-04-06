enum NetworkError: Error, Equatable {
    case noConnection
    case timeout
    case badStatus(Int)
    case decodingFailed
    case unknown
}
