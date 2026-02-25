final class AppLifecycleDispatcher {

    private var listeners: [AppLifecycleListener] = []

    func addListener(_ listener: AppLifecycleListener) {
        listeners.append(listener)
    }

    func dispatch(_ event: AppLifecycleEvent) {
        listeners.forEach { $0.handle(event: event) }
    }
}
