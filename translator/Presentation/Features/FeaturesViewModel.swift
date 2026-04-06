import Foundation

final class DefaultFeaturesViewModel: FeaturesViewModelProtocol {
    weak var view: FeaturesView?

    private let useCase: GetAvailableFeaturesUseCase
    private let onSelectFeature: (String) -> Void
    private var loadTask: Task<Void, Never>?

    init(useCase: GetAvailableFeaturesUseCase, onSelectFeature: @escaping (String) -> Void) {
        self.useCase = useCase
        self.onSelectFeature = onSelectFeature
    }

    func onAppear() {
        load()
    }

    func retry() {
        load()
    }

    func didSelectFeature(id: String) {
        onSelectFeature(id)
    }

    private func load() {
        loadTask?.cancel()
        view?.render(.loading)

        loadTask = Task { [weak self] in
            guard let self else { return }
            do {
                let features = try await useCase.execute()
                guard !Task.isCancelled else { return }
                if features.isEmpty {
                    await MainActor.run { self.view?.render(.empty) }
                } else {
                    let viewModels = features.map(Self.map)
                    await MainActor.run { self.view?.render(.content(viewModels)) }
                }
            } catch {
                guard !Task.isCancelled else { return }
                let message = Self.errorMessage(from: error)
                await MainActor.run { self.view?.render(.error(message)) }
            }
        }
    }

    private static func map(_ feature: Feature) -> FeatureCellViewModel {
        FeatureCellViewModel(
            id: feature.id,
            title: feature.title,
            subtitle: feature.subtitle,
            rightText: feature.isAvailableOffline ? "Offline" : nil,
            imageURL: feature.flagURL
        )
    }

    private static func errorMessage(from error: Error) -> String {
        switch error as? NetworkError {
        case .noConnection: return "No internet connection"
        case .timeout: return "Request timed out"
        case .badStatus(let code): return "Server error (\(code))"
        case .decodingFailed: return "Failed to parse response"
        default: return "Something went wrong"
        }
    }
}
