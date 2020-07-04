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
    case haunter
    case bodyguard
    case amor
    
    var name: String {
        switch self {
        case .werewolf: return "Werwolf"
        case .prince: return "Prinz"
        case .villager: return "Dorfbewohner"
        case .witch: return "Hexe"
        case .haunter: return "Jäger"
        case .bodyguard: return "Leibwächter"
        case .amor: return "Amor"
        }
    }
    
}

enum RoleCause {
    
    case eat, lynch, love, heal, prince, safe, poison, killed, revive, none
    
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
        case .none: return ""
        }
    }
    
    var isDeadly: Bool {
        
        switch self {
        case .eat, .lynch, .poison, .killed: return true
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
    
    case major, amor, loved, none
    
    var name: String {
        switch self {
        case .major: return "Bürgermeister"
        case .amor: return "Amor"
        case .loved: return "Verliebter"
        case .none: return "Keine"
        }
    }
    
    var imageName: String {
        switch self {
        case .major: return "person.circle"
        case .amor, .loved: return "heart.circle"
        case .none: return ""
        }
    }
    
}

enum RoleState {
    case alive, dead
}

enum ActiveAlert {
    case major, loved, timer, none
}

class Player: Identifiable, ObservableObject {
    
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
    
}

