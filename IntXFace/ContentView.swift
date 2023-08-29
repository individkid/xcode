//
//  ContentView.swift
//  IntXFace
//
//  Created by Paul Coelho on 8/26/23.
//

import SwiftUI

class Heap: ObservableObject {
    @Published var filter: String = "filter"
    @Published var input: String = "input"
    @Published var output: String = "output"
    var count = 0
    init() {
        NSEvent.addLocalMonitorForEvents(matching:NSEvent.EventTypeMask.keyDown, handler: {(event: NSEvent) in
            if (self.count == 0) {
                self.output = "hello"
                self.count = 1
            } else if (self.count == 1) {
                self.output = "ok"
                self.count = 2
            } else if (self.count == 2){
                self.output = "again"
                self.count = 3
            } else {
                self.output = "and"
                self.count = 2
            }
            return event})
    }
}

class Queue: ObservableObject {
    @Published var vector: [CGFloat] = []
    var vectors: [[CGFloat]] = []
    var closures: [()->Void] = []
    init(_ count: Int) {
        let float: CGFloat = 1.0/CGFloat(count)
        for _ in 0..<count {self.vector.append(float)}
        NSEvent.addLocalMonitorForEvents(matching:NSEvent.EventTypeMask.applicationDefined,
        handler: {(event: NSEvent) in self.closures.first!(); self.closures.removeFirst(); return event})
    }
    func apply() {
        if (vectors.isEmpty) {return}
        vector = vectors.first!
        vectors.removeFirst()
    }
    func push(_ vector: [CGFloat]) {
        vectors.append(vector)
        push(apply)
    }
    func push(_ closure: @escaping () -> Void) {
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
        closures.append(closure)
    }
}

struct ContentView: View {
    @ObservedObject var heap: Heap
    @StateObject var queue = Queue(4)
    @State var scratch: String = "scatch"
    let dividers : CGFloat = 3
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
            TextEditor(text: $scratch)
                .frame(height: {() -> CGFloat in
                let ratio = queue.vector[3]
                let height = geo.size.height-dividers*thickness
                return ratio*height}())
            Color.green.frame(height: thickness)
                .gesture(DragGesture(coordinateSpace:.local).onChanged{val in
                let height = geo.size.height-dividers*thickness
                let delta = -val.translation.height
                queue.push(ratioHeight(queue.vector,height,delta,4,2))})
            TextEditor(text: .constant(heap.filter))
                .frame(height: {() -> CGFloat in
                let ratio = queue.vector[2]
                let height = geo.size.height-dividers*thickness
                return ratio*height}())
            Color.yellow.frame(height: thickness)
                .gesture(DragGesture(coordinateSpace:.local).onChanged{val in
                let height = geo.size.height-dividers*thickness
                let delta = -val.translation.height
                queue.push(ratioHeight(queue.vector,height,delta,4,1))})
            TextEditor(text: .constant(heap.input))
                .frame(height: {() -> CGFloat in
                let ratio = queue.vector[1]
                let height = geo.size.height-dividers*thickness
                return ratio*height}())
            Color.orange.frame(height: thickness)
                .gesture(DragGesture(coordinateSpace:.local).onChanged{val in
                let height = geo.size.height-dividers*thickness
                let delta = -val.translation.height
                queue.push(ratioHeight(queue.vector,height,delta,4,0))})
            TextEditor(text: .constant(heap.output))
                .frame(height: {() -> CGFloat in
                let ratio = queue.vector[0]
                let height = geo.size.height-dividers*thickness
                return ratio*height}())
        }}
    }
}
