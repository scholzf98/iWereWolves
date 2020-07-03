//
//  PlayerStorage.swift
//  IOS14Test
//
//  Created by Florian Scholz on 01.07.20.
//

import SwiftUI
import Combine

final class PlayerStorage: ObservableObject {
    
    var players: [Player] {
        willSet {
            objectWillChange.send()
        }
    }
    
    var objectWillChange = ObservableObjectPublisher()
    
    init(players: [Player] = []) {
        self.players = players
    }
    
    private func checkFaiths(player: Player) {
        switch player.role.type {
        case .amor:
            player.setFaith(faith: .amor)
        default:
            break
        }
    }
    
    func addPlayer(with name: String, role: RoleType) {
        
        var player = Player(name: name, role: .init(type: role))
        checkFaiths(player: player)
        players.append(player)
        
    }
    
    func amorAndLoved(cause: RoleCause) {
        
        if let loved = getPlayer(for: .loved), let amor = getPlayer(for: .amor) {
            
            loved.setState(state: .dead)
            loved.role.setCause(cause: cause)
            
            amor.setState(state: .dead)
            amor.role.setCause(cause: cause)
            
            objectWillChange.send()
            
        } else {
            fatalError()
        }
        
    }
    
    func perform(player: Player, state: RoleState, cause: RoleCause) {
        
        if cause.isDeadly && (player.faith == .amor || player.faith == .loved) {
            amorAndLoved(cause: cause)
        } else {
            
            player.setState(state: state)
            player.role.setCause(cause: cause)
            
        }
        
        objectWillChange.send()
        
    }
    
    func needSetup() -> Bool {
        
        let amor = players.contains(where: { $0.role.type == .amor })
        
        print("amor \(amor)")
        
        let loved = players.contains(where: { $0.faith == .loved })
        
        print("loved \(loved)")
        
        return amor && !loved
        
    }
    
    func getPlayer(for faith: Faith) -> Player? {
        return players.first(where: { $0.faith == faith })
    }
    
    func setLoved(player: Player) {
        
        print("pre \(player.name) -> with \(player.faith)")
        player.setFaith(faith: .loved)
        print("post \(player.name) -> with \(player.faith)")
        objectWillChange.send()
    }

    
}
