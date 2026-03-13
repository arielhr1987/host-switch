//
//  StatusBar.swift
//  HostSwitch
//
//  Created by Ariel Hernandez on 3/13/26.
//

import Cocoa

class StatusBar {

    private let statusItem: NSStatusItem

    private let menu = Menu()

    init() {

        statusItem = NSStatusBar.system.statusItem(
            withLength: NSStatusItem.squareLength
        )

        if let button = statusItem.button {
            button.image = NSImage(
                systemSymbolName: "shield",
                accessibilityDescription: "HostSwitch"
            )
        }

        statusItem.menu = menu.menu
    }
}
