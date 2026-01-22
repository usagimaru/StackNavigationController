//
//  StackNavigationController.swift
//
//  Created by usagimaru on 2021/06/25.
//

import Cocoa

open class StackNavigationController: NSViewController {
	
	/// Transition type
	public enum TransitionType {
		case push
		case pop
	}
	
	/// Equal to `self.view`
	public var contentView: StackNavigationView {
		view as! StackNavigationView
	}
	
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
	
	/// Transition state
	public var isInTransition: Bool = false
	
	/// Default animation duration
	public static var defaultAnimationDuration: TimeInterval {
		0.65
	}
	
	/// Default animation curve
	public static var defaultTimingFunction: CAMediaTimingFunction {
		.easeOutQuint()
	}
	
	
	// MARK: -
	
	// To detect transition events without delegate, Override these in subclasses.
	
	open func willMove(from: StackNavigationPageViewController?, to: StackNavigationPageViewController, type: TransitionType) {}
	open func didMove(from: StackNavigationPageViewController?, to: StackNavigationPageViewController, type: TransitionType) {}
	
	
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
		let transition: TransitionType = .push
		
		isInTransition = true
		
		fromVC?.viewWillDisappear(by: self)
		toVC.viewWillAppear(by: self)
		
		willMove(from: fromVC, to: toVC, type: .push)
		delegate?.stackNavigationController(self, willMove: fromVC, to: toVC, type: transition)
		
		toVC.stackNavigationController = self
		viewControllers.append(toVC)
		addChild(toVC)
		view.addSubview(toVC.view)
		
		toVC.setBackgroundView()
		
