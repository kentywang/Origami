//
//  AppDelegate.swift
//  Origami
//
//  Created by Kenty Wang on 9/20/17.
//  Copyright © 2017 Kenty Wang. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let statusItem = NSStatusBar.system().statusItem(withLength: NSSquareStatusItemLength)
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let button = statusItem.button {
            button.image = NSImage(named: "StatusBarItemImage")
            button.action = #selector(woof(_:))
        }
        
        constructMenu()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    @objc func woof(_ sender: Any?) {
        print("-_-")
    }
    
    func constructMenu() {
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "Bark", action: #selector(AppDelegate.woof(_:)), keyEquivalent: "b"))
        menu.addItem(NSMenuItem(title: "Bark", action: #selector(AppDelegate.woof(_:)), keyEquivalent: "b"))
        menu.addItem(NSMenuItem(title: "Bark", action: #selector(AppDelegate.woof(_:)), keyEquivalent: "b"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
}
