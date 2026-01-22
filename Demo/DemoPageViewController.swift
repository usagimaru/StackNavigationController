//
//  DemoPageViewController.swift
//  StackNavigationControllerDemo
//
//  Created by usagimaru on 2022/11/22.
//

import Cocoa

// 0: use default background view; 1: use colored view
let customBackground = 0

class DemoPageViewController: StackNavigationPlainPageViewController {
	
	@IBOutlet var label: NSTextField!
	@IBOutlet var button: NSButton!
	
	class func newViewController() -> Self {
		return NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "DemoPageViewController") as! Self
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		label.stringValue = String(localized: "Next")
		button.controlSize = .large
	}
	
	private func nextViewController(_ title: String) -> StackNavigationPageViewController {
		let nextVC = DemoPageViewController.newViewController()
		nextVC.loadView()
		nextVC.label.stringValue = title
		nextVC.title = nextVC.label.stringValue
		
		return nextVC
	}
	
	@IBAction func nextAction(_ sender: Any) {
		if let stackNavigationController {
			let count = stackNavigationController.viewControllers.count
			let nextVC = nextViewController("View Controller #\(count)")
			let isAnimated = (view.window?.windowController as? DemoWindowController)?.isAnimated ?? false
			
			// Prevents focus ring issue during animation
			button.focusRingType = .none
			stackNavigationController.pushViewController(nextVC, animated: isAnimated) {
				self.button.focusRingType = .exterior
			}
		}
	}
	
	override func buildBackgroundView() -> StackNavigationPageBackgroundView? {
		if customBackground != 0 {
			let view = PageBackgroundView()
			view.setColor()
			return view
		}
		else {
			return super.buildBackgroundView()
		}
	}
	
	
	// MARK: - StackNavigationPageViewController
	
	override func viewWillAppear(by stackNavigationController: StackNavigationController) {
		
	}
	
	override func viewDidAppear(by stackNavigationController: StackNavigationController) {
		view.window?.makeFirstResponder(button)
	}
	
	override func viewWillDisappear(by stackNavigationController: StackNavigationController) {
		
	}
	
	override func viewDidDisappear(by stackNavigationController: StackNavigationController) {
		
	}

}

class PageBackgroundView: StackNavigationPageBackgroundView {
	
	func setColor() {
		layer?.backgroundColor = NSColor(hue: CGFloat.random(in: 0..<1.0),
										 saturation: 0.5,
										 brightness: 1.0,
										 alpha: 1.0).cgColor
	}
	
	override func updateLayer() {
	}
	
}
