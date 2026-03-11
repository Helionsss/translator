import Foundation

struct Translation: Equatable {
    let id: UUID
    let original: String
    let translated: String
    let source: Language
    let target: Language
    let createdAt: Date
}
