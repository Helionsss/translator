protocol AppLifecycleListener: AnyObject {
    func handle(event: AppLifecycleEvent)
}
