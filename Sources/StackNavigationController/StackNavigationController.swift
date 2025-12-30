//
//  StackNavigationController.swift
//
//  Created by usagimaru on 2021/06/25.
//

import Cocoa

open class StackNavigationController: NSViewController {
	
	/// Current displayed view controller
	open var topViewController: StackNavigationPageViewController? {
		viewControllers.last
	}
	
	/// View controller at the first
	open var rootViewController: StackNavigationPageViewController? {
		viewControllers.first
	}
	
	open var isViewControllersEmpty: Bool {
		viewControllers.isEmpty
	}
	
	/// Can pop `topViewController`
	open var canPop: Bool {
		viewControllers.count > 1
	}
	
	/// Insert a black curtain view onto the source view when transiting with animation
	open var isShadowCurtainEnabled: Bool = true
	
	/// Prevents user interactions when view is animating
	open var preventsUserInteractionsWhenAnimating: Bool = false
	
	/// StackNavigationControllerDelegate
	open weak var delegate: StackNavigationControllerDelegate?
	
	/// View controller stack
	open private(set) var viewControllers: [StackNavigationPageViewController] = []
	
	/// Default animation duration
	public static var defaultAnimationDuration: TimeInterval {
		0.65
	}
	
	
	// MARK: -
	
	// To detect push/pop event without delegate, Override these in subclasses.
	
	open func willPushTransition(from: StackNavigationPageViewController?, to: StackNavigationPageViewController) {}
	open func didPushTransition(from: StackNavigationPageViewController?, to: StackNavigationPageViewController) {}
	open func willPopTransition(from: StackNavigationPageViewController, to: StackNavigationPageViewController?) {}
	open func didPopTransition(from: StackNavigationPageViewController, to: StackNavigationPageViewController?) {}
	
	
	// MARK: -
	
	public init(rootViewController: StackNavigationPageViewController) {
		super.init(nibName: nil, bundle: nil)
		pushViewController(rootViewController, animated: false)
	}
	
	public required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	override open func loadView() {
		view = StackNavigationView()
	}
	
