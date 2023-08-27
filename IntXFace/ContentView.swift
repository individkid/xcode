//
//  ContentView.swift
//  IntXFace
//
//  Created by Paul Coelho on 8/26/23.
//

import SwiftUI

class Keyboard: ObservableObject {
    @Published var string: String = "hello"
    var count = 0
    init() {
        NSEvent.addLocalMonitorForEvents(matching:NSEvent.EventTypeMask.keyDown, handler: {(event: NSEvent) in
            if (self.count == 0) {
                self.string = "ok"
                self.count = 1
            } else {
                self.string = "again"
            }
            print("keyPressed \(event.characters!)")
            return event})
    }
}

class Queue: ObservableObject {
    @Published var float: CGFloat = 0
    var floats: [CGFloat] = []
    init(_ float: CGFloat) {
        self.float = float
        NSEvent.addLocalMonitorForEvents(matching:NSEvent.EventTypeMask.applicationDefined, handler: {(event: NSEvent) in
            if (self.floats.isEmpty) {return event}
            self.float = self.floats.first!
            self.floats.removeFirst()
            return event})
    }
    func push(_ float: CGFloat) {
        NSApp.postEvent(
            NSEvent.otherEvent(
                with:.applicationDefined,
                location:NSZeroPoint,
                modifierFlags:.command,
                timestamp:0.0,
                windowNumber:0,
                context:nil,
                subtype:0,
                data1:Int(0),
                data2:Int(0))!,
            atStart:false)
        floats.append(float)
    }
}

struct TextView: NSViewRepresentable {
    @ObservedObject var keyboard: Keyboard
    func makeNSView(context: Context) -> NSView {
        let view = NSTextView.scrollableTextView()
        guard let text = view.documentView as? NSTextView else {return NSView()}
        let font = NSFont.userFont(ofSize:36.0)
        text.font = font
        text.string = keyboard.string
        text.backgroundColor = NSColor.white
        text.textColor = NSColor.black
        text.isEditable = false
        text.isVerticallyResizable = false
        text.isHorizontallyResizable = false
        return text
    }
    func updateNSView(_ view: NSView, context: Context) {
        guard let text = view as? NSTextView else {return}
        text.string = keyboard.string
    }
}

struct ContentView: View {
    @StateObject var keyboard = Keyboard()
    @ObservedObject var queue = Queue(0.5)
    let thickness : CGFloat = 10
    func ratioHeight(_ height: CGFloat, _ delta: CGFloat) -> CGFloat {
        var value = queue.float*height-delta
        if (value < 0) {value = 0}
        if (value > height-thickness) {value = height-thickness}
        return value/height
    }
    func validHeight(_ height: CGFloat, _ count: Int) -> CGFloat {
        var value = height - CGFloat(count)*height*queue.float - CGFloat(count)*thickness
        if (value < 0) {value = 0}
        return value
    }
    var body: some View {
        GeometryReader{geo in VStack(spacing: 0) {
            TextView(keyboard: keyboard)/*Color.blue*/
                .frame(height:validHeight(geo.size.height,1))
            Color.orange.frame(height: thickness)
                .gesture(DragGesture(coordinateSpace:.local).onChanged{val in queue
                .push(ratioHeight(geo.size.height,val.translation.height))})
            TextView(keyboard: keyboard)/*Color.blue*/
                .frame(height:validHeight(geo.size.height,0))
        }}
    }
}
