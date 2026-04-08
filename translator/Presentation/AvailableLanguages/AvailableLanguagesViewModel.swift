import Foundation

final class DefaultAvailableLanguagesViewModel: AvailableLanguagesViewModelProtocol {
    weak var view: AvailableLanguagesView?

    private let useCase: GetAvailableFeaturesUseCase
    private let onSelectLanguage: (String) -> Void
    private var loadTask: Task<Void, Never>?

    private var allItems: [AvailableLanguageCellViewModel] = []

    init(useCase: GetAvailableFeaturesUseCase, onSelectLanguage: @escaping (String) -> Void) {
        self.useCase = useCase
        self.onSelectLanguage = onSelectLanguage
    }

    func onAppear() {
        load()
    }

    func retry() {
        load()
    }

    func refresh() {
        load()
    }

    func search(query: String) {
        if query.isEmpty {
            view?.render(.content(allItems))
        } else {
            let lowercased = query.lowercased()
            let filtered = allItems.filter {
                $0.title.lowercased().contains(lowercased) ||
                ($0.subtitle?.lowercased().contains(lowercased) ?? false)
            }
            if filtered.isEmpty {
                view?.render(.empty)
            } else {
                view?.render(.content(filtered))
            }
        }
    }

    func didSelectLanguage(id: String) {
        onSelectLanguage(id)
    }

    private func load() {
        loadTask?.cancel()
        view?.render(.loading)

        loadTask = Task { [weak self] in
            guard let self else { return }
            do {
                let features = try await useCase.execute()
                guard !Task.isCancelled else { return }
                let viewModels = features.map(Self.map)
                self.allItems = viewModels
                if viewModels.isEmpty {
                    await MainActor.run { self.view?.render(.empty) }
                } else {
                    await MainActor.run { self.view?.render(.content(viewModels)) }
                }
            } catch {
                guard !Task.isCancelled else { return }
                let message = Self.errorMessage(from: error)
                await MainActor.run { self.view?.render(.error(message)) }
            }
        }
    }

    private static func map(_ feature: Feature) -> AvailableLanguageCellViewModel {
        AvailableLanguageCellViewModel(
            id: feature.id,
            title: feature.title,
            subtitle: feature.subtitle,
            rightText: feature.isAvailableOffline ? "Offline" : nil,
            imageURLString: feature.flagURL?.absoluteString
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