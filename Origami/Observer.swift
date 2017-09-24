//
//  Copyright © 2017 Keith Smiley. All rights reserved.
//

import AppKit
import Foundation

enum FlagState {
    case Drag
    case Ignore
}

final class Observer {
    private var monitor: Any?
    
    func startObserving(state: @escaping (FlagState) -> Void) {
        self.monitor = NSEvent.addGlobalMonitorForEvents(matching: NSEvent.EventTypeMask.flagsChanged) { event in
            state(self.state(for: event.modifierFlags))
        }
    }
    
    private func state(for flags: NSEvent.ModifierFlags) -> FlagState {
        let hasMain = flags.contains(NSEvent.ModifierFlags.command) && flags.contains(NSEvent.ModifierFlags.option)
        
        if hasMain {
            return .Drag
        } else {
            return .Ignore
        }
    }
    
    deinit {
        if let monitor = self.monitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}
