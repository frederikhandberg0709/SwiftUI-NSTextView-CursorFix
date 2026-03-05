//
//  ArrowCursorView.swift
//  SwiftUI-NSTextView-CursorFix
//
//  Created by Frederik Handberg on 05/03/2026.
//

import AppKit
import SwiftUI

/// An NSView that intercepts tracking events to aggressively force the arrow cursor.
class CursorRectView: NSView {
    private var trackingArea: NSTrackingArea?
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        
        if let existing = trackingArea {
            removeTrackingArea(existing)
        }
        
        let options: NSTrackingArea.Options = [
            .activeInKeyWindow,
            .cursorUpdate,
            .mouseEnteredAndExited,
            .mouseMoved,
            .inVisibleRect
        ]
        
        trackingArea = NSTrackingArea(rect: .zero, options: options, owner: self, userInfo: nil)
        addTrackingArea(trackingArea!)
    }
    
    override func resetCursorRects() {
        super.resetCursorRects()
        addCursorRect(bounds, cursor: .arrow)
    }
    
    // MARK: - Smart Cursor Routing
    
    private func shouldForceArrow(for event: NSEvent) -> Bool {
        guard let window = self.window, let contentView = window.contentView else {
            return true
        }
        
        let hitView = contentView.hitTest(event.locationInWindow)
        
        // If the mouse is hitting the background editor, force the arrow
        if hitView is OverlayAwareTextView {
            return true
        }
        
        // Allow iBeam if hovering over a specific text field inside the overlay itself
        if let hitView = hitView {
            if hitView is NSTextField || hitView is NSTextView {
                return false
            }
        }
        
        return true
    }
    
    // MARK: - Event Overrides
    
    // Aggressively force the cursor on state changes
    override func cursorUpdate(with event: NSEvent) {
        if shouldForceArrow(for: event) { NSCursor.arrow.set() }
    }
    
    override func mouseEntered(with event: NSEvent) {
        if shouldForceArrow(for: event) { NSCursor.arrow.set() }
    }
    
    override func mouseMoved(with event: NSEvent) {
        if shouldForceArrow(for: event) { NSCursor.arrow.set() }
    }
    
    override func mouseExited(with event: NSEvent) {
        // When the mouse leaves the overlay, we force the window to completely
        // recalculate all cursor rects. This wakes up the NSTextView underneath
        // and forces it to reapply the iBeam instantly.
        if let contentView = self.window?.contentView {
            self.window?.invalidateCursorRects(for: contentView)
        }
    }
    
    override func hitTest(_ point: NSPoint) -> NSView? {
        if super.hitTest(point) != nil {
            return self
        }
        return nil
    }
}

/// A SwiftUI wrapper to place behind overlays to catch and fix cursor events.
struct ArrowCursorView: NSViewRepresentable {
    func makeNSView(context: Context) -> CursorRectView {
        return CursorRectView()
    }
    
    func updateNSView(_ nsView: CursorRectView, context: Context) {}
}
