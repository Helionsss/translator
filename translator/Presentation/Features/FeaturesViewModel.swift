final class DefaultFeaturesViewModel: FeaturesViewModel {
    private let useCase: GetAvailableFeaturesUseCase

    init(useCase: GetAvailableFeaturesUseCase) {
        self.useCase = useCase
    }

    func onAppear() { }

    func didSelectFeature(id: String) { }
}
