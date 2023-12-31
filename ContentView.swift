//
//  ContentView.swift
//  IntXFace
//
//  Created by Paul Coelho on 8/26/23.
//

import SwiftUI

var queue: Int = 0
class Queue<Type>: ObservableObject {
    @Published var vector: Type
    var vectors: [Type] = []
    var closures: [()->Void] = []
    var ident: Int
    init(_ vector: Type) {
        self.vector = vector
        ident = queue
        queue = queue + 1
        NSEvent.addLocalMonitorForEvents(matching:NSEvent.EventTypeMask.applicationDefined,
        handler: {(event: NSEvent) in
        if (event.data1 == self.ident) {
        self.closures.first!()
        self.closures.removeFirst()}
        return event})
    }
    func apply() {
        if (vectors.isEmpty) {return}
        vector = vectors.first!
        vectors.removeFirst()
    }
    func push(_ vector: Type) {
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
                data1:Int(ident),
                data2:Int(0))!,
            atStart:false)
        closures.append(closure)
    }
}

func getTitle(_ value: String) -> String {
    // TODO use portion of first word of value after last slash if any
    return value
}
func getVector(_ count: Int) -> [CGFloat] {
    var vector: [CGFloat] = []
    let float: CGFloat = 1.0/CGFloat(count)
    for _ in 0..<count {vector.append(float)}
    return vector
}
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
typealias Unsafe = Optional<UnsafeMutablePointer<Int8>>
func openFilter(_ viewId: Int, _ filter: String) {
    var argv: [String] = []
    // TODO split into command and arguments
    let argc:[Int] = Swift.Array(0..<argv.count)
    let ptr = UnsafeMutablePointer<Unsafe>.allocate(capacity:argv.count+1)
    for (val,idx) in zip(argv,argc) {
    let idc:[Int] = Swift.Array(0..<val.count)
    ptr[idx] = UnsafeMutablePointer<Int8>.allocate(capacity:val.count+1)
    for (v,i) in zip(val.utf8,idc) {ptr[idx]?[i] = Int8(v)}
    ptr[idx]?[val.count] = Int8(0)}
    ptr[argv.count] = nil
    if (argv.count > 0) {open_filter(Int32(viewId),ptr)}
    for idx in argc {ptr[idx]!.deallocate()}
    ptr.deallocate()
}

struct ContentView: View {
    @Binding var viewId: Int
    @ObservedObject var title: Title<String>
    @State private var scratch: String = "scatch"
    @State private var filter: String = "filter"
    @State private var input: String = "input"
    @State private var output: String = "output"
    @State private var error: String = "error"
    @State private var mode: String = "Manual"
    @StateObject var queue = Queue(getVector(5))
    let dividers : CGFloat = 40
    let thickness : CGFloat = 10
    var body: some View {GeometryReader() {geo in
        let height = (geo.size.height > dividers ? geo.size.height-dividers : 0.0)
        VStack(spacing: 0) {
            TextEditor(text: $scratch)
                .frame(height: {queue.vector[4]*height}())
                .onChange(of: scratch) {val in
                print("view: \(viewId) text: \(val)")}
            Color.green.frame(height: thickness)
                .gesture(DragGesture(coordinateSpace:.local).onChanged() {val in
                queue.push(ratioHeight(queue.vector,height,-val.translation.height,5,3))})
            TextEditor(text: .constant(filter))
                .frame(height: {queue.vector[3]*height}())
                .onChange(of: filter) {val in openFilter(viewId,val); title.set(viewId,getTitle(val))}
            Color.yellow.frame(height: thickness)
                .gesture(DragGesture(coordinateSpace:.local).onChanged() {val in
                queue.push(ratioHeight(queue.vector,height,-val.translation.height,5,2))})
            TextEditor(text: .constant(input))
                .frame(height: {queue.vector[2]*height}())
            Color.orange.frame(height: thickness)
                .gesture(DragGesture(coordinateSpace:.local).onChanged() {val in
                queue.push(ratioHeight(queue.vector,height,-val.translation.height,5,1))})
            TextEditor(text: .constant(output))
                .frame(height: {queue.vector[1]*height}())
            Color.red.frame(height: thickness)
                .gesture(DragGesture(coordinateSpace:.local).onChanged() {val in
                queue.push(ratioHeight(queue.vector,height,-val.translation.height,5,0))})
            TextEditor(text: .constant(error))
                .frame(height: {queue.vector[0]*height}())
        }} .toolbar {
            Button(mode) {
                if (mode == "Manual") {mode = "Character"}
                else if (mode == "Character") {mode = "Line"}
                else {mode = "Manual"}}
            Button("Filter") {
                filter = NSPasteboard.general.string(forType: .string) ?? ""}
                .keyboardShortcut("F")
            Button("Input") {
                input = NSPasteboard.general.string(forType: .string) ?? ""}
                .keyboardShortcut("I")
       }
    }
}
