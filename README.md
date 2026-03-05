# SwiftUI NSTextView Cursor Fix

I figured out a solution to a known and frustrating macOS AppKit-to-SwiftUI bridging issue: **`NSTextView` aggressively hijacking the mouse cursor through SwiftUI overlays.**

This repository includes my solution to fix this issue.
Feel free to use in your own projects.

## The Problem

When building macOS apps with SwiftUI, you often need to wrap AppKit components like `NSTextView` to access more advanced text editing features than what SwiftUI offers. However, if you place a SwiftUI overlay (like a custom modal, popup, or floating menu) directly above that `NSTextView`, you'll run into an annoying bug:

**The cursor will still change to an I-Beam (`NSCursor.iBeam`) when hovering over your overlay, even though the text view is completely obscured.** Because `NSTextView` operates deep within the AppKit responder chain, it takes higher priority for cursor updates than the SwiftUI views layered on top of it.
I was unable to find any guidance on how to handle this bridging discrepancy in Apple's official documentation.

## The Solution

This repository provides a clean, self-contained Minimum Reproducible Example (MRE) and a drop-in workaround that you can easily use. 

It solves the problem using a two-pronged approach:
1. **`OverlayAwareTextView`**: A subclass of `NSTextView` that explicitly intercepts and drops mouse/cursor events if it detects that the mouse is hitting a view that is *not* the text view or its descendants (i.e., it is covered by an overlay).
2. **`ArrowCursorView`**: An `NSViewRepresentable` that you place at the bottom of your SwiftUI overlay's Z-stack. It uses a custom `NSTrackingArea` to forcefully reassert the standard arrow cursor (`NSCursor.arrow`) when the user interacts with the overlay.

## Quick Start

To use this in your own project, copy the following two files:
- `OverlayAwareTextView.swift`
- `ArrowCursorView.swift`

### Usage

1. Replace your standard text editor with the wrapper:
```swift
OverlayAwareTextEditor(text: $myText)
```

2. Inside your SwiftUI overlay, place the ArrowCursorView as the deepest background layer to intercept the cursor:
```swift
if showOverlay {
    VStack {
        Text("My Custom Overlay")
        // ... overlay content ...
    }
    .background(
        ZStack {
            ArrowCursorView() // Wakes up the tracking area and forces the arrow
            RoundedRectangle(cornerRadius: 12).fill(Color.windowBackgroundColor)
        }
    )
}
```

### Try the Demo

Clone this repository and build the project in Xcode.

1. Hover over the text area to see the standard I-Beam cursor.

2. Click "Toggle Overlay".

3. Hover over the newly presented overlay. Notice how the cursor correctly remains an arrow, completely ignoring the `NSTextView` underneath.

## License

This project is released into the public domain under [The Unlicense](LICENSE). Feel free to drop this workaround directly into your own commercial or open-source macOS apps without any restrictions or attribution required!
