//
//  AppDelegate.swift
//  HostSwitch
//
//  Created by Ariel Hernandez on 3/12/26.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {

    var statusBar: StatusBar!

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusBar = StatusBar()
    }
}
