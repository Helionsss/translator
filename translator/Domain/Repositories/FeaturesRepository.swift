protocol FeaturesRepository {
    func fetchRemote() async throws -> [Feature]
    func fetchCached() async throws -> [Feature]
}
