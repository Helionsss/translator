protocol FeaturesView: AnyObject {
    func render(_ state: FeaturesState)
}

protocol FeaturesViewModelProtocol: AnyObject {
    var view: FeaturesView? { get set }
    func onAppear()
    func retry()
    func didSelectFeature(id: String)
}
