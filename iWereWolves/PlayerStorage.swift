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
            player.addFaith(faith: .amor)
        default:
            break
        }
    }
    
    func addPlayer(with name: String, role: RoleType) {
        var player = Player(name: name, role: .init(type: role))
        checkFaiths(player: player)
        players.append(player)
    }
    
    func performAmorAndLoved(cause: RoleCause) {
        
        if let loved = getPlayer(for: .loved), let amor = getPlayer(for: .amor) {
            loved.setState(state: .dead)
            loved.role.setCause(cause: cause)
            
            amor.setState(state: .dead)
            amor.role.setCause(cause: cause)
            
            loved.removeFaith(faith: .loved)
            amor.removeFaith(faith: .amor)
            
            if loved.faiths.contains(.major) {
                performMajor(cause: cause)
            }
            
            objectWillChange.send()
            
        } else {
            
        }
        
    }
    
    func performMajor(cause: RoleCause) {
        
        if let major = getPlayer(for: .major) {
            major.removeFaith(faith: .major)
            major.role.setCause(cause: cause)
            major.setState(state: .dead)
        } else {
            fatalError()
        }
        
    }
    
    func performHunter(cause : RoleCause) {
        
        if let hunter = getPlayer(for: .hunter) {
            hunter.setState(state: .dead)
            hunter.role.setCause(cause: cause)
        } else {
            fatalError()
        }
        
    }
    
    func perform(player: Player, state: RoleState, cause: RoleCause) {
        
        if cause.isDeadly {
            
            if player.faiths.contains(.amor) || player.faiths.contains(.loved) {
                performAmorAndLoved(cause: cause)
                objectWillChange.send()
                return
            } else if player.faiths.contains(.major) {
                performMajor(cause: cause)
                objectWillChange.send()
                return
            } else if player.faiths.contains(.hunter) {
                performHunter(cause: cause)
                objectWillChange.send()
                return
            }
            
        } else {
            player.setState(state: state)
            player.role.setCause(cause: cause)
        }
        
        objectWillChange.send()
        
    }
    
    func validate() -> ActiveAlert {
        let amor = players.contains(where: { $0.faiths.contains(.amor) })
        let loved = players.contains(where: { $0.faiths.contains(.loved) })
        let major = players.contains(where: { $0.faiths.contains(.major) })
        
        if amor && !loved {
            return .loved
        } else if !major {
            return .major
        } else {
            return .none
        }
        
    }
    
    func getPlayer(for faith: Faith) -> Player? {
        return players.first(where: { $0.faiths.contains(faith) })
    }
    
    func setMajor(player: Player) {
        
        if !player.faiths.contains(.major) {
            player.faiths.append(.major)
        }
        
        objectWillChange.send()
        
    }
    
    func setLoved(player: Player) {
        
        if !player.faiths.contains(.loved) {
            player.faiths.append(.loved)
        }
        
        objectWillChange.send()
    }

    
}
