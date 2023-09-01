//
//  IntXFaceApp.swift
//  IntXFace
//
//  Created by Paul Coelho on 8/26/23.
//

import SwiftUI

var unique: Int = 0
class Title<Type>: Queue<[Type]> {
    let value: Type
    init(_ value: Type) {
        self.value = value
        super.init([])
    }
    func get(_ index: Int) -> Type {
        if (index < vector.count) {return vector[index]}
        return value
    }
    func set(_ index: Int, _ value: Type) {
        var vector = super.vector
        while (index >= vector.count) {vector.append(self.value)}
        vector[index] = value
        push(vector)
    }
}

@main
struct IntXFaceApp: App {
    @StateObject var title: Title<String> = Title("IntXFace")
    var body: some Scene {
        WindowGroup(for: Int.self) {$viewId in
            ContentView(viewId: $viewId, title: title)
            .navigationTitle(title.get(viewId))
        } defaultValue: {
            let temp = unique
            unique = unique + 1
            return temp
        }
    }
}
