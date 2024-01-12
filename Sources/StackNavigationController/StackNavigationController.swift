//
//  StackNavigationController.swift
//
//  Created by usagimaru on 2021/06/25.
//

import Cocoa
import ObjectiveC

@objc public protocol StackNavigationControllerDelegate: AnyObject {
	
	@objc optional func stackNavigationController(_ navi: StackNavigationController, willPush viewController: NSViewController, current: NSViewController?)
	@objc optional func stackNavigationController(_ navi: StackNavigationController, didPush viewController: NSViewController)
	@objc optional func stackNavigationController(_ navi: StackNavigationController, willPop viewController: NSViewController, next: NSViewController?)
	@objc optional func stackNavigationController(_ navi: StackNavigationController, didPop viewController: NSViewController)
	
}

public class StackNavigationController: NSViewController {
	
	/// Current displayed view controller
	open var topViewController: NSViewController? {
		viewControllers.last
	}
	
	/// View controller at the first
	open var rootViewController: NSViewController? {
		viewControllers.first
	}
	
	open var isViewControllersEmpty: Bool {
		viewControllers.isEmpty
	}
	
	/// Can pop `topViewController`
	open var canPop: Bool {
		viewControllers.count > 1
	}
	
	open weak var delegate: StackNavigationControllerDelegate?
	
	/// View controller stack
	open private(set) var viewControllers: [NSViewController] = []
	
	
	// MARK: -
	
	// To detect push/pop event without delegate, Override these in subclasses.
	
	public func willPushViewController(_: NSViewController, current: NSViewController?) {}
	public func didPushViewController(_: NSViewController) {}
	public func willPopViewController(_: NSViewController, next: NSViewController?) {}
	public func didPopViewController(_: NSViewController) {}
	
	
	// MARK: -
	
	override open func loadView() {
		view = NSView()
		view.wantsLayer = true
	}
	
	public init(rootViewController: NSViewController) {
		super.init(nibName: nil, bundle: nil)
		pushViewController(rootViewController)
	}
	
	public required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	/// Pushing view controller without animation.
	public func pushViewController(_ pushingViewController: NSViewController) {
		pushViewController(pushingViewController, animated: false)
	}
	
	/// Pushing view controller with animation.
	/// I think animating is not getting good usability and not good feeling. We should respect standard macOS experiences.
	public func pushViewControllerWithAnimation(_ pushingViewController: NSViewController) {
		pushViewController(pushingViewController, animated: true)
	}
	
	private func pushViewController(_ pushingViewController: NSViewController, animated: Bool) {
		let previousVC = topViewController
		pushingViewController.stackNavigationController = self
		
		if animated {
			pushingViewController.view.wantsLayer = true
			
			if let previousVC, animated {
				addChildViewController(pushingViewController)
				
				let endFrame = previousVC.view.frame
				let startFrame = endFrame.offsetBy(dx: endFrame.width, dy: 0)
				pushingViewController.view.frame = startFrame
				pushingViewController.view.alphaValue = 0.85
				
				viewControllers.append(pushingViewController)
				
				NSAnimationContext.runAnimationGroup { context in
					context.duration = 0.2
					context.allowsImplicitAnimation = true
					context.timingFunction = CAMediaTimingFunction(name: .easeOut)
					pushingViewController.view.animator().frame = endFrame
					pushingViewController.view.animator().alphaValue = 1
					previousVC.view.animator().alphaValue = 0.25
				} completionHandler: {
					previousVC.view.alphaValue = 1
					previousVC.view.removeFromSuperview()
					
					self.didPushViewController(pushingViewController)
					self.delegate?.stackNavigationController?(self, didPush: pushingViewController)
				}
			}
		}
		
		willPushViewController(pushingViewController, current: previousVC)
		delegate?.stackNavigationController?(self, willPush: pushingViewController, current: previousVC)
		
		addChildViewController(pushingViewController)
		viewControllers.append(pushingViewController)
		
		previousVC?.view.removeFromSuperview()
		
		didPushViewController(pushingViewController)
		delegate?.stackNavigationController?(self, didPush: pushingViewController)
	}
	
	
	/// Popping view controller without animation.
	@discardableResult
	public func popViewController() -> NSViewController? {
		popViewController(animated: false)
	}
	
