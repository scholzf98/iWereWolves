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
        case .witch:
            player.addFaith(faith: .witchHeal)
            player.addFaith(faith: .witchPoison)
        default:
            break
        }
    }
    
    func addPlayer(with name: String, role: RoleType) {
        let player = Player(name: name, role: .init(type: role))
        checkFaiths(player: player)
        players.append(player)
        objectWillChange.send()
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
            fatalError()
        }
        
    }
    
    func performMajor(cause: RoleCause) {
        
        if let major = getPlayer(for: .major) {
            major.removeFaith(faith: .major)
            major.role.setCause(cause: cause)
            major.setState(state: .dead)
            _ = validate()
        } else {
            fatalError()
        }
        
    }
    
    func performWitch(cause: RoleCause) {
        
        if let witch = getPlayer(for: .witch) {
            witch.faiths = []
            witch.role.setCause(cause: cause)
            witch.setState(state: .dead)
            _ = validate()
        } else {
            fatalError()
        }
        
    }
    
    func performHunter(cause : RoleCause) {
        
        if let hunter = getPlayer(for: .hunter) {
            hunter.setState(state: .dead)
            hunter.role.setCause(cause: cause)
            _ = validate()
        } else {
            fatalError()
        }
        
    }
    
    func checkWitchAbilities(cause: RoleCause) {
        if cause == .heal || cause == .poison {
            if let witch = getPlayer(for: .witch) {
                
                if cause == .heal {
                    witch.removeFaith(faith: .witchHeal)
                } else {
                    witch.removeFaith(faith: .witchPoison)
                }
                
            } else {
                fatalError()
            }
            objectWillChange.send()
        }
    }
    
    func performShield(player: Player) {
        player.addFaith(faith: .shield)
        player.setState(state: .alive)
    }
    
    func performPrince(player: Player, cause: RoleCause) {
        
        if cause == .lynch {
            player.addFaith(faith: .prince)
        } else {
            player.setState(state: .dead)
            player.role.setCause(cause: cause)
        }
    }
    
    func perform(player: Player, state: RoleState, cause: RoleCause) {
        
        checkWitchAbilities(cause: cause)
        
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
            } else if player.role.type == .witch {
                performWitch(cause: cause)
                objectWillChange.send()
                return
            } else if player.role.type == .prince {
                performPrince(player: player, cause: cause)
                objectWillChange.send()
                return
            }
            
            player.setState(state: state)
            player.role.setCause(cause: cause)
            objectWillChange.send()
            return
        } else {
            
            if cause == .shield {
                performShield(player: player)
                objectWillChange.send()
                return
            }
            
            player.setState(state: state)
            player.role.setCause(cause: cause)
            objectWillChange.send()
            return
        }
        
    }
    
    func validate() -> ActiveAlert {
        let amor = players.contains(where: { $0.faiths.contains(.amor) })
        let loved = players.contains(where: { $0.faiths.contains(.loved) })
        let major = players.contains(where: { $0.faiths.contains(.major) })
        let hunter = players.contains(where: { $0.faiths.contains(.hunter) })
        var alive = players
        alive.removeAll(where: { $0.state == .dead } )
        
        var value: ActiveAlert = .none
        
        if amor && !loved {
            value = .loved
        } else if !major {
            
            var deadPlayers = players
            deadPlayers.removeAll(where: {$0.state == .alive})
            
            if deadPlayers.count != 0 {
                value = .major
            } else {
                value = .none
            }
        } else if !alive.isEmpty {
            
            if alive.count == 2 {
                if alive.first!.faiths.contains(.loved) || alive.first!.faiths.contains(.amor) {
                    let loved = getPlayer(for: .loved)
                    let amor = getPlayer(for: .amor)
                    
                    if loved != nil && amor != nil {
                        value = .finished
                    }
                    
                }
            } else {
                value = .none
            }
            
        } else if hunter {
            
            if let pHunter = getPlayer(for: .hunter) {
                
                if pHunter.state == .dead {
                    players.forEach { (player) in
                        if player.role.cause == .shoot {
                            value = .none
                        } else {
                            value = .hunter
                        }
                    }
                }
                
            }
        } else {
            value = .none
        }
        
        return value
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
