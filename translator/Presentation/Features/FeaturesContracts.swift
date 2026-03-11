enum FeaturesViewState: Equatable {
    case loading
    case content([Feature])
    case error(String)
}

protocol FeaturesView: AnyObject {
    func render(_ state: FeaturesViewState)
}

protocol FeaturesViewModel {
    func onAppear()
    func didSelectFeature(id: String)
}