	/// Popping view controller with animation.
	/// I think animating is not getting good usability and not good feeling. We should respect standard macOS experiences.
	@discardableResult
	public func popViewControllerWithAnimation() -> NSViewController? {
		popViewController(animated: true)
	}
	
	@discardableResult
	private func popViewController(animated: Bool) -> NSViewController? {
		guard canPop, let poppingVC = viewControllers.popLast(), let originalVC = topViewController
		else { return nil }
		
		willPopViewController(poppingVC, next: viewControllers.last)
		delegate?.stackNavigationController?(self, willPop: poppingVC, next: viewControllers.last)
		
		originalVC.addView(on: view, positioned: .below, relativeTo: poppingVC.view)
		
		if animated {
			let endFrame = poppingVC.view.frame.offsetBy(dx: poppingVC.view.frame.width, dy: 0)

			NSAnimationContext.runAnimationGroup { context in
				context.duration = 0.23
				context.allowsImplicitAnimation = true
				context.timingFunction = CAMediaTimingFunction(name: .easeIn)
				poppingVC.view.animator().frame = endFrame
				poppingVC.view.animator().alphaValue = 0.85
			} completionHandler: {
				self.removeChildViewController(poppingVC)
				self.didPopViewController(poppingVC)
				self.delegate?.stackNavigationController?(self, didPop: poppingVC)
			}
		}
		
		removeChildViewController(poppingVC)
		didPopViewController(poppingVC)
		delegate?.stackNavigationController?(self, didPop: poppingVC)
		
		return poppingVC
	}
	
}


// MARK: -

public extension NSViewController {
	
	// The great idea of using malloc(1) for the associatedObjectKey was taken from this Swift forum.
	// https://forums.swift.org/t/handling-the-new-forming-unsaferawpointer-warning/65523/7
	private static let StackNavigationController_associatedObjectKey = malloc(1)!
	
	var stackNavigationController: StackNavigationController? {
		get {
			value(forKey: Self.StackNavigationController_associatedObjectKey)
		}
		set {
			setAssign(value: newValue, forKey: Self.StackNavigationController_associatedObjectKey)
		}
	}
	
	func addView(on parentView: NSView, positioned place: NSWindow.OrderingMode? = nil, relativeTo otherView: NSView? = nil) {
		if let place {
			parentView.addSubview(view, positioned: place, relativeTo: otherView)
		} else {
			parentView.addSubview(view)
		}
		
		self.view.translatesAutoresizingMaskIntoConstraints = false
		let constraints = [
			NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[v]-0-|",
										   metrics: nil,
										   views: ["v" : view]),
			NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[v]-0-|",
										   metrics: nil,
										   views: ["v" : view])
		].flatMap { $0 }
		NSLayoutConstraint.activate(constraints)
	}
	
	func addChildViewController(_ vc: NSViewController, container: NSView? = nil) {
		addChild(vc)
		vc.addView(on: container ?? view)
	}
	
	func removeChildViewController(_ vc: NSViewController) {
		vc.view.removeFromSuperview()
		vc.removeFromParent()
	}
	
}

extension NSObject {
	
	func value<T>(forKey key: UnsafeRawPointer) -> T? {
		objc_getAssociatedObject(self, key) as? T
	}
	
	func setAssign<T>(value: T?, forKey key: UnsafeRawPointer) {
		objc_setAssociatedObject(self, key, value, .OBJC_ASSOCIATION_ASSIGN)
	}
	
	func setRetainNonAtomic<T>(value: T?, forKey key: UnsafeRawPointer) {
		objc_setAssociatedObject(self, key, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
	}
	
	func setCopyNonAtomic<T>(value: T?, forKey key: UnsafeRawPointer) {
		objc_setAssociatedObject(self, key, value, .OBJC_ASSOCIATION_COPY_NONATOMIC)
	}
	
	func setRetain<T>(value: T?, forKey key: UnsafeRawPointer) {
		objc_setAssociatedObject(self, key, value, .OBJC_ASSOCIATION_RETAIN)
	}
	
	func setCopy<T>(value: T?, forKey key: UnsafeRawPointer) {
		objc_setAssociatedObject(self, key, value, .OBJC_ASSOCIATION_COPY)
	}
	
}
