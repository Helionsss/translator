import Foundation

enum FeatureType: String, Equatable {
    case translate
    case languages
    case history
    case favorites
    case settings
}

struct Feature: Equatable {
    let id: String
    let title: String
    let subtitle: String?
    let type: FeatureType
    let isAvailableOffline: Bool
    let flagURL: URL?
}
