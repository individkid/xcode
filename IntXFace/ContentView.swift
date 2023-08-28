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
    @Published var vector: [CGFloat] = []
    var vectors: [[CGFloat]] = []
    init(_ count: Int) {
        let float: CGFloat = 1.0/CGFloat(count)
        for _ in 0..<count {self.vector.append(float)}
        NSEvent.addLocalMonitorForEvents(matching:NSEvent.EventTypeMask.applicationDefined, handler: {(event: NSEvent) in
            if (self.vectors.isEmpty) {return event}
            self.vector = self.vectors.first!
            self.vectors.removeFirst()
            return event})
    }
    func push(_ float: [CGFloat]) {
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
        vectors.append(float)
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
    @ObservedObject var queue = Queue(3)
    let thickness : CGFloat = 10
    func ratioHeight(_ given: [CGFloat], _ height: CGFloat, _ delta: CGFloat, _ count: Int, _ start: Int) -> [CGFloat] {
        var vector = given
        var from = start
        var move = start
        var todo = delta
        for i in 0..<count {vector[i] = vector[i]*height}
        // if delta is positive/negative, move from region above/below to the region below/above the start
        if (delta > 0) {from = from + 1}
        else {todo = -delta; move = move + 1}
        while (todo > 0) {
            // if all removed, use the next above/below to move from
            if (vector[from] == 0) {if (delta > 0) {from = from + 1} else {from = from - 1}}
            // if no more above/below, return early
            if (from < 0 || from >= count) {break}
            // move minimum of todo or vector[from]
            if (todo > vector[from]) {
                vector[move] = vector[move] + vector[from]; todo = todo - vector[from]; vector[from] = 0
            } else {
                vector[move] = vector[move] + todo; vector[from] = vector[from] - todo; todo = 0
            }
        }
        for i in 0..<count {vector[i] = vector[i]/height}
        return vector
    }
    var body: some View {
        GeometryReader{geo in VStack(spacing: 0) {
            TextView(keyboard: keyboard)/*Color.blue*/.frame(height: {() -> CGFloat in
                let ratio = queue.vector[2]
                let height = geo.size.height-2.0*thickness
                return ratio*height}())
            Color.yellow.frame(height: thickness)
                .gesture(DragGesture(coordinateSpace:.local).onChanged{val in
                let height = geo.size.height-2.0*thickness
                let delta = -val.translation.height
                queue.push(ratioHeight(queue.vector,height,delta,3,1))})
            TextView(keyboard: keyboard)/*Color.blue*/.frame(height: {() -> CGFloat in
                let ratio = queue.vector[1]
                let height = geo.size.height-2.0*thickness
                return ratio*height}())
            Color.orange.frame(height: thickness)
                .gesture(DragGesture(coordinateSpace:.local).onChanged{val in
                let height = geo.size.height-2.0*thickness
                let delta = -val.translation.height
                queue.push(ratioHeight(queue.vector,height,delta,3,0))})
            TextView(keyboard: keyboard)/*Color.blue*/.frame(height: {() -> CGFloat in
                let ratio = queue.vector[0]
                let height = geo.size.height-2.0*thickness
                return ratio*height}())
        }}
    }
}
