import Foundation

struct FeatureCellViewModel: Equatable, Hashable {
    let id: String
    let title: String
    let subtitle: String?
    let icon: String

    static func == (lhs: FeatureCellViewModel, rhs: FeatureCellViewModel) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

enum FeaturesState: Equatable {
    case idle
    case content([FeatureCellViewModel])
}