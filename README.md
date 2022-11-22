# StackNavigationController

A lightweignt UINavigationController for macOS AppKit.

[Licese](./LICENSE)


## Usage

Setup with root view controller.

```swift
// Root view controller
let rootVC = NSViewController()

// StackNavigationController is subclass of NSViewController
let stackNavigationController = StackNavigationController(rootViewController: rootVC)

// Option for StackNavigationControllerDelegate
stackNavigationController.delegate = self
```

Push next view controller.

```swift
let nextVC = NSViewController()
stackNavigationController.pushViewController(nextVC)
```

Pop current view controller, and back to previous.

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
