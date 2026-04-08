import Foundation

final class DefaultFeaturesRepository: FeaturesRepository {
    private let networkClient: NetworkClient
    private let useLocalFallback: Bool
    private var cache: [Feature]?

    private static let endpoint = URL(string: "https://api.worldbank.org/v2/country?format=json&per_page=300")!

    private static let languageMap: [String: String] = [
        "US": "English", "GB": "English", "AU": "English", "CA": "English",
        "ES": "Spanish", "MX": "Spanish", "AR": "Spanish", "CO": "Spanish",
        "FR": "French", "BE": "French", "CH": "French",
        "DE": "German", "AT": "German",
        "IT": "Italian",
        "PT": "Portuguese", "BR": "Portuguese",
        "RU": "Russian", "BY": "Russian", "KZ": "Russian",
        "CN": "Chinese", "TW": "Chinese",
        "JP": "Japanese", "KR": "Korean",
        "SA": "Arabic", "EG": "Arabic", "AE": "Arabic",
        "IN": "Hindi",
        "NL": "Dutch", "SE": "Swedish", "NO": "Norwegian", "DK": "Danish",
        "FI": "Finnish", "PL": "Polish", "CZ": "Czech", "RO": "Romanian",
        "TR": "Turkish", "GR": "Greek", "IL": "Hebrew", "TH": "Thai",
        "VN": "Vietnamese", "ID": "Indonesian", "MY": "Malay",
        "UA": "Ukrainian", "HU": "Hungarian", "BG": "Bulgarian",
        "HR": "Croatian", "SK": "Slovak", "RS": "Serbian",
        "LT": "Lithuanian", "LV": "Latvian", "EE": "Estonian",
        "IR": "Persian", "PK": "Urdu", "BD": "Bengali",
        "NG": "Yoruba", "KE": "Swahili", "ET": "Amharic",
        "PH": "Filipino", "DZ": "Arabic", "MA": "Arabic",
        "TN": "Arabic", "LY": "Arabic", "IQ": "Arabic",
        "JO": "Arabic", "LB": "Arabic", "KW": "Arabic",
        "QA": "Arabic", "OM": "Arabic", "YE": "Arabic",
        "CL": "Spanish", "PE": "Spanish", "VE": "Spanish",
        "EC": "Spanish", "GT": "Spanish", "CU": "Spanish",
        "BO": "Spanish", "DO": "Spanish", "HN": "Spanish",
        "PY": "Spanish", "SV": "Spanish", "NI": "Spanish",
        "CR": "Spanish", "PA": "Spanish", "UY": "Spanish",
        "SN": "French", "CI": "French", "ML": "French",
        "BF": "French", "NE": "French", "TD": "French",
        "MG": "French", "CM": "French", "CD": "French",
        "CG": "French", "GA": "French", "BJ": "French",
        "TG": "French", "GW": "Portuguese", "AO": "Portuguese",
        "MZ": "Portuguese", "TL": "Portuguese",
        "GE": "Georgian", "AM": "Armenian", "AZ": "Azerbaijani",
        "UZ": "Uzbek", "TM": "Turkmen", "TJ": "Tajik", "KG": "Kyrgyz",
        "MN": "Mongolian", "NP": "Nepali", "LK": "Sinhala",
        "MM": "Burmese", "KH": "Khmer", "LA": "Lao",
        "AL": "Albanian", "MK": "Macedonian", "ME": "Montenegrin",
        "BA": "Bosnian", "SI": "Slovenian", "IS": "Icelandic",
        "IE": "Irish", "MT": "Maltese", "LU": "Luxembourgish",
        "LI": "German", "MC": "French", "SM": "Italian",
        "VA": "Italian", "AD": "Catalan",
        "ZW": "Shona", "ZM": "Bemba", "TZ": "Swahili",
        "UG": "Swahili", "RW": "Kinyarwanda", "BI": "Kirundi",
        "MW": "Chichewa", "NA": "Afrikaans",
        "BW": "Tswana", "SZ": "Swati", "LS": "Sotho",
        "MU": "Creole", "SC": "Creole", "CV": "Creole",
        "KM": "Comorian", "DJ": "Somali", "SO": "Somali",
        "ER": "Tigrinya", "SD": "Arabic", "SS": "Arabic",
        "CF": "French", "GQ": "Spanish", "ST": "Portuguese",
        "SR": "Dutch", "GY": "English", "GF": "French",
        "BZ": "English", "JM": "English", "TT": "English",
        "BB": "English", "GD": "English", "LC": "English",
        "VC": "English", "DM": "English", "AG": "English",
        "KN": "English", "BS": "English", "HT": "French",
        "FJ": "English", "PG": "English", "SB": "English",
        "VU": "Bislama", "NC": "French", "PF": "French",
        "WS": "Samoan", "TO": "Tongan", "KI": "English",
        "NR": "English", "TV": "English", "FM": "English",
        "MH": "English", "PW": "English", "BN": "Malay",
        "MV": "Dhivehi", "BT": "Dzongkha", "AF": "Pashto",
        "SY": "Arabic", "PS": "Arabic"
    ]

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
        let features: [Feature] = response.countries
            .filter { !$0.region.id.isEmpty && $0.region.id != "NA" }
            .sorted { $0.name < $1.name }
            .map { dto in
                let languageName = Self.languageName(for: dto.iso2Code, countryName: dto.name)
                return Feature(
                    id: dto.iso2Code,
                    title: languageName,
                    subtitle: dto.name,
                    type: .languages,
                    isAvailableOffline: false,
                    flagURL: URL(string: "https://flagcdn.com/w40/\(dto.iso2Code.lowercased()).png")
                )
            }
        cache = features
        return features
    }

    private static func languageName(for code: String, countryName: String) -> String {
        languageMap[code] ?? countryName
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
            .map { dto in
                let languageName = Self.languageName(for: dto.iso2Code, countryName: dto.name)
                return Feature(
                    id: dto.iso2Code,
                    title: languageName,
                    subtitle: dto.name,
                    type: .languages,
                    isAvailableOffline: true,
                    flagURL: URL(string: "https://flagcdn.com/w40/\(dto.iso2Code.lowercased()).png")
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
