import Foundation

enum FeatureType: String, Equatable {
    case text
    case voice
    case photo
    case history
}

struct Feature: Equatable {
    let id: String
    let title: String
    let subtitle: String?
    let type: FeatureType
    let isAvailableOffline: Bool
    let flagURL: URL?
}
