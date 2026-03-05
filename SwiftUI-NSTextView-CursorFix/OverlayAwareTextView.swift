//
//  OverlayAwareTextView.swift
//  SwiftUI-NSTextView-CursorFix
//
//  Created by Frederik Handberg on 05/03/2026.
//

import AppKit
import SwiftUI

/// A custom NSTextView that respects SwiftUI overlays by conditionally dropping cursor events.
class OverlayAwareTextView: NSTextView {
    
    override func cursorUpdate(with event: NSEvent) {
        guard let window = self.window else {
            super.cursorUpdate(with: event)
            return
        }
        
        // If the hit view is not us and not our descendants, we are covered.
        let hitView = window.contentView?.hitTest(event.locationInWindow)
        if let hitView = hitView, hitView != self && !hitView.isDescendant(of: self) {
            return
        }
        
        super.cursorUpdate(with: event)
    }
    
    override func addCursorRect(_ aRect: NSRect, cursor anObj: NSCursor) {
        guard let window = self.window, let contentView = window.contentView else {
            super.addCursorRect(aRect, cursor: anObj)
            return
        }
        
        let rectCenterLocal = NSPoint(x: aRect.midX, y: aRect.midY)
        let windowPoint = self.convert(rectCenterLocal, to: nil)
        
        // Drop the cursor rect entirely if obscured by an overlay to prevent edge-bleeding/flashing.
        if let hitView = contentView.hitTest(windowPoint) {
            if hitView != self && !hitView.isDescendant(of: self) {
                return
            }
        }
        
        super.addCursorRect(aRect, cursor: anObj)
    }
    
    override func mouseMoved(with event: NSEvent) {
        guard let window = self.window else {
            super.mouseMoved(with: event)
            return
        }
        
        let hitView = window.contentView?.hitTest(event.locationInWindow)
        if let hitView = hitView, hitView != self && !hitView.isDescendant(of: self) {
            return
        }
        
        super.mouseMoved(with: event)
    }
    
    override func mouseEntered(with event: NSEvent) {
        guard let window = self.window else {
            super.mouseEntered(with: event)
            return
        }
        
        let hitView = window.contentView?.hitTest(event.locationInWindow)
        if let hitView = hitView, hitView != self && !hitView.isDescendant(of: self) {
            return
        }
        
        super.mouseEntered(with: event)
    }
    
    override func mouseExited(with event: NSEvent) {
        guard let window = self.window else {
            super.mouseExited(with: event)
            return
        }
        
        let hitView = window.contentView?.hitTest(event.locationInWindow)
        if let hitView = hitView, hitView != self && !hitView.isDescendant(of: self) {
            return
        }
        
        super.mouseExited(with: event)
    }
}

/// A simple SwiftUI wrapper for the custom AppKit text view.
struct OverlayAwareTextEditor: NSViewRepresentable {
    @Binding var text: String
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        let textView = OverlayAwareTextView()
        
        textView.string = text
        textView.isSelectable = true
        textView.isEditable = true
        textView.font = .systemFont(ofSize: 14)
        
        scrollView.documentView = textView
        return scrollView
    }
    
    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        if let textView = scrollView.documentView as? OverlayAwareTextView {
            if textView.string != text {
                textView.string = text
            }
        }
    }
}
