import Foundation

final class DefaultFeaturesRepository: FeaturesRepository {
    private let networkClient: NetworkClient
    private let useLocalFallback: Bool
    private var cache: [Feature]?

    private static let endpoint = URL(string: "https://api.worldbank.org/v2/country?format=json&per_page=300")!

    init(networkClient: NetworkClient, useLocalFallback: Bool = false) {
        self.networkClient = networkClient
        self.useLocalFallback = useLocalFallback
    }

    func fetchFeatures() async throws -> [Feature] {
        if let cached = cache { return cached }

        if useLocalFallback {
            let features = Self.localFallback()
            cache = features
            return features
        }

        let response: WorldBankResponse = try await networkClient.get(Self.endpoint)
        let features = response.countries
            .filter { !$0.region.id.isEmpty && $0.region.id != "NA" }
            .sorted { $0.name < $1.name }
            .map { dto in
                Feature(
                    id: dto.iso2Code,
                    title: dto.name,
                    subtitle: dto.region.value.trimmingCharacters(in: .whitespaces),
                    type: .text,
                    isAvailableOffline: false,
                    flagURL: URL(string: "https://flagcdn.com/w320/\(dto.iso2Code.lowercased()).png")
                )
            }
        cache = features
        return features
    }

    private static func localFallback() -> [Feature] {
        guard
            let url = Bundle.main.url(forResource: "countries", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let response = try? JSONDecoder().decode(WorldBankResponse.self, from: data)
        else { return [] }

        return response.countries
            .filter { !$0.region.id.isEmpty && $0.region.id != "NA" }
            .sorted { $0.name < $1.name }
            .map {
                Feature(
                    id: $0.iso2Code,
                    title: $0.name,
                    subtitle: $0.region.value.trimmingCharacters(in: .whitespaces),
                    type: .text,
                    isAvailableOffline: true,
                    flagURL: URL(string: "https://flagcdn.com/w320/\($0.iso2Code.lowercased()).png")
                )
            }
    }
}

struct WorldBankResponse: Decodable {
    let countries: [WorldBankCountryDTO]

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(WorldBankMetaDTO.self)
        countries = try container.decode([WorldBankCountryDTO].self)
    }
}
