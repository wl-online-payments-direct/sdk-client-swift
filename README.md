Online Payments Swift SDK
=======================

The Online Payments Swift SDK provides a convenient way to support a large number of payment methods inside your iOS app.
It supports iOS 9.0 and up out of the box.
The Swift SDK comes with an example app that illustrates the use of the SDK and the services provided by the Online Payments platform.

Use the SDK with Carthage, CocoaPods or Swift Package Manager
---------------------------------------
The Online Payments Swift SDK is available via the following package managers: [CocoaPods](https://cocoapods.org/), [Carthage](https://github.com/Carthage/Carthage) or [Swift Package Manager](https://github.com/apple/swift-package-manager).

### CocoaPods

You can add the Swift SDK as a pod to your project by adding the following to your `Podfile`:

```
$ pod 'OnlinePaymentsKit'
```

Afterwards, run the following command:

```
$ pod install
```

### Carthage

You can add the Swift SDK with Carthage, by adding the following to your `Cartfile`:

```
$ github "wl-online-payments-direct/sdk-client-swift"
```

Afterwards, run the following command:

```
$ carthage update --use-xcframeworks
```

Navigate to the ```Carthage/Build``` directory, which was created in the same directory as where the ```.xcodeproj``` or ```.xcworkspace``` is. Inside this directory the ```.xcframework``` bundle is stored. Drag the ```.xcframework``` into the "Framework, Libraries and Embedded Content" section of the desired target. Make sure that it is set to "Embed & Sign". 

### Swift Package Manager

You can add the Swift SDK with Swift Package Manager, by configuring your project as following:

1. Go to your project's settings and click the 'Package Dependencies' tab.
2. Click the '+' to add a new Swift Package dependency.
3. Enter the Github URL in the search bar: `https://github.com/wl-online-payments-direct/sdk-client-swift`
4. Additionally, you can also set a version of the package that you wish to include. The default option is to select the latest version from the main branch.
5. Click 'Add package'

When the package has successfully been added, it will automatically be added as a dependency to your targets as well.
