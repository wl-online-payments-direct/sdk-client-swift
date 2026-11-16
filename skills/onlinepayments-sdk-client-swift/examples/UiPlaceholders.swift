import Foundation

// Placeholders for your own UI. The SDK has no screens: the examples call these where your app shows something.

/// Shows the payment result on your own result screen. Called with the status your backend returned, or with the
/// error when the status could not be read.
func showPaymentResult(_ result: Result<PaymentStatus, Error>) {
    // Navigate to your result screen.
}
