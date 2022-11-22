# StackNavigationController

A lightweignt UINavigationController for macOS AppKit.

[License](./LICENSE)


## Usage

Setup with the root view controller.

```swift
// Root view controller
let rootVC = NSViewController()

// StackNavigationController is subclass of NSViewController
let stackNavigationController = StackNavigationController(rootViewController: rootVC)

// Option for StackNavigationControllerDelegate
stackNavigationController.delegate = self
```

Push the next view controller.

```swift
let nextVC = NSViewController()
stackNavigationController.pushViewController(nextVC)
```

Pop the current view controller, and back to the previous.

```swift
stackNavigationController.popViewController()
```

Determine if `stackNavigationController` can pop.

```swift
if stackNavigationController.canPop {
	…
}
else {
	…
}
```


## Reference
https://stackoverflow.com/questions/4853209/uinavigationcontroller-alike-for-desktop-cocoa
