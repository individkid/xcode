//
//  IntXFaceApp.swift
//  IntXFace
//
//  Created by Paul Coelho on 8/26/23.
//

import SwiftUI

var unique: Int = 0

@main
struct IntXFaceApp: App {
    var body: some Scene {
        WindowGroup(for: Int.self) {$viewId in
            ContentView(viewId: $viewId)
            .navigationTitle("IntXFace\(viewId)")
        } defaultValue: {
            let temp = unique
            unique = unique + 1
            return temp
        }
    }
}
