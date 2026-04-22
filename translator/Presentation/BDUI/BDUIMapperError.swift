enum BDUIMapperError: Error {
    case unsupportedContent(BDUIViewType)
    case malformedJSON
}
