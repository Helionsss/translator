protocol GetAvailableFeaturesUseCase {
    func execute() async throws -> [Feature]
}

final class DefaultGetAvailableFeaturesUseCase: GetAvailableFeaturesUseCase {
    private let repository: FeaturesRepository

    init(repository: FeaturesRepository) {
        self.repository = repository
    }

    func execute() async throws -> [Feature] {
        try await repository.fetchFeatures()
    }
}
