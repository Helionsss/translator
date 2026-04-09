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
    case loading
    case content([FeatureCellViewModel])
    case error(String)
    
    static func == (lhs: FeaturesState, rhs: FeaturesState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle): return true
        case (.loading, .loading): return true
        case (.content(let lhsItems), .content(let rhsItems)): return lhsItems == rhsItems
        case (.error(let lhsMessage), .error(let rhsMessage)): return lhsMessage == rhsMessage
        default: return false
        }
    }
}
