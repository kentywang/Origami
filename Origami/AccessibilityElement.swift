//
//  Copyright © 2017 Keith Smiley. All rights reserved.
//

import AppKit
import Foundation

final class AccessibilityElement {
    static let systemWideElement = AccessibilityElement.createSystemWideElement()
    
    var position: CGPoint? {
        get { return self.getPosition() }
        set {
            if let position = newValue {
                self.set(position: position)
            }
        }
    }
    
    var positionX: CGFloat? {
        get { return self.getPosition()?.x }
        set {
            if let positionxx = newValue, let positionyy = self.getPosition()?.y {
                self.set(position: CGPoint(x:positionxx, y: positionyy))
            }
        }
    }
    
    var positionY: CGFloat? {
        get { return self.getPosition()?.y }
        set {
            if let positionxx = self.getPosition()?.x, let positionyy = newValue {
                self.set(position: CGPoint(x:positionxx, y: positionyy))
            }
        }
    }
    
    var size: CGSize? {
        get { return self.getSize() }
        set {
            if let size = newValue {
                self.set(size: size)
            }
        }
    }
    
    private let elementRef: AXUIElement
    
    init(elementRef: AXUIElement) {
        self.elementRef = elementRef
    }
    
    func element(at point: CGPoint) -> Self? {
        var ref: AXUIElement?
        AXUIElementCopyElementAtPosition(self.elementRef, Float(point.x), Float(point.y), &ref)
        return ref.map(type(of: self).init)
    }
    
    func window() -> Self? {
        var element = self
        while element.role() != kAXWindowRole {
            if let nextElement = element.parent() {
                element = nextElement
            } else {
                return nil
            }
        }
        
        return element
    }
    
    func parent() -> Self? {
        return self.value(for: kAXParentAttribute)
    }
    
    func role() -> String? {
        return self.value(for: kAXRoleAttribute)
    }
    
    func pid() -> pid_t? {
        let pointer = UnsafeMutablePointer<pid_t>.allocate(capacity: 1)
        let error = AXUIElementGetPid(self.elementRef, pointer)
        return error == .success ? pointer.pointee : nil
    }
    
    func bringToFront() {
        if let isMainWindow = self.rawValue(for: NSAccessibilityAttributeName.main.rawValue) as? Bool, isMainWindow
        {
            return
        }
        
        AXUIElementSetAttributeValue(self.elementRef,
                                     NSAccessibilityAttributeName.main as CFString,
                                     true as CFTypeRef)
    }
    
    // MARK: - Private functions
    
    static private func createSystemWideElement() -> Self {
        return self.init(elementRef: AXUIElementCreateSystemWide())
    }
    
    private func getPosition() -> CGPoint? {
        return self.value(for: kAXPositionAttribute)
    }
    
    private func set(position: CGPoint) {
        if let value = AXValue.from(value: position, type: .cgPoint) {
            AXUIElementSetAttributeValue(self.elementRef, kAXPositionAttribute as CFString, value)
        }
    }
    
    private func getSize() -> CGSize? {
        return self.value(for: kAXSizeAttribute)
    }
    
    private func set(size: CGSize) {
        if let value = AXValue.from(value: size, type: .cgSize) {
            AXUIElementSetAttributeValue(self.elementRef, kAXSizeAttribute as CFString, value)
        }
    }
    
    private func rawValue(for attribute: String) -> AnyObject? {
        var rawValue: AnyObject?
        let error = AXUIElementCopyAttributeValue(self.elementRef, attribute as CFString, &rawValue)
        return error == .success ? rawValue : nil
    }
    
    private func value(for attribute: String) -> Self? {
        if let rawValue = self.rawValue(for: attribute), CFGetTypeID(rawValue) == AXUIElementGetTypeID() {
            return type(of: self).init(elementRef: rawValue as! AXUIElement)
        }
        
        return nil
    }
    
    private func value(for attribute: String) -> String? {
        return self.rawValue(for: attribute) as? String
    }
    
    private func value<T>(for attribute: String) -> T? {
        if let rawValue = self.rawValue(for: attribute), CFGetTypeID(rawValue) == AXValueGetTypeID() {
            return (rawValue as! AXValue).toValue()
        }
        
        return nil
    }
}
