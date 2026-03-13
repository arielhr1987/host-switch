//
//  Menu.swift
//  HostSwitch
//
//  Created by Ariel Hernandez on 3/13/26.
//

import Cocoa

// Manages the application menu shown in the macOS menu bar.
// Responsible for building menu items and handling their actions.
class Menu: NSObject {

    // The menu displayed when the user clicks the status bar icon.
    let menu = NSMenu()

    // Initializes the menu and builds its items.
    override init() {
        super.init()
        build()
    }

    // Builds the menu structure and adds all menu items.
    private func build() {

        // Add the hosts
        addItem(
            title: "Host Profile 1",
            action: #selector(select(_:)),
            keyEquivalent: "1"
        )
        addItem(
            title: "Host Profile 2",
            action: #selector(select(_:)),
            keyEquivalent: "2"
        )

        // Adds a separator line between groups of menu items
        menu.addItem(.separator())

        // Opens the hosts editor window
        addItem(
            title: "Editor",
            action: #selector(openEditor),
            keyEquivalent: "e"
        )

        // Adds a separator line between groups of menu items
        menu.addItem(.separator())

        // Terminates the application
        addItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
    }

    // Creates a menu item and adds it to the menu.
    // - Parameters:
    //   - title: The text displayed in the menu.
    //   - action: The selector executed when the item is clicked.
    //   - keyEquivalent: The keyboard shortcut for the menu item.
    private func addItem(
        title: String,
        action: Selector?,
        keyEquivalent: String
    ) {
        let item = NSMenuItem(
            title: title,
            action: action,
            keyEquivalent: keyEquivalent
        )
        item.target = self
        item.subtitle = "Subtitle"
        item.toolTip = "A very long description of what this item does. It should be long enough to warrant a tooltip, but not so long that it obscures the actual text of the item."
        menu.addItem(item)
    }

    // Handles the selection of a host profile from the menu.
    // - Parameter sender: The menu item that was selected.
    @objc func select(_ sender: NSMenuItem) {
        print("Selected host: \(sender.title)")
    }

    // Opens the hosts file editor.
    @objc func openEditor() {
        print("Open editor")
    }

    // Quits the application.
    @objc func quit() {
        NSApplication.shared.terminate(nil)
    }
}
