//
//  ContentView.swift
//  SwiftUI-NSTextView-CursorFix
//
//  Created by Frederik Handberg on 05/03/2026.
//

import SwiftUI

struct ContentView: View {
    @State private var text: String = "Hover over this text to see the iBeam cursor.\n\nThen, open the overlay and hover over it. The cursor will properly remain an arrow, thanks to the custom bridging logic!"
    @State private var showOverlay: Bool = false
    
    var body: some View {
        ZStack {
            // Background Layer: The Custom AppKit Text View
            VStack(alignment: .leading) {
                Button("Toggle Overlay") {
                    withAnimation(.easeInOut) {
                        showOverlay.toggle()
                    }
                }
                .padding()
                
                OverlayAwareTextEditor(text: $text)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            // Foreground Layer: The Overlay
            if showOverlay {
                // Dimming Background
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut) {
                            showOverlay = false
                        }
                    }
                    .zIndex(1)
                
                // Overlay Content
                VStack(spacing: 20) {
                    Image(systemName: "cursorarrow")
                        .font(.system(size: 40))
                    
                    Text("I am an Overlay")
                        .font(.headline)
                    
                    Text("Hovering over me will NOT show the I-Beam cursor, even though there is an NSTextView directly underneath me.")
                        .multilineTextAlignment(.center)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Button("Close") {
                        withAnimation(.easeInOut) {
                            showOverlay = false
                        }
                    }
                }
                .padding(30)
                .frame(width: 300)
                // Place the ArrowCursorView right behind the overlay's visual elements
                .background(
                    ZStack {
                        ArrowCursorView()
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(nsColor: .windowBackgroundColor))
                            .shadow(radius: 20)
                    }
                )
                .zIndex(2)
            }
        }
        .frame(minWidth: 500, minHeight: 400)
    }
}
