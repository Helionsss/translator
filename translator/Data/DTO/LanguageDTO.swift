import Foundation

struct WorldBankMetaDTO: Decodable {
    let total: Int
}

struct WorldBankRegionDTO: Decodable {
    let id: String
    let value: String
}

struct WorldBankCountryDTO: Decodable {
    let id: String
    let iso2Code: String
    let name: String
    let region: WorldBankRegionDTO
    let capitalCity: String
}
