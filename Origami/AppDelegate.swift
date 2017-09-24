//
//  Copyright © 2017 Kenty Wang and Keith Smiley. All rights reserved.
//

import Cocoa
import AppKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let button = statusItem.button {
            button.image = NSImage(named: NSImage.Name(rawValue: "StatusBarItemImage"))
//            button.action = #selector(woof(_:))
        }
        
        constructMenu()
        
        AccessibilityHelper.askForAccessibilityIfNeeded()
        
        if !LoginController.opensAtLogin() {
            LoginController.setOpensAtLogin(true)
        }
        
        let mover = Mover()
        Observer().startObserving { state in
            mover.state = state
        }
        
        let dev: MTDeviceRef = MTDeviceCreateDefault()
        
        MTRegisterContactFrameCallback(dev, {(device, data, num_fingers, timestamp, frame) in
            let mom = data![0]
            let dad = data![1]
            
            Mover.updateTouchData(device: Int(device),
                                  one: mom.normalized.position,
                                  two: dad.normalized.position,
                                  size: mom.size,
                                  size2: dad.size,
                                  num_fingers: Int(num_fingers),
                                  timestamp: timestamp,
                                  frame: Int(frame))
        })
        
        MTDeviceStart(dev, 0)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
//    @objc func woof(_ sender: Any?) {
//        print("-_-")
//    }
    
    func constructMenu() {
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent:""))
        
        statusItem.menu = menu
    }
}
