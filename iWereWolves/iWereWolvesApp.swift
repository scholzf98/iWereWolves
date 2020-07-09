//
//  iWereWolvesApp.swift
//  iWereWolves
//
//  Created by Florian Scholz on 03.07.20.
//

import SwiftUI

let testData =
    [
        Player(name: "Test", role: .init(type: .amor), faiths: [.amor]),
        Player(name: "Test2", role: .init(type: .hunter), faiths: [.loved, .major]),
        Player(name: "Test3", role: .init(type: .bodyguard)),
        Player(name: "Test5", role: .init(type: .witch), faiths: [.witch, .witchHeal, .witchPoison])
    ]

@main
struct iWereWolvesApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(playerStore: PlayerStorage(players: testData))
        }
    }
}
