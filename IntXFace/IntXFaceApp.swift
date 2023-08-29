//
//  IntXFaceApp.swift
//  IntXFace
//
//  Created by Paul Coelho on 8/26/23.
//

import SwiftUI

@main
struct IntXFaceApp: App {
    @StateObject var heap = Heap()
    var body: some Scene {
        WindowGroup {
            ContentView(heap: heap)
        } .commands {
            CommandGroup(after: CommandGroupPlacement.pasteboard) {
                Button("Append to Filter") {
                    heap.filter = clipboardContent()
                } .keyboardShortcut("F")
                Button("Append to Input") {
                    heap.input = clipboardContent()
                } .keyboardShortcut("I")
            }
        }
    }
    func clipboardContent() -> String
    {
        return NSPasteboard.general.string(forType: .string) ?? ""
    }
}
