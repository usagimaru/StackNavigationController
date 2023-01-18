//
//  WindowController.swift
//  StackNavigationController
//
//  Created by usagimaru on 2022/11/23.
//

import Cocoa

class WindowController: NSWindowController,
						NSToolbarDelegate,
						NSMenuItemValidation,
						NSToolbarItemValidation,
						StackNavigationControllerDelegate {
	
	@IBOutlet var toolbar: NSToolbar!

    override func windowDidLoad() {
        super.windowDidLoad()
    
		self.window?.title = "StackNavigationController Demo"
		
		let rootVC = ViewController.newViewController()
		rootVC.loadView()
		rootVC.label.stringValue = "Root View Controller"
		rootVC.title = rootVC.label.stringValue
		rootVC.view.layer?.backgroundColor = NSColor.tertiaryLabelColor.cgColor
		
		self.stackNavigationController.delegate = self
		self.stackNavigationController.pushViewController(rootVC)
    }
	
	var stackNavigationController: StackNavigationController {
		self.contentViewController as! StackNavigationController
	}
	
	@IBAction func popViewController(_ sender: Any) {
		self.stackNavigationController.popViewController()
	}
	
	
	// MARK: - NSToolbarDelegate
	
	private let navigationControlItem = NSToolbarItem.Identifier("navigationControlItem")
	
	func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
		[
			self.navigationControlItem
		]
	}
	
	func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
		switch itemIdentifier {
			case self.navigationControlItem:
				let item = NSToolbarItem(itemIdentifier: itemIdentifier)
				item.isNavigational = true
				item.isBordered = false
				item.image = NSImage(systemSymbolName: "chevron.left", accessibilityDescription: nil)
				item.label = "Back"
				item.title = item.label
				item.target = self
				item.action = #selector(popViewController(_:))
				return item
				
			case _:
				return nil
		}
	}
	
	
	// MARK: - NSMenuItemValidation
	
	func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
		switch menuItem.action {
			case #selector(popViewController(_:)):
				return self.stackNavigationController.canPop
				
			case _:
				return true
		}
	}
	
	
	// MARK: - NSToolbarItemValidation
	
	func validateToolbarItem(_ item: NSToolbarItem) -> Bool {
		switch item.itemIdentifier {
			case self.navigationControlItem:
				return self.stackNavigationController.canPop
				
			case _:
				return true
		}
	}
	
	
	// MARK: - StackNavigationControllerDelegate
	
	func stackNavigationController(_ navi: StackNavigationController, willPush viewController: NSViewController, current: NSViewController?) {
		print(#function, "[Pushing]: '\(current?.title ?? "(none)")' -> '\(viewController.title ?? "(none)")'")
	}
	
	func stackNavigationController(_ navi: StackNavigationController, didPush viewController: NSViewController) {
		self.toolbar.validateVisibleItems()
	}
	
	func stackNavigationController(_ navi: StackNavigationController, willPop viewController: NSViewController, next: NSViewController?) {
		print(#function, "[Popping]: '\(viewController.title ?? "(none)")' -> '\(next?.title ?? "(none)")'")
	}
	
	func stackNavigationController(_ navi: StackNavigationController, didPop viewController: NSViewController) {
		self.toolbar.validateVisibleItems()
	}

}
