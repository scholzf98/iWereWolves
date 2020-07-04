//
//  iWereWolvesApp.swift
//  iWereWolves
//
//  Created by Florian Scholz on 03.07.20.
//

import SwiftUI

let testData =
    [
        Player(name: "Test", role: .init(type: .amor), state: .alive, faiths: [.amor]),
        Player(name: "Test2", role: .init(type: .villager), state: .alive, faiths: [.loved]),
        Player(name: "Test3", role: .init(type: .villager), state: .alive, faiths: [.none])
    ]

@main
struct iWereWolvesApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(playerStore: PlayerStorage(players: testData))
        }
    }
}
