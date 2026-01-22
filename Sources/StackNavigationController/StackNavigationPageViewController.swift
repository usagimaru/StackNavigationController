//
//  StackNavigationPageViewController.swift
//
//  Created by usagimaru on 2025/12/30.
//

import Cocoa

/// You can use this skeleton class to implement a custom page view controller with subclassing
open class StackNavigationPlainPageViewController: NSViewController, StackNavigationPageViewController {
	
	open weak var stackNavigationController: StackNavigationController?
	
	open func viewWillAppear(by stackNavigationController: StackNavigationController) {}
	open func viewDidAppear(by stackNavigationController: StackNavigationController) {}
	open func viewWillDisappear(by stackNavigationController: StackNavigationController) {}
	open func viewDidDisappear(by stackNavigationController: StackNavigationController) {}
	
	public func buildBackgroundView() -> StackNavigationPageBackgroundView? {
		StackNavigationPageBackgroundView()
	}
	
}

/// Protocol of a page view controller for StackNavigationController
public protocol StackNavigationPageViewController: NSViewController {
	
	/// Rewriting to `weak var` is recommended
	var stackNavigationController: StackNavigationController? { get set }
	
	func viewWillAppear(by stackNavigationController: StackNavigationController)
	func viewDidAppear(by stackNavigationController: StackNavigationController)
	func viewWillDisappear(by stackNavigationController: StackNavigationController)
	func viewDidDisappear(by stackNavigationController: StackNavigationController)
	
	func buildBackgroundView() -> StackNavigationPageBackgroundView?
}

public extension StackNavigationPageViewController {
	
	func addView(on parentView: NSView, positioned position: NSWindow.OrderingMode? = nil, relativeTo otherView: NSView? = nil) {
		if let position {
			parentView.addSubview(view, positioned: position, relativeTo: otherView)
		} else {
			parentView.addSubview(view)
		}
		
		view.translatesAutoresizingMaskIntoConstraints = false
		view.topAnchor.constraint(equalTo: parentView.topAnchor).isActive = true
		view.bottomAnchor.constraint(equalTo: parentView.bottomAnchor).isActive = true
		view.leadingAnchor.constraint(equalTo: parentView.leadingAnchor).isActive = true
		view.trailingAnchor.constraint(equalTo: parentView.trailingAnchor).isActive = true
	}
	
	func setCurtain(positioned position: NSWindow.OrderingMode? = nil,
					relativeTo otherView: NSView? = nil) -> StackNavigationCurtainView
	{
		let curtainView = buildCurtainView()
		
		if let position {
			view.addSubview(curtainView, positioned: position, relativeTo: otherView)
		} else {
			view.addSubview(curtainView)
		}
		
		curtainView.translatesAutoresizingMaskIntoConstraints = false
		curtainView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		curtainView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
		curtainView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		curtainView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
		
		return curtainView
	}
	
	func buildCurtainView() -> StackNavigationCurtainView {
		let curtainView = StackNavigationCurtainView()
		curtainView.identifier = .init("\(self).curtainView")
		curtainView.wantsLayer = true
		curtainView.layer?.backgroundColor = NSColor.black.cgColor
		return curtainView
	}
	
	func removeCurtain() {
		view.subviews.filter {
			$0.identifier == .init("\(self).curtainView")
		}.first?.removeFromSuperview()
	}
	
	@discardableResult
	func setBackgroundView() -> StackNavigationPageBackgroundView? {
		guard let backgroundView = buildBackgroundView()
		else { return nil }
		
		backgroundView.identifier = .init("\(self).backgroundView")
		view.addSubview(backgroundView, positioned: .below, relativeTo: nil)
		
		backgroundView.translatesAutoresizingMaskIntoConstraints = false
		backgroundView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
		backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
		
		return backgroundView
	}
	
	func backgroundView() -> StackNavigationPageBackgroundView? {
		view.subviews.filter {
			$0.identifier == .init("\(self).backgroundView")
		}.first as? StackNavigationPageBackgroundView
	}
	
	func removeBackgroundView() {
		backgroundView()?.removeFromSuperview()
	}
	
}
