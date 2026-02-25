enum DomainError: Error, Equatable {
    case networkUnavailable
    case unauthorized
    case invalidInput
    case modelNotDownloaded
    case translationFailed
}
