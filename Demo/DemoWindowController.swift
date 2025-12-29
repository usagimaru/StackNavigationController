//
//  DemoWindowController.swift
//  StackNavigationControllerDemo
//
//  Created by usagimaru on 2022/11/23.
//

import Cocoa

class DemoWindowController: NSWindowController,
							NSToolbarDelegate,
							NSMenuItemValidation,
							NSToolbarItemValidation,
							StackNavigationControllerDelegate {
	
	private let navigationControlItem = NSToolbarItem.Identifier("navigationControlItem")
	private let animationControlItem = NSToolbarItem.Identifier("animationControlItem")
	
	private(set) var isAnimated: Bool = true
	
	@IBOutlet var toolbar: NSToolbar!
	
	
	// MARK: -

	override func windowDidLoad() {
		super.windowDidLoad()
		
		window?.title = "StackNavigationController Demo"
		
		let rootVC = DemoPageViewController.newViewController()
		rootVC.loadView()
		rootVC.label.stringValue = "Root View Controller"
		rootVC.title = rootVC.label.stringValue
		rootVC.setRandomBackgroundColor()
		
		stackNavigationController.delegate = self
		stackNavigationController.preventsUserInteractionsWhenAnimating = false // or `true`
		stackNavigationController.pushViewController(rootVC, animated: false)
	}
	
	var stackNavigationController: StackNavigationController {
		contentViewController as! StackNavigationController
	}
	
	@IBAction func popViewController(_ sender: Any) {
		stackNavigationController.popViewController(animated: isAnimated)
	}
	
	@IBAction func toggleAnimations(_ sender: Any) {
		isAnimated.toggle()
		
		(toolbar.items.first { $0.itemIdentifier == animationControlItem })?.image = isAnimated
		? NSImage(symbolName: "custom.circle.dotted.and.circle.badge.checkmark", variableValue: 0)
		: NSImage(systemSymbolName: "circle.dotted.and.circle", accessibilityDescription: nil)
	}
	
	
	// MARK: - NSToolbarDelegate
	
	func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
		[
			navigationControlItem,
			animationControlItem,
		]
	}
	
	func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
		switch itemIdentifier {
			case navigationControlItem:
				let item = NSToolbarItem(itemIdentifier: itemIdentifier)
				item.isNavigational = true
				item.isBordered = false
				item.image = NSImage(systemSymbolName: "chevron.left", accessibilityDescription: nil)
				item.label = String(localized: "Back")
				item.title = item.label
				item.target = self
				item.action = #selector(popViewController(_:))
				return item
				
			case animationControlItem:
				let item = NSToolbarItem(itemIdentifier: itemIdentifier)
				item.isBordered = false
				item.image = isAnimated
				? NSImage(symbolName: "custom.circle.dotted.and.circle.badge.checkmark", variableValue: 0)
				: NSImage(systemSymbolName: "circle.dotted.and.circle", accessibilityDescription: nil)
				
				item.label = String(localized: "Animation")
				item.title = item.label
				item.target = self
				item.action = #selector(toggleAnimations(_:))
				return item
				
			case _:
				return nil
		}
	}
	
	
	// MARK: - NSMenuItemValidation
	
	func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
		switch menuItem.action {
			case #selector(popViewController(_:)):
				return stackNavigationController.canPop
				
			case _:
				return true
		}
	}
	
	
	// MARK: - NSToolbarItemValidation
	
	func validateToolbarItem(_ item: NSToolbarItem) -> Bool {
		switch item.itemIdentifier {
			case navigationControlItem:
				return stackNavigationController.canPop
				
			case _:
				return true
		}
	}
	
	
	// MARK: - StackNavigationControllerDelegate
	
	func stackNavigationController(_ navi: StackNavigationController, willPushTransition from: StackNavigationPageViewController?, to: StackNavigationPageViewController) {
		print(#function, "\n  [Pushing (will)]: '\(from?.title ?? "(none)")' -> '\(to.title ?? "(none)")'")
	}
	
	func stackNavigationController(_ navi: StackNavigationController, didPushTransition from: StackNavigationPageViewController?, to: StackNavigationPageViewController) {
		print(#function, "\n  [Pushing (did)]: '\(from?.title ?? "(none)")' -> '\(to.title ?? "(none)")'")
		toolbar.validateVisibleItems()
	}
	
	func stackNavigationController(_ navi: StackNavigationController, willPopTransition from: StackNavigationPageViewController, to: StackNavigationPageViewController?) {
		print(#function, "\n  [Popping (will)]: '\(from.title ?? "(none)")' -> '\(to?.title ?? "(none)")'")
	}
	
	func stackNavigationController(_ navi: StackNavigationController, didPopTransition from: StackNavigationPageViewController, to: StackNavigationPageViewController?) {
		print(#function, "\n  [Popping (did)]: '\(from.title ?? "(none)")' -> '\(to?.title ?? "(none)")'")
		toolbar.validateVisibleItems()
	}

}
