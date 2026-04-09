import Foundation

struct AvailableLanguageCellViewModel: Equatable, Hashable {
    let id: String
    let title: String
    let subtitle: String?
    let rightText: String?
    let imageURLString: String?

    var imageURL: URL? {
        imageURLString.flatMap { URL(string: $0) }
    }

    static func == (lhs: AvailableLanguageCellViewModel, rhs: AvailableLanguageCellViewModel) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

enum AvailableLanguagesState: Equatable {
    case idle
    case loading
    case content([AvailableLanguageCellViewModel])
    case empty
    case error(String)
}