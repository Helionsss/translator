protocol FeaturesRepository {
    func fetchFeatures() async throws -> [Feature]
}
