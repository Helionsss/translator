final class DefaultFeaturesRepository: FeaturesRepository {
    func fetchRemote() async throws -> [Feature] {
        fatalError()
    }

    func fetchCached() async throws -> [Feature] {
        fatalError()
    }
}
