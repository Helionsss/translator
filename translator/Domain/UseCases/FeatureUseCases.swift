protocol GetAvailableFeaturesUseCase {
    func execute() async throws -> [Feature]
}
