import Foundation
import SwiftUI
import UIKit

// [START pending-payment-store]
/// The only thing the app keeps across a restart: the id of the order that waits for its result. Never store
/// card data, form values or an encrypted request.
enum PendingPaymentStore {
    private static let key = "pendingOrderId"

    static var orderId: String? {
        UserDefaults.standard.string(forKey: key)
    }

    static func save(orderId: String) {
        UserDefaults.standard.set(orderId, forKey: key)
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
// [END pending-payment-store]

// [START handle-payment-result]
/// Shows what your backend returned for Create Payment. The app never decides the outcome itself. When the
/// backend returns a redirect URL (for example for 3-D Secure), save the order id first, then open the URL exactly
/// as received: do not build or change it.
@MainActor
func handlePaymentResponse(
    _ response: MerchantPaymentResponse,
    orderId: String,
    showResult: (PaymentStatus) -> Void
) {
    guard let redirectUrl = response.redirectUrl, let url = URL(string: redirectUrl) else {
        showResult(response.status)
        return
    }

    PendingPaymentStore.save(orderId: orderId)
    UIApplication.shared.open(url)
}
// [END handle-payment-result]

// [START handle-return-link]
// The returnUrl that your backend sends in Create Payment: a universal link that only your app handles.
private let returnUrlPrefix = "https://shop.example.com/payment-return"

/// Call it for every link the app receives, at the root of the app (see the three examples below). It acts only
/// when the link is the return URL and a payment waits for its result. It never reads the outcome from the link:
/// it asks your backend for the status. The result is delivered on the main thread. Returns true when it handled
/// the link.
@discardableResult
func handleReturnLink(_ url: URL, onResult: @escaping @MainActor (Result<PaymentStatus, Error>) -> Void) -> Bool {
    guard url.absoluteString.hasPrefix(returnUrlPrefix), let orderId = PendingPaymentStore.orderId else {
        return false
    }

    Task { @MainActor in
        let result: Result<PaymentStatus, Error>
        do {
            let response = try await fetchPaymentStatus(orderId: orderId)
            if response.status != .pending {
                PendingPaymentStore.clear()
            }
            result = .success(response.status)
        } catch {
            // Keep the order id: the customer can try to check the status again.
            result = .failure(error)
        }
        onResult(result)
    }

    return true
}
// [END handle-return-link]

// [START return-link-scene-delegate]
// UIKit with scenes. Handle the link here, not in the checkout screen, so that it also works when the link
// starts the app (the system stopped the app while the customer was on the 3-D Secure page).
@MainActor
final class ExampleSceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    // The app was not running and a link started it.
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        for urlContext in connectionOptions.urlContexts {
            handle(urlContext.url)
        }
        for activity in connectionOptions.userActivities where activity.activityType == NSUserActivityTypeBrowsingWeb {
            if let url = activity.webpageURL {
                handle(url)
            }
        }
    }

    // The app is running and a custom URL scheme link opens it.
    func scene(_ scene: UIScene, openURLContexts urlContexts: Set<UIOpenURLContext>) {
        for urlContext in urlContexts {
            handle(urlContext.url)
        }
    }

    // The app is running and a universal link opens it.
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb, let url = userActivity.webpageURL {
            handle(url)
        }
    }

    private func handle(_ url: URL) {
        handleReturnLink(url) { result in showPaymentResult(result) }
    }
}
// [END return-link-scene-delegate]

// [START return-link-app-delegate]
// UIKit without scenes: the app delegate receives the links, also when a link starts the app.
@MainActor
final class ExampleAppDelegate: UIResponder, UIApplicationDelegate {
    // A custom URL scheme link.
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        handleReturnLink(url) { result in showPaymentResult(result) }
    }

    // A universal link.
    func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb, let url = userActivity.webpageURL else {
            return false
        }

        return handleReturnLink(url) { result in showPaymentResult(result) }
    }
}
// [END return-link-app-delegate]

// [START return-link-swiftui]
// SwiftUI: onOpenURL receives custom URL scheme links and universal links, also when the link starts the app.
// Add @main to your own App type.
struct ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            Text("Checkout") // your root view
                .onOpenURL { url in
                    handleReturnLink(url) { result in showPaymentResult(result) }
                }
        }
    }
}
// [END return-link-swiftui]
