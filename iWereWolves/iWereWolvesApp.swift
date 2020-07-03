//
//  iWereWolvesApp.swift
//  iWereWolves
//
//  Created by Florian Scholz on 03.07.20.
//

import SwiftUI

let testData =
    [
        Player(name: "Test", role: .init(type: .amor), state: .alive, faith: .amor),
        Player(name: "Test2", role: .init(type: .villager), state: .alive, faith: .loved),
        Player(name: "Test3", role: .init(type: .villager), state: .alive, faith: .none, isMajor: true)
    ]

@main
struct iWereWolvesApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(playerStore: PlayerStorage(players: testData))
        }
    }
}
