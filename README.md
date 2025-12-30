# StackNavigationController

A lightweignt page-based navigation container like UINavigationController for macOS AppKit.

[License](./LICENSE)


## Usage

StackNavigationController is a container view controller based on NSViewController architecture. This container holds multiple pages.

### Implementing pages

When implementing pages, you must use the protocol `StackNavigationPageViewController`. (A) Implement it yourself or (B) use the skeleton class.

```swift
// A: Protocol based
class MyPageViewController: NSViewController, StackNavigationPageViewController { … }

// B: Skeleton class based (recommended)
class MyPageViewController: StackNavigationPlainPageViewController {}
```

Prepare stack navigation controller as a container with the root page.

```swift
// Initialize StackNavigationController with the root page view controller
let rootPageVC = MyPageViewController()
let stack = StackNavigationController(rootViewController: rootPageVC)

// Implementation example:
// Insert stack view controller to some parent view controller as a child
someParentVC.addChild(stack)
someParentVC.view.addSubview(stack.view)

// Setup Auto layout
stack.view.translatesAutoresizingMaskIntoConstraints = false
stack.view.topAnchor.constraint(equalTo: someParentVC.view.topAnchor).isActive = true
stack.view.bottomAnchor.constraint(equalTo: someParentVC.view.bottomAnchor).isActive = true
stack.view.leadingAnchor.constraint(equalTo: someParentVC.view.leadingAnchor).isActive = true
stack.view.trailingAnchor.constraint(equalTo: someParentVC.view.trailingAnchor).isActive = true
```

### Event handling – Push
Push the next view controller.

```swift
stack.pushViewController(nextVC, animated: true) // or false
```

### Event handling – Pop
Pop the current view controller, and back to the previous.

```swift
stack.popViewController(animated: true) // or false
```

Determines whether the stack navigation controller can perform a pop operation.

```swift
if stackNavigationController.canPop {
	…
}
else {
	…
}
```

### Delegation

To detect some events with `StackNavigationControllerDelegate` methods. You can determine the transition types (push / pop) using the `type: TransitionType` argument.

```swift
stack.delegate = self

func stackNavigationController(_ navi: StackNavigationController,
  willMove from: (any StackNavigationPageViewController)?,
  to: (any StackNavigationPageViewController),
  type: StackNavigationController.TransitionType)
{}

func stackNavigationController(_ navi: StackNavigationController,
  didMove from: (any StackNavigationPageViewController)?,
  to: (any StackNavigationPageViewController),
  type: StackNavigationController.TransitionType)
{}
```

## Reference
https://stackoverflow.com/questions/4853209/uinavigationcontroller-alike-for-desktop-cocoa
