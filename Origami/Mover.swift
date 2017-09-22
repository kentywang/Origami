//
//  Copyright © 2017 Kenty Wang and Keith Smiley. All rights reserved.
//

import AppKit
import Foundation
import CoreGraphics

final class Mover : NSResponder {
    var state: FlagState = .Ignore {
        didSet {
            if self.state != oldValue {
                self.changed(state: self.state)
            }
        }
    }
    
    static let sensitivity: CGFloat = 30
    static let dragSensitivity: CGFloat = sensitivity / 3
    
    static let deviceSize = NSSize(width: 297.638, height: 215.433)
    
    static let maxDeltaThreshold : CGFloat = 480
    static let minDeltaThreshold : CGFloat = 0.5
    
    private var monitor: Timer?
    
    static var window: AccessibilityElement?
    
    static var currentMouseLocation = NSPoint(x:0, y:0)
    static var startMouseLocation : NSPoint? = NSPoint(x:0, y:0)
    
    static var numberOfFingers : Int = 0
    
    static var smallestFingerSize : Float = 0.0
    static var firstFingerSize: Float = 0.0
    
    static var f1 = CGPoint(x:0, y:0)
    static var f2 = CGPoint(x:0, y:0)
    static var f1new = CGPoint(x:0, y:0)
    static var f2new = CGPoint(x:0, y:0)
    
    static var fingerDistance : Double {
        return pow(Double(fabs(f1new.x - f2new.x)), 2) + pow(Double(fabs(f1new.y - f2new.y)),2).squareRoot()
    }
    
    static var deltaOriginSinglePt : CGPoint {
        
        var delta = CGPoint(x: 0,y: 0)
        
        delta.x = (f1.x - f1new.x)  * deviceSize.width * dragSensitivity
        delta.y = (f1.y - f1new.y)  * deviceSize.height * dragSensitivity
        
        return delta;
    }
    
    static var deltaOrigin : CGPoint {
        
        let x1: CGFloat = min(f1.x, f2.x)
        let x2: CGFloat = min(f1new.x, f2new.x)
        let y1: CGFloat = max(f1.y, f2.y)
        let y2: CGFloat = max(f1new.y, f2new.y)
        
        var delta = CGPoint(x: 0,y: 0)
        
        delta.x = (x2 - x1)  * deviceSize.width * sensitivity
        delta.y = (y2 - y1)  * deviceSize.height * sensitivity

        return delta;
    }
    
    static var deltaSize : CGSize {
        
        var x1,x2,y1,y2,width1,width2,height1,height2: CGFloat
        
        x1 = min(f1.x, f2.x);
        x2 = max(f1.x, f2.x);
        width1 = x2 - x1;
        
        y1 = min(f1.y, f2.y);
        y2 = max(f1.y, f2.y);
        height1 = y2 - y1;
        
        x1 = min(f1new.x, f2new.x);
        x2 = max(f1new.x, f2new.x);
        width2 = x2 - x1;
        
        y1 = min(f1new.y, f2new.y);
        y2 = max(f1new.y, f2new.y);
        height2 = y2 - y1;
        
        var delta = CGSize(width: 0, height: 0)
        
        delta.width = (width2 - width1)  * deviceSize.width * sensitivity
        delta.height = (height2 - height1)  * deviceSize.height * sensitivity
        
        return delta;
    }
    
    static func updateTouchData(device: Int, one: mtPoint, two: mtPoint, size: Float, size2: Float, num_fingers: Int, timestamp: Double, frame: Int) {
        
        numberOfFingers = num_fingers
        
        f1.x = f1new.x
        f1.y = f1new.y
        f2.x = f2new.x
        f2.y = f2new.y
        f1new.x = CGFloat(one.x)
        f1new.y = CGFloat(one.y)
        f2new.x = CGFloat(two.x)
        f2new.y = CGFloat(two.y)

        smallestFingerSize = min(size, size2)
        firstFingerSize = size
    }
    
