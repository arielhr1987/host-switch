//
//  HostSwitchApp.swift
//  HostSwitch
//
//  Created by Ariel Hernandez on 3/12/26.
//

import SwiftUI

// App entry point.
// Starts the SwiftUI lifecycle.
@main
struct HostSwitchApp: App {

    // Connects the AppDelegate to SwiftUI.
    // Needed for menu bar logic using AppKit.
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    // Defines app scenes.
    // We avoid windows because this is a menu bar app.
    var body: some Scene {
        // Empty settings scene.
        // Prevents creating a default window.
        Settings {
            EmptyView()
        }
    }
}
