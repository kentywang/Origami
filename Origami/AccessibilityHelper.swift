//
//  Copyright © 2017 Keith Smiley. All rights reserved.
//

import AppKit
import Foundation

struct AccessibilityHelper {
    static func askForAccessibilityIfNeeded() {
        let key: String = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
        let options = [key: true]
        let enabled = AXIsProcessTrustedWithOptions(options as CFDictionary)
        
        if enabled {
            return
        }
        
        let alert = NSAlert()
        alert.messageText = "Enable Accessibility First"
        alert.informativeText = "Find the popup right behind this one, click \"Open System Preferences\" and enable Origami. Then launch Origami again."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Okay")
        alert.runModal()
        NSApp.terminate(nil)
    }
}
