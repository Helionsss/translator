import Foundation

struct FeatureCellViewModel: Equatable {
    let id: String
    let title: String
    let subtitle: String?
    let rightText: String?
    let imageURL: URL?
}

enum FeaturesState: Equatable {
    case idle
    case loading
    case content([FeatureCellViewModel])
    case empty
    case error(String)
}