		if let fromVC, animated {
			// With animation
			
			let initialFrame_to = NSRect(x: view.bounds.width,
										 y: view.bounds.minY,
										 width: view.bounds.width,
										 height: view.bounds.height)
			let destFrame_from = NSRect(x: -view.bounds.width / 4,
										y: view.bounds.minY,
										width: view.bounds.width,
										height: view.bounds.height)
			
			toVC.view.frame = initialFrame_to
			
			// Curtain view
			let curtainView = isShadowCurtainEnabled ? fromVC.setCurtain() : nil
			curtainView?.setAlphaAsZero()
			
			// User interaction state
			if preventsUserInteractionsWhenAnimating {
				contentView.preventsUserInteractions = true
			}
			
			NSAnimationContext.runAnimationGroup { context in
				context.duration = duration ?? Self.defaultAnimationDuration
				context.allowsImplicitAnimation = true
				context.timingFunction = timingFunction ?? Self.defaultTimingFunction
				context.completionHandler = {
					fromVC.view.removeFromSuperview()
					
					// Reset curtain and user interaction state
					fromVC.removeCurtain()
					self.contentView.preventsUserInteractions = false
					self.isInTransition = false
					
					fromVC.viewDidDisappear(by: self)
					toVC.viewDidAppear(by: self)
					
					completion?()
					
					self.didMove(from: fromVC, to: toVC, type: transition)
					self.delegate?.stackNavigationController(self, didMove: fromVC, to: toVC, type: transition)
				}
				
				fromVC.view.animator().frame = destFrame_from
				toVC.view.animator().frame = view.bounds
				curtainView?.animator().alphaValue = StackNavigationCurtainView.defaultCurtainViewAlphaValue
			}
		}
		else {
			// No animation
			
			fromVC?.view.removeFromSuperview()
			toVC.view.frame = view.bounds
			
			isInTransition = false
			
			fromVC?.viewDidDisappear(by: self)
			toVC.viewDidAppear(by: self)
			
			completion?()
			
			didMove(from: fromVC, to: toVC, type: transition)
			delegate?.stackNavigationController(self, didMove: fromVC, to: toVC, type: transition)
		}
	}
	
	
	/// Pop view controller
	open func popViewController(animated: Bool,
								duration: TimeInterval? = nil,
								timingFunction: CAMediaTimingFunction? = nil,
								completion: (() -> Void)? = nil) {
		guard canPop, let fromVC = viewControllers.popLast(), let toVC = viewControllers.last
		else { return }
		
		let transition: TransitionType = .pop
		
		isInTransition = true
		
		fromVC.viewWillDisappear(by: self)
		toVC.viewWillAppear(by: self)
		
		willMove(from: fromVC, to: toVC, type: transition)
		delegate?.stackNavigationController(self, willMove: fromVC, to: toVC, type: transition)
		
		if animated {
			view.addSubview(toVC.view, positioned: .below, relativeTo: fromVC.view)
			toVC.setBackgroundView()
			
			let initialFrame_to = NSRect(x: -view.bounds.width / 4,
										 y: view.bounds.minY,
										 width: view.bounds.width,
										 height: view.bounds.height)
			let destFrame_from = NSRect(x: view.bounds.width,
										y: view.bounds.minY,
										width: view.bounds.width,
										height: view.bounds.height)
			
			toVC.view.frame = initialFrame_to
			
			// Curtain view
			let curtainView = isShadowCurtainEnabled ? toVC.setCurtain() : nil
			curtainView?.setAlphaAsDefault()
			
			// User interaction state
			if preventsUserInteractionsWhenAnimating {
				contentView.preventsUserInteractions = true
			}
			
			NSAnimationContext.runAnimationGroup { context in
				context.duration = duration ?? Self.defaultAnimationDuration
				context.allowsImplicitAnimation = true
				context.timingFunction = timingFunction ?? Self.defaultTimingFunction
				context.completionHandler = {
					fromVC.view.removeFromSuperview()
					fromVC.removeFromParent()
					fromVC.removeBackgroundView()
					toVC.removeBackgroundView()
					
					// Reset curtain and user interaction state
					toVC.removeCurtain()
					self.contentView.preventsUserInteractions = false
					self.isInTransition = false
					
					fromVC.viewDidDisappear(by: self)
					toVC.viewDidAppear(by: self)
					
					completion?()
					
					self.didMove(from: fromVC, to: toVC, type: transition)
					self.delegate?.stackNavigationController(self, didMove: fromVC, to: toVC, type: transition)
				}
				
				fromVC.view.animator().frame = destFrame_from
				toVC.view.animator().frame = view.bounds
				curtainView?.animator().alphaValue = 0.0
			}
		}
		else {
			// No animation
			
			view.addSubview(toVC.view, positioned: .below, relativeTo: fromVC.view)
			toVC.view.frame = view.bounds
			toVC.setBackgroundView()
			
			fromVC.view.removeFromSuperview()
			fromVC.removeFromParent()
			
			isInTransition = false
			
			fromVC.viewDidDisappear(by: self)
			toVC.viewDidAppear(by: self)
			
			completion?()
			
			didMove(from: fromVC, to: toVC, type: transition)
			delegate?.stackNavigationController(self, didMove: fromVC, to: toVC, type: transition)
		}
	}
	
}

public protocol StackNavigationControllerDelegate: AnyObject {
	
	func stackNavigationController(_ navi: StackNavigationController, willMove from: StackNavigationPageViewController?, to: StackNavigationPageViewController, type: StackNavigationController.TransitionType)
	func stackNavigationController(_ navi: StackNavigationController, didMove from: StackNavigationPageViewController?, to: StackNavigationPageViewController, type: StackNavigationController.TransitionType)
	
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

open class StackNavigationPageBackgroundView: NSView {
	
	open override var wantsUpdateLayer: Bool {
		true
	}
	
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
		layerContentsRedrawPolicy = .onSetNeedsDisplay
		needsDisplay = true
	}
	
	open override func updateLayer() {
		// apply the system background color of NSWindow
		layer?.backgroundColor = NSColor.alternatingContentBackgroundColors.last?.cgColor
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