    static func updateWindowPosition() {
        
        startMouseLocation = startMouseLocation ?? currentMouseLocation
        
        if let window = window {
            window.bringToFront()
            
            let currentPid = NSRunningApplication.current().processIdentifier
            
            if let pid = window.pid(), pid != currentPid {
                NSRunningApplication(processIdentifier: pid)?.activate(options: .activateIgnoringOtherApps)
            }
            
            if let position = window.position {
                let newPosition = CGPoint(x: position.x - deltaOriginSinglePt.x, y: position.y + deltaOriginSinglePt.y)
                
                if fabs(deltaOriginSinglePt.x) > maxDeltaThreshold
                    || fabs(deltaOriginSinglePt.y) > maxDeltaThreshold
                    || firstFingerSize < 0.35
                {
                    return
                }
                
                CGWarpMouseCursorPosition(CGPoint(x: 0, y: 0))
                window.position = newPosition
            }
        }
    }
    
    static func updateWindow() {

        startMouseLocation = startMouseLocation ?? currentMouseLocation
        
        if let window = window {
            window.bringToFront()
            
            let currentPid = NSRunningApplication.current().processIdentifier
            
            if let pid = window.pid(), pid != currentPid {
                NSRunningApplication(processIdentifier: pid)?.activate(options: .activateIgnoringOtherApps)
            }
            
            if let size = window.size, let position = window.position {
                let newSize = CGSize(width: size.width + deltaSize.width, height: size.height + deltaSize.height)
                let newPosition = CGPoint(x: position.x + deltaOrigin.x, y: position.y - deltaOrigin.y)
                
                if fabs(deltaOrigin.x) > maxDeltaThreshold
                    || fabs(deltaOrigin.y) > maxDeltaThreshold
                    || fabs(deltaSize.width) > maxDeltaThreshold
                    || fabs(deltaSize.height) > maxDeltaThreshold
                    || smallestFingerSize < 0.3
                {
                    return
                }

                CGWarpMouseCursorPosition(CGPoint(x: 0, y: 0))

                window.size = newSize
                
                if let sz = window.size {
                    if sz.width == round(newSize.width){
                        window.positionX = newPosition.x
                    } else if let x = window.position?.x {
                        if x >= newPosition.x {
                            window.positionX = newPosition.x
                        }
                    }
                    if sz.height == round(newSize.height){
                        window.positionY = newPosition.y
                    } else if let y = window.position?.y {
                        if y >= newPosition.y {
                            window.positionY = newPosition.y
                        }
                    }
                }
            }
        }
    }
    
    private func changed(state: FlagState) {
        self.removeMonitor()
        switch state {
        case .Drag:
            Mover.currentMouseLocation = CGEvent(source: nil)!.location
            Mover.window = AccessibilityElement.systemWideElement.element(at: Mover.currentMouseLocation)?.window()

            Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true){ (Timer) in
                self.monitor = Timer

                if Mover.numberOfFingers == 2
                    && fabs(Mover.deltaOrigin.x) > Mover.minDeltaThreshold
                    && fabs(Mover.deltaOrigin.y) > Mover.minDeltaThreshold
                    && fabs(Mover.deltaSize.width) > Mover.minDeltaThreshold
                    && fabs(Mover.deltaSize.height) > Mover.minDeltaThreshold
                {
                    Mover.updateWindow()
                } else if Mover.numberOfFingers == 1
                    && fabs(Mover.deltaOriginSinglePt.x) > Mover.minDeltaThreshold
                    && fabs(Mover.deltaOriginSinglePt.y) > Mover.minDeltaThreshold
                {
                    Mover.updateWindowPosition()
                }
            }
        default:
            if Mover.startMouseLocation != nil {
                if let windowPosition = Mover.window?.position, let windowSize = Mover.window?.size {
                    
                    let n = windowPosition.x + windowSize.width/2.0
                    let m = windowPosition.y + windowSize.height/2.0
                    
                    CGWarpMouseCursorPosition(CGPoint(x: n, y: m))
                }
                
                Mover.startMouseLocation = nil
                
                self.monitor?.invalidate()
                self.monitor = nil
                return
            }
        }
    }
    

    private func removeMonitor() {
        self.monitor?.invalidate()
        self.monitor = nil
    }
    
    deinit {
        self.removeMonitor()
    }
}