	/// Push view controller
	open func pushViewController(_ toVC: StackNavigationPageViewController,
								 animated: Bool,
								 duration: TimeInterval? = nil,
								 timingFunction: CAMediaTimingFunction? = nil,
								 completion: (() -> Void)? = nil) {
		let fromVC = topViewController
		
		fromVC?.viewWillDisappear(by: self)
		toVC.viewWillAppear(by: self)
		
		willPushTransition(from: fromVC, to: toVC)
		delegate?.stackNavigationController(self,willPushTransition: fromVC, to: toVC)
		
		toVC.stackNavigationController = self
		viewControllers.append(toVC)
		addChild(toVC)
		view.addSubview(toVC.view)
		
		if let fromVC, animated {
			// With animation
			
			var initialFrame = view.bounds
			initialFrame.origin.x = initialFrame.width
			toVC.view.frame = initialFrame
			
			// Curtain view
			let curtainView = isShadowCurtainEnabled ? fromVC.setCurtain() : nil
			curtainView?.setAlphaAsZero()
			
			// User interaction state
			if preventsUserInteractionsWhenAnimating {
				(view as? StackNavigationView)?.preventsUserInteractions = true
			}
			
			NSAnimationContext.runAnimationGroup { context in
				context.duration = duration ?? Self.defaultAnimationDuration
				context.allowsImplicitAnimation = true
				context.timingFunction = timingFunction ?? CAMediaTimingFunction.easeOutQuint()
				context.completionHandler = {
					fromVC.view.removeFromSuperview()
					
					// Reset curtain and user interaction state
					fromVC.removeCurtain()
					(self.view as? StackNavigationView)?.preventsUserInteractions = false
					
					fromVC.viewDidDisappear(by: self)
					toVC.viewDidAppear(by: self)
					
					completion?()
					
					self.didPushTransition(from: fromVC, to: toVC)
					self.delegate?.stackNavigationController(self, didPushTransition: fromVC, to: toVC)
				}
				
				toVC.view.animator().frame = view.bounds
				curtainView?.animator().alphaValue = StackNavigationCurtainView.defaultCurtainViewAlphaValue
			}
		}
		else {
			// No animation
			
			fromVC?.view.removeFromSuperview()
			toVC.view.frame = view.bounds
			
			fromVC?.viewDidDisappear(by: self)
			toVC.viewDidAppear(by: self)
			
			completion?()
			
			didPushTransition(from: fromVC, to: toVC)
			delegate?.stackNavigationController(self, didPushTransition: fromVC, to: toVC)
		}
	}
	
	
	/// Pop view controller
	open func popViewController(animated: Bool,
								duration: TimeInterval? = nil,
								timingFunction: CAMediaTimingFunction? = nil,
								completion: (() -> Void)? = nil) {
		guard canPop, let fromVC = viewControllers.popLast(), let toVC = viewControllers.last
		else { return }
		
		fromVC.viewWillDisappear(by: self)
		toVC.viewWillAppear(by: self)
		
		willPopTransition(from: fromVC, to: toVC)
		delegate?.stackNavigationController(self, willPopTransition: fromVC, to: toVC)
		
		if animated {
			view.addSubview(toVC.view, positioned: .below, relativeTo: fromVC.view)
			toVC.view.frame = view.bounds
			
			// Curtain view
			let curtainView = isShadowCurtainEnabled ? toVC.setCurtain() : nil
			curtainView?.setAlphaAsDefault()
			
			// User interaction state
			if preventsUserInteractionsWhenAnimating {
				(view as? StackNavigationView)?.preventsUserInteractions = true
			}
			
			NSAnimationContext.runAnimationGroup { context in
				context.duration = duration ?? Self.defaultAnimationDuration
				context.allowsImplicitAnimation = true
				context.timingFunction = timingFunction ?? CAMediaTimingFunction.easeOutQuint()
				context.completionHandler = {
					fromVC.view.removeFromSuperview()
					fromVC.removeFromParent()
					
					// Reset curtain and user interaction state
					toVC.removeCurtain()
					(self.view as? StackNavigationView)?.preventsUserInteractions = false
					
					fromVC.viewDidDisappear(by: self)
					toVC.viewDidAppear(by: self)
					
					completion?()
					
					self.didPopTransition(from: fromVC, to: toVC)
					self.delegate?.stackNavigationController(self, didPopTransition: fromVC, to: toVC)
				}
				
				var newFrame = view.bounds
				newFrame.origin.x = newFrame.width
				fromVC.view.animator().frame = newFrame
				curtainView?.animator().alphaValue = 0.0
			}
		}
		else {
			// No animation
			
			view.addSubview(toVC.view, positioned: .below, relativeTo: fromVC.view)
			toVC.view.frame = view.bounds
			
			fromVC.view.removeFromSuperview()
			fromVC.removeFromParent()
			
			fromVC.viewDidDisappear(by: self)
			toVC.viewDidAppear(by: self)
			
			completion?()
			
			didPopTransition(from: fromVC, to: toVC)
			delegate?.stackNavigationController(self, didPopTransition: fromVC, to: toVC)
		}
	}
	
}

public protocol StackNavigationControllerDelegate: AnyObject {
	
	func stackNavigationController(_ navi: StackNavigationController, willPushTransition from: StackNavigationPageViewController?, to: StackNavigationPageViewController)
	func stackNavigationController(_ navi: StackNavigationController, didPushTransition from: StackNavigationPageViewController?, to: StackNavigationPageViewController)
	func stackNavigationController(_ navi: StackNavigationController, willPopTransition from: StackNavigationPageViewController, to: StackNavigationPageViewController?)
	func stackNavigationController(_ navi: StackNavigationController, didPopTransition from: StackNavigationPageViewController, to: StackNavigationPageViewController?)
	
}


// MARK: -

open class StackNavigationView: NSView {
	
	/// Prevents user interactions
	open var preventsUserInteractions: Bool = false
	
	public override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		setup()
	}
	
	public required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}
	
	open func setup() {
		wantsLayer = true
	}
	
	open override func hitTest(_ point: NSPoint) -> NSView? {
		if preventsUserInteractions {
			return nil
		}
		return super.hitTest(point)
	}
	
}


// MARK: -

open class StackNavigationCurtainView: NSView {
	
	public static var defaultCurtainViewAlphaValue: CGFloat {
		0.25
	}
	
	open func setAlphaAsDefault() {
		alphaValue = Self.defaultCurtainViewAlphaValue
	}
	
	open func setAlphaAsZero() {
		alphaValue = 0
	}
	
}


// MARK: -

fileprivate extension CAMediaTimingFunction {
	static func easeInQuint() -> CAMediaTimingFunction {
		return CAMediaTimingFunction(controlPoints: 0.64, 0, 0.78, 0)
	}
	static func easeOutQuint() -> CAMediaTimingFunction {
		return CAMediaTimingFunction(controlPoints: 0.22, 1, 0.36, 1)
	}
}
