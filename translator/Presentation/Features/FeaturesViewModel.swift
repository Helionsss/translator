import Foundation

final class DefaultFeaturesViewModel: FeaturesViewModelProtocol {
    weak var view: FeaturesView?

    private let onSelectFeature: (FeatureType) -> Void

    init(onSelectFeature: @escaping (FeatureType) -> Void) {
        self.onSelectFeature = onSelectFeature
    }

    func onAppear() {
        let (viewModels, types) = Self.makeFeatures()
        (view as? FeaturesViewController)?.setFeatureTypes(types)
        view?.render(.content(viewModels))
    }

    func didSelectFeature(type: FeatureType) {
        onSelectFeature(type)
    }

    private static func makeFeatures() -> ([FeatureCellViewModel], [FeatureType]) {
        let features: [(FeatureType, String, String, String?)] = [
            (.translate, "🌐", "Translate", "Translate text between languages"),
            (.languages, "🌍", "Available Languages", "217 languages available"),
            (.history, "📜", "History", "View translation history"),
            (.favorites, "⭐", "Favorites", "Saved translations"),
            (.settings, "⚙️", "Settings", "App settings and preferences")
        ]

        let viewModels = features.map { type, icon, title, subtitle in
            FeatureCellViewModel(id: type.rawValue, title: title, subtitle: subtitle, icon: icon)
        }
        let types = features.map(\.0)
        return (viewModels, types)
    }
}