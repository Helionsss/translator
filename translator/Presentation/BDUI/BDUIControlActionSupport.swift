import UIKit
import ObjectiveC

private final class BDUIControlActionProxy: NSObject {
    let action: () -> Void

    init(action: @escaping () -> Void) {
        self.action = action
    }

    @objc func invoke() {
        action()
    }
}

private var bduiControlProxyKey: UInt8 = 0
private var bduiTapActionKey: UInt8 = 0
private var bduiTapHandlerKey: UInt8 = 0
private var bduiTapContextKey: UInt8 = 0

extension UIControl {
    func bdui_addAction(for controlEvent: UIControl.Event, _ action: @escaping () -> Void) {
        let proxy = BDUIControlActionProxy(action: action)
        addTarget(proxy, action: #selector(BDUIControlActionProxy.invoke), for: controlEvent)

        var proxies = objc_getAssociatedObject(self, &bduiControlProxyKey) as? [BDUIControlActionProxy] ?? []
        proxies.append(proxy)
        objc_setAssociatedObject(self, &bduiControlProxyKey, proxies, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

extension UITapGestureRecognizer {
    var bduiAction: BDUIAction? {
        get { objc_getAssociatedObject(self, &bduiTapActionKey) as? BDUIAction }
        set { objc_setAssociatedObject(self, &bduiTapActionKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    var bduiActionHandler: BDUIActionHandling? {
        get { objc_getAssociatedObject(self, &bduiTapHandlerKey) as? BDUIActionHandling }
        set { objc_setAssociatedObject(self, &bduiTapHandlerKey, newValue, .OBJC_ASSOCIATION_ASSIGN) }
    }

    var bduiContextProvider: (() -> BDUIRenderContext?)? {
        get { objc_getAssociatedObject(self, &bduiTapContextKey) as? (() -> BDUIRenderContext?) }
        set { objc_setAssociatedObject(self, &bduiTapContextKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC) }
    }
}
