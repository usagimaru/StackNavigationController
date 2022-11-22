//
//  ViewController.swift
//  StackNavigationController
//
//  Created by usagimaru on 2022/11/22.
//

import Cocoa

class ViewController: NSViewController {
	
	@IBOutlet var label: NSTextField!
	@IBOutlet var button: NSButton!
	
	var canPushNext: Bool = false
	
	class func newViewController() -> Self {
		let sb = NSStoryboard(name: "Main", bundle: nil)
		return sb.instantiateController(withIdentifier: "ViewController") as! Self
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self.view.wantsLayer = true
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}
	
	@IBAction func nextAction(_ sender: Any) {
		if let stackNavigationController = self.stackNavigationController {
			let nextVC = ViewController.newViewController()
			nextVC.loadView()
			nextVC.canPushNext = true
			
			let count = stackNavigationController.viewControllers.count
			nextVC.label.stringValue = "View Controller #\(count)"
			
			nextVC.view.layer?.backgroundColor = NSColor(hue: CGFloat.random(in: 0..<1.0),
														 saturation: 0.5,
														 brightness: 1.0,
														 alpha: 1.0).cgColor
			
			stackNavigationController.pushViewController(nextVC)
		}
	}

}

