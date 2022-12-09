//
//  StackNavigationController.swift
//
//  Created by usagimaru on 2021/06/25.
//

import Cocoa
import ObjectiveC

public protocol StackNavigationControllerDelegate: AnyObject {
	
	func stackNavigationController(_ navi: StackNavigationController, didPush viewController: NSViewController)
	func stackNavigationController(_ navi: StackNavigationController, didPop viewController: NSViewController)
	
}

open class StackNavigationController: NSViewController {
	
	/// Current displayed view controller
	var topViewController: NSViewController? {
		self.viewControllers.last
	}
	
	/// View controller at the first
	var rootViewController: NSViewController? {
		self.viewControllers.first
	}
	
	var isViewControllersEmpty: Bool {
		self.viewControllers.isEmpty
	}
	
	/// Can pop `topViewController`
	var canPop: Bool {
		self.viewControllers.count > 1
	}
	
	weak var delegate: StackNavigationControllerDelegate?
	
	/// View controller stack
	private(set) var viewControllers: [NSViewController] = []
	
	
	// MARK: -
	
	// To detect push/pop event without delegate, Override these in subclasses.
	
	func didPushViewController(_: NSViewController) {}
	func didPopViewController(_: NSViewController) {}
	
	
	// MARK: -
	
	override open func loadView() {
		self.view = NSView()
//		self.view.wantsLayer = true
	}
	
	public init(rootViewController: NSViewController) {
		super.init(nibName: nil, bundle: nil)
		pushViewController(rootViewController)
	}
	
	public required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	func pushViewController(_ pushingViewController: NSViewController) {
		let previousVC = self.topViewController
		pushingViewController.stackNavigationController = self
		
		/*
		 I disabled these currently because not good usability.
		 Respecting standard macOS experience.
		 */
		
//		pushingViewController.view.wantsLayer = true
//
//		if let previousVC, animated {
//			addChildViewController(pushingViewController)
//
//			let endFrame = previousVC.view.frame
//			let startFrame = endFrame.offsetBy(dx: endFrame.width, dy: 0)
//			pushingViewController.view.frame = startFrame
//			pushingViewController.view.alphaValue = 0.85
//
//			viewControllers.append(pushingViewController)
//
//			NSAnimationContext.runAnimationGroup { context in
//				context.duration = 0.2
//				context.allowsImplicitAnimation = true
//				context.timingFunction = CAMediaTimingFunction(name: .easeOut)
//				pushingViewController.view.animator().frame = endFrame
//				pushingViewController.view.animator().alphaValue = 1
//				previousVC.view.animator().alphaValue = 0.25
//			} completionHandler: {
//				previousVC.view.alphaValue = 1
//				previousVC.view.removeFromSuperview()
//
//				self.didPushViewController(pushingViewController)
//				self.delegate?.stackNavigationController(self, didPush: pushingViewController)
//			}
//		}
		
		addChildViewController(pushingViewController)
		viewControllers.append(pushingViewController)
		
		previousVC?.view.removeFromSuperview()
		
		didPushViewController(pushingViewController)
		self.delegate?.stackNavigationController(self, didPush: pushingViewController)
	}
	
	@discardableResult
	func popViewController() -> NSViewController? {
		guard self.canPop, let poppingVC = viewControllers.popLast(), let originalVC = topViewController
		else { return nil }
		
		originalVC.addView(on: self.view, positioned: .below, relativeTo: poppingVC.view)
		
//		if animated {
//			let endFrame = poppingVC.view.frame.offsetBy(dx: poppingVC.view.frame.width, dy: 0)
//
//			NSAnimationContext.runAnimationGroup { context in
//				context.duration = 0.23
//				context.allowsImplicitAnimation = true
//				context.timingFunction = CAMediaTimingFunction(name: .easeIn)
//				poppingVC.view.animator().frame = endFrame
//				poppingVC.view.animator().alphaValue = 0.85
//			} completionHandler: {
//				self.removeChildViewController(poppingVC)
//				self.didPopViewController(poppingVC)
//				self.delegate?.stackNavigationController(self, didPop: poppingVC)
//			}
//		}
		
		removeChildViewController(poppingVC)
		didPopViewController(poppingVC)
		self.delegate?.stackNavigationController(self, didPop: poppingVC)
		
		return poppingVC
	}
	
}


// MARK: -

public extension NSViewController {
	
	private enum AssociatedObjectKey {
		static var navigationController = "AAFD9B44-7C88-431F-B867-E64750AAB7F3 StackNavigationController"
	}
	
	var stackNavigationController: StackNavigationController? {
		get {
			StackNavigationController_AssociatedObject.value(from: self, forKey: &AssociatedObjectKey.navigationController)
		}
		set {
			StackNavigationController_AssociatedObject.setAssign(value: newValue, to: self, forKey: &AssociatedObjectKey.navigationController)
		}
	}
	
	func addView(on parentView: NSView, positioned place: NSWindow.OrderingMode? = nil, relativeTo otherView: NSView? = nil) {
		if let place {
			parentView.addSubview(self.view, positioned: place, relativeTo: otherView)
		} else {
			parentView.addSubview(self.view)
		}
		
		self.view.translatesAutoresizingMaskIntoConstraints = false
		let constraints = [
			NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[v]-0-|",
										   metrics: nil,
										   views: ["v" : self.view]),
			NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[v]-0-|",
										   metrics: nil,
										   views: ["v" : self.view])
		].flatMap { $0 }
		NSLayoutConstraint.activate(constraints)
	}
	
	func addChildViewController(_ vc: NSViewController, container: NSView? = nil) {
		addChild(vc)
		vc.addView(on: container ?? self.view)
	}
	
	func removeChildViewController(_ vc: NSViewController) {
		vc.view.removeFromSuperview()
		vc.removeFromParent()
	}
	
}

enum StackNavigationController_AssociatedObject {
	
	static func value<T>(from object: AnyObject, forKey key: UnsafeRawPointer) -> T? {
		objc_getAssociatedObject(object, key) as? T
	}
	
	static func setAssign<T>(value: T?, to object: Any, forKey key: UnsafeRawPointer) {
		objc_setAssociatedObject(object, key, value, .OBJC_ASSOCIATION_ASSIGN)
	}
	
	static func setRetainNonAtomic<T>(value: T?, to object: Any, forKey key: UnsafeRawPointer) {
		objc_setAssociatedObject(object, key, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
	}
	
	static func setCopyNonAtomic<T>(value: T?, to object: Any, forKey key: UnsafeRawPointer) {
		objc_setAssociatedObject(object, key, value, .OBJC_ASSOCIATION_COPY_NONATOMIC)
	}
	
	static func setRetain<T>(value: T?, to object: Any, forKey key: UnsafeRawPointer) {
		objc_setAssociatedObject(object, key, value, .OBJC_ASSOCIATION_RETAIN)
	}
	
	static func setCopy<T>(value: T?, to object: Any, forKey key: UnsafeRawPointer) {
		objc_setAssociatedObject(object, key, value, .OBJC_ASSOCIATION_COPY)
	}
	
}

