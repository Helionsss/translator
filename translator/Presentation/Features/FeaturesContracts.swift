protocol FeaturesView: AnyObject {
    func render(_ state: FeaturesState)
}

protocol FeaturesViewModelProtocol: AnyObject {
    var view: FeaturesView? { get set }
    func onAppear()
    func didSelectFeature(type: FeatureType)
}