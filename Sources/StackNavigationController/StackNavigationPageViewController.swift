//
//  StackNavigationPageViewController.swift
//
//  Created by usagimaru on 2025/12/30.
//

import Cocoa

/// You can use this skeleton class to implement a custom page view controller with subclassing
public class StackNavigationPlainPageViewController: NSViewController, StackNavigationPageViewController {
	
	public weak var stackNavigationController: StackNavigationController?
	
	public func viewWillAppear(by stackNavigationController: StackNavigationController) {}
	public func viewDidAppear(by stackNavigationController: StackNavigationController) {}
	public func viewWillDisappear(by stackNavigationController: StackNavigationController) {}
	public func viewDidDisappear(by stackNavigationController: StackNavigationController) {}
	
}

/// Protocol of a page view controller for StackNavigationController
public protocol StackNavigationPageViewController: NSViewController {
	
	/// Rewriting to `weak var` is recommended
	var stackNavigationController: StackNavigationController? { get set }
	
	func viewWillAppear(by stackNavigationController: StackNavigationController)
	func viewDidAppear(by stackNavigationController: StackNavigationController)
	func viewWillDisappear(by stackNavigationController: StackNavigationController)
	func viewDidDisappear(by stackNavigationController: StackNavigationController)
	
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
					relativeTo otherView: NSView? = nil,
					curtainViewSetup: (() -> StackNavigationCurtainView)? = nil) -> StackNavigationCurtainView
	{
		let curtainView: StackNavigationCurtainView
		
		if let setup = curtainViewSetup {
			curtainView = setup()
		}
		else {
			curtainView = StackNavigationCurtainView()
			curtainView.wantsLayer = true
			curtainView.layer?.backgroundColor = NSColor.black.cgColor
		}
		
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
	
	func removeCurtain() {
		view.subviews.filter {
			$0 is StackNavigationCurtainView
		}.forEach {
			$0.removeFromSuperview()
		}
	}
	
}
