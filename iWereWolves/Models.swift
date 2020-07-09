//
//  Models.swift
//  IOS14Test
//
//  Created by Florian Scholz on 03.07.20.
//

import Foundation

enum RoleType: String, CaseIterable {
    
    case werewolf
    case prince
    case witch
    case villager
    case hunter
    case bodyguard
    case amor
    
    var name: String {
        switch self {
        case .werewolf: return "Werwolf"
        case .prince: return "Prinz"
        case .villager: return "Dorfbewohner"
        case .witch: return "Hexe"
        case .hunter: return "Jäger"
        case .bodyguard: return "Leibwächter"
        case .amor: return "Amor"
        }
    }
    
}

enum RoleCause {
    
    case eat, lynch, love, heal, prince, safe, poison, killed, revive, shoot, none
    
    var name: String {
        switch self {
        case .eat: return "Gefressen"
        case .lynch: return "Gelyncht"
        case .love: return "Liebeskummer"
        case .heal: return "Geheilt"
        case .prince: return "Der Prinz"
        case .safe: return "Geschützt"
        case .poison: return "Vergiftet"
        case .killed: return "Getötet"
        case .revive: return "Wiederbelebt"
        case .shoot: return "Erschossen"
        case .none: return ""
        }
    }
    
    var isDeadly: Bool {
        
        switch self {
        case .eat, .lynch, .poison, .killed, .shoot: return true
        default:
            return false
        }
        
    }
    
}

struct Role: Hashable {
    var type: RoleType
    var cause: RoleCause
    
    init(type: RoleType, cause: RoleCause = .none) {
        self.type = type
        self.cause = cause
    }
    
    mutating func setCause(cause: RoleCause) {
        self.cause = cause
    }
    
}

enum Faith: String, CaseIterable {
    
    case major, amor, loved, hunter, witch, witchHeal, witchPoison, none
    
    var name: String {
        switch self {
        case .major: return "Bürgermeister"
        case .amor: return "Amor"
        case .loved: return "Verliebter"
        case .hunter: return "Jäger"
        case .witch, .witchHeal, .witchPoison: return ""
        case .none: return "Keine"
        }
    }
    
    var imageName: String {
        switch self {
        case .major: return "person.circle"
        case .amor, .loved: return "heart.circle"
        case .hunter: return "bolt.fill"
        case .witchHeal: return "plus.circle"
        case .witchPoison: return "multiply.circle"
        case .none, .witch: return ""
        }
    }
    
}

enum RoleState {
    case alive, dead
}

enum ActiveAlert {
    case major, loved, timer, hunter, none
}

enum ActionErrorAlert {
    case witchHeal, witchPoison, noWitch, none
}

class Player: Identifiable, ObservableObject, Comparable {
    
    var id = UUID()
    var name: String
    var role: Role
    var state: RoleState
    var faiths: [Faith]
    
    func setState(state: RoleState) {
        self.state = state
    }
    
    func addFaith(faith: Faith) {
        self.faiths.append(faith)
    }
    
    func removeFaith(faith: Faith) {
        self.faiths.removeAll(where: {$0 == faith})
    }
    
    init(name: String, role: Role, state: RoleState = .alive, faiths: [Faith] = [.none]) {
        self.name = name
        self.role = role
        self.state = state
        self.faiths = faiths
    }
    
    static func == (lhs: Player, rhs: Player) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func < (lhs: Player, rhs: Player) -> Bool {
        return lhs.state != rhs.state
    }
    
}

