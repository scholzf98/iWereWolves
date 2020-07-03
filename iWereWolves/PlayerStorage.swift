//
//  PlayerStorage.swift
//  IOS14Test
//
//  Created by Florian Scholz on 01.07.20.
//

import SwiftUI
import Combine

final class PlayerStorage: ObservableObject {
    
    @Published var players: [Player] = []
    @Published var setup: Bool = false
    
    init(players: [Player] = []) {
        self.players = players
    }
    
    private func checkFaiths(player: inout Player) {
        switch player.role.type {
        case .amor:
            player.setFaith(faith: .amor)
        default:
            break
        }
    }
    
    func addPlayer(with name: String, role: RoleType) {
        
        var player = Player(name: name, role: .init(type: role))
        checkFaiths(player: &player)
        players.append(player)
        
    }
    
    func perform(player: inout Player, state: RoleState, cause: RoleCause) {
        
        players.forEach { (player) in
            print(player.faith.name)
        }
        
        player.setState(state: state)
        player.role.setCause(cause: cause)
    }
    
    func needSetup() {
        
        print("pre \(setup)")
        
        setup = containsAmor() && !containsLoved()
        
        print("post \(setup)")
    }
    
    func setLoved(player: inout Player) {
        player.setFaith(faith: .loved)
    }
    
    func containsAmor() -> Bool {
        return players.contains { (element) -> Bool in
            element.faith == .amor
        }
    }
    
    func getPlayer(for faith: Faith) -> Player? {
        
        return players.first { (element) -> Bool in
            element.faith == faith
        }
        
    }
    
    func containsLoved() -> Bool {
        return players.contains { (element) -> Bool in
            element.faith == .loved
        }
    }
    
}
