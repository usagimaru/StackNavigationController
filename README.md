# StackNavigationController

A lightweignt UINavigationController for macOS AppKit. 


## Usage

```swift
let rootVC = NSViewController()
let stackNavigationController = StackNavigationController(rootViewController: rootVC)

stackNavigationController.delegate = self // Optional
```

```swift:Pushing
let nextVC = NSViewController()
stackNavigationController.pushViewController(nextVC)
```


```swift:Popping
stackNavigationController.popViewController()
```


## Reference
https://stackoverflow.com/questions/4853209/uinavigationcontroller-alike-for-desktop-cocoa
