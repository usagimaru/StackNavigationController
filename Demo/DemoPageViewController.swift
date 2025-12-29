//
//  DemoPageViewController.swift
//  StackNavigationControllerDemo
//
//  Created by usagimaru on 2022/11/22.
//

import Cocoa

class DemoPageViewController: NSViewController, StackNavigationPageViewController {
	
	@IBOutlet var label: NSTextField!
	@IBOutlet var button: NSButton!
	
	class func newViewController() -> Self {
		return NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "DemoPageViewController") as! Self
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		label.stringValue = String(localized: "Next")
	}
	
	func setRandomBackgroundColor() {
		view.wantsLayer = true
		view.layer?.backgroundColor = NSColor(hue: CGFloat.random(in: 0..<1.0),
											  saturation: 0.5,
											  brightness: 1.0,
											  alpha: 1.0).cgColor
	}
	
	private func nextViewController(_ title: String) -> StackNavigationPageViewController {
		let nextVC = DemoPageViewController.newViewController()
		nextVC.loadView()
		nextVC.label.stringValue = title
		nextVC.title = nextVC.label.stringValue
		nextVC.setRandomBackgroundColor()
		
		return nextVC
	}
	
	@IBAction func nextAction(_ sender: Any) {
		if let stackNavigationController {
			let count = stackNavigationController.viewControllers.count
			let nextVC = nextViewController("View Controller #\(count)")
			let isAnimated = (view.window?.windowController as? DemoWindowController)?.isAnimated ?? false
			
			button.isEnabled = false
			stackNavigationController.pushViewController(nextVC, animated: isAnimated) {
				self.button.isEnabled = true
			}
		}
	}
	
	
	// MARK: - StackNavigationPageViewController
	
	weak var stackNavigationController: StackNavigationController?
	
	func viewWillAppear(by stackNavigationController: StackNavigationController) {
		
	}
	
	func viewDidAppear(by stackNavigationController: StackNavigationController) {
		view.window?.makeFirstResponder(button)
		print(String(describing: Self.self), #function)
	}
	
	func viewWillDisappear(by stackNavigationController: StackNavigationController) {
		
	}
	
	func viewDidDisappear(by stackNavigationController: StackNavigationController) {
		
	}

}

