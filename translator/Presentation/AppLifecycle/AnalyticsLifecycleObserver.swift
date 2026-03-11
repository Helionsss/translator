final class AnalyticsLifecycleObserver: AppLifecycleListener {
    private let analytics: AnalyticsService

    init(analytics: AnalyticsService) {
        self.analytics = analytics
    }

    func handle(event: AppLifecycleEvent) { }
}
