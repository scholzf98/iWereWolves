//
//  ContentView.swift
//  IOS14Test
//
//  Created by Florian Scholz on 24.06.20.
//

import SwiftUI
import Combine
import AudioToolbox

struct FaithsView: View {
    var faiths: [Faith]
    
    var body: some View {
        HStack {
            ForEach(faiths, id: \.self) { faith in
                
                if faith == .witchHeal || faith == .witchPoison {
                    Image(systemName: faith.imageName)
                } else {
                    Image(systemName: faith.imageName)
                }
                
            }
        }
        
    }
    
}

struct PlayerRow: View {
    
    @State var player: Player
    @State private var showErrorAlert = false
    @State private var activeErrorAlert: ActionErrorAlert = .none
    @ObservedObject var playerStore: PlayerStorage
    
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(player.name)
                Text(player.role.type.name)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if player.role.cause != .none {
                Text(player.role.cause.name)
            }
            
            if !player.faiths.isEmpty {
                FaithsView(faiths: player.faiths)
            }
            
            Image(systemName: player.state == .alive ? "checkmark.circle" : "multiply.circle")
            
        }.contextMenu {
            
            if playerStore.validate() != .none {
                Button(action: {
                    playerStore.setLoved(player: player)
                }) {
                    Text("Verliebter")
                    Image(systemName: "heart.circle")
                }
                
                Button(action: {
                    playerStore.setMajor(player: player)
                }) {
                    Text("Bürgermeister")
                    Image(systemName: "person.circle")
                }
                
            } else {
                
                Button(action: {
                    playerStore.perform(player: player, state: .dead, cause: .killed)
                }) {
                    Text("Töten")
                    Image(systemName: "multiply.circle")
                }
                
                Button(action: {
                    playerStore.perform(player: player, state: .dead, cause: .shoot)
                }) {
                    Text("Erschießen")
                    Image(systemName: "bolt.fill")
                }
                
                Button(action: {
                    playerStore.perform(player: player, state: .dead, cause: .eat)
                }) {
                    Text("Fressen")
                    Image(systemName: "multiply.circle")
                }
                
                Button(action: {
                    playerStore.perform(player: player, state: .dead, cause: .lynch)
                }) {
                    Text("Lynchen")
                    Image(systemName: "multiply.circle")
                }
                
                Button(action: {
                    
                    if let shielded = playerStore.getPlayer(for: .shield) {
                        
                        if shielded.id == player.id {
                            activeErrorAlert = .alreadyShield
                            showErrorAlert.toggle()
                        } else {
                            shielded.removeFaith(faith: .shield)
                            playerStore.perform(player: player, state: .alive, cause: .shield)
                        }
                        
                    } else {
                        playerStore.perform(player: player, state: .alive, cause: .shield)
                    }
                    
                }) {
                    Text("Geschützt")
                    Image(systemName: "shield.fill")
                }
                
                Button(action: {
                    if let witch = playerStore.getPlayer(for: .witch) {
                        
                        if witch.faiths.contains(.witchPoison) {
                            playerStore.perform(player: player, state: .dead, cause: .poison)
                        } else {
                            activeErrorAlert = .witchPoison
                            showErrorAlert.toggle()
                        }
                        
                    } else {
                        activeErrorAlert = .noWitch
                        showErrorAlert.toggle()
                    }
                }) {
                    Text("Gifttrank")
                    Image(systemName: "minus.circle")
                }
                
                Button(action: {
                    
                    if let witch = playerStore.getPlayer(for: .witch) {
                        if witch.faiths.contains(.witchHeal) {
                            playerStore.perform(player: player, state: .alive, cause: .heal)
                        } else {
                            activeErrorAlert = .witchHeal
                            showErrorAlert.toggle()
                        }
                    } else {
                        activeErrorAlert = .noWitch
                        showErrorAlert.toggle()
                    }
                }) {
                    Text("Heiltrank")
                    Image(systemName: "plus.circle")
                }
                
                Button(action: {
                    playerStore.perform(player: player, state: .alive, cause: .revive)
                }) {
                    Text("Wiederbeleben")
                    Image(systemName: "checkmark.circle")
                }
            }
        }
        .alert(isPresented: $showErrorAlert, content: {
            if activeErrorAlert == .witchHeal {
                return Alert(title: Text("iWere"), message: Text("Du kann nicht mehr heilen!"), dismissButton: .default(Text("OK")))
            } else if activeErrorAlert == .witchPoison {
                return Alert(title: Text("iWere"), message: Text("Du kann nicht mehr vergiften!"), dismissButton: .default(Text("OK")))
            } else if activeErrorAlert == .alreadyShield {
                return Alert(title: Text("iWere"), message: Text("Du kann nicht zwei Mal hintereinander den gleichen Spieler schützen"), dismissButton: .default(Text("OK")))
            } else {
                return Alert(title: Text("iWere"), message: Text("Es ist keine Hexe im Spiel!"), dismissButton: .default(Text("OK")))
            }
        })
    }
}

struct SettingsView: View {
    
    @AppStorage("dayDuration") private var dayDuration: Int = 2
    @AppStorage("showDead") private var showDead: Bool = true
    
    @ObservedObject var playerStore: PlayerStorage
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var playerRole: RoleType = .villager
    @State private var playerName: String = ""
    
    func addPlayer() {
        playerStore.addPlayer(with: playerName, role: playerRole)
        self.presentationMode.wrappedValue.dismiss()
    }
    
    var body: some View {
        NavigationView {
            Form {
                
                Section(header: Text("Einstellungen").font(.title)) {
                    
                    Toggle(isOn: $showDead, label: {
                        Text("Tote Spieler anzeigen")
                    }).toggleStyle(SwitchToggleStyle())
                    Stepper("Länge der Tage \(dayDuration)", value: $dayDuration, in: 1...5)
                    
                }
                
                Section(header: Text("Spieler hinzufügen").font(.title)) {
                    
                    Picker(selection: $playerRole, label: Text("Rolle:")) {
                        ForEach(RoleType.allCases, id: \.self) { role in
                            Text(role.name).tag(role)
                        }
                    }
                    
                    HStack {
                        Text("Spielername:")
                        TextField("", text: $playerName)
                    }
                    
                }
                
                Button(action: addPlayer, label: {
                    Text("Spieler hinzufügen")
                })
            }
            .navigationTitle(Text("Spieler Menü"))
        }
    }
    
}

struct AddPlayerView: View {
    
    @ObservedObject var playerStore: PlayerStorage
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var playerRole: RoleType = .villager
    @State private var playerName: String = ""
    
    func addPlayer() {
        playerStore.addPlayer(with: playerName, role: playerRole)
        self.presentationMode.wrappedValue.dismiss()
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Spieler hinzufügen").font(.title)) {
                    
                    Picker(selection: $playerRole, label: Text("Rolle:")) {
                        ForEach(RoleType.allCases, id: \.self) { role in
                            Text(role.name).tag(role)
                        }
                    }
                    
                    HStack {
                        Text("Spielername:")
                        TextField("", text: $playerName)
                    }
                    
                }
                
                Button(action: addPlayer, label: {
                    Text("Spieler hinzufügen")
                })
            }
            .navigationTitle(Text("Spieler Menü"))
        }
    }
    
}

struct ContentView: View {
        
    @State private var showSettingsView = false
    
    @ObservedObject var playerStore: PlayerStorage
    
    @State private var showAlert = false
    @State private var activeAlert: ActiveAlert = .none
    
    @State private var timeRemaining: Int = 20
    @State private var timerName =  "Timer: 0"
    @State private var timer: Timer.TimerPublisher = Timer.publish(every: 1, on: .main, in: .common)
    
    func instantiateTimer() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
        return
    }
    
    func startTimer() {
        if let time = UserDefaults.standard.value(forKey: "dayDuration") as? Int {
            timeRemaining = time * 60
        } else {
            timeRemaining = 60
        }
        
        _ = timer.connect()
    }
    
    func validate() {
        switch playerStore.validate() {
        case .loved:
            activeAlert = .loved
            showAlert.toggle()
        case .major:
            activeAlert = .major
            showAlert.toggle()
        default:
            activeAlert = .none
            break
        }
    }
    
    func delete(at offset: IndexSet) {
        playerStore.players.remove(atOffsets: offset)
        playerStore.objectWillChange.send()
    }
    
    var body: some View {
        
        NavigationView {
                
            VStack {
            
                Label(timerName, systemImage: "alarm")
                    .font(.title)
                    .onTapGesture {
                        instantiateTimer()
                        startTimer()
                    }
                
                List {
                    ForEach(playerStore.players) { player in
                        PlayerRow(player: player, playerStore: playerStore)
                    }
                    .onDelete(perform: delete)
                    
                }
                .onTapGesture(perform: validate)
                .navigationTitle("iWere")
                .navigationBarItems(leading:
                                        HStack(spacing: 25) {
                                            Button(action: {
                                                validate()
                                            }, label: {
                                                Image(systemName: "play.fill")
                                            })
                                            
                                            Button(action: {
                                                print(playerStore.validate())
                                                if playerStore.validate() != .none {
                                                    activeAlert = playerStore.validate()
                                                    print(activeAlert)
                                                    showAlert.toggle()
                                                }
                                            }, label: {
                                                Image(systemName: "checkmark")
                                            })
                                            
                                        }, trailing:
                                            Button(action: {
                                                showSettingsView.toggle()
                                            }, label: {
                                                Image(systemName: "gear")
                                            })
                )
                .alert(isPresented: $showAlert) {
                    if activeAlert == .loved {
                        return Alert(title: Text("iWere"), message: Text("Wähle einen Verliebten aus!"), dismissButton: .default(Text("OK")))
                    } else if activeAlert == .timer {
                        return Alert(title: Text("iWere"), message: Text("Der Timer ist abgelaufen!"), dismissButton: .default(Text("OK")))
                    } else if activeAlert == .major {
                        return Alert(title: Text("iWere"), message: Text("Wähle einen Bürgermeister aus!"), dismissButton: .default(Text("OK")))
                    } else if activeAlert == .finished {
                        return Alert(title: Text("iWere"), message: Text("Das Spiel ist zuende!"), dismissButton: .default(Text("OK")))
                    } else {
                        return Alert(title: Text("iWere"), message: Text("Der Jäger muss jemanden erschießen!"), dismissButton: .default(Text("OK")))
                    }
                }
                .sheet(isPresented: $showSettingsView) {
                    SettingsView(playerStore: playerStore)
                }
            }
            .onReceive(timer) { time in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                    timerName = "Timer: \(timeRemaining)"
                } else if timeRemaining == 0 {
                    showAlert.toggle()
                    timer.connect().cancel()
                    activeAlert = .timer
                    
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                    
                    if let time = UserDefaults.standard.value(forKey: "dayDuration") as? Int {
                        timeRemaining = time * 60
                    } else {
                        timeRemaining = 60
                    }
                    
                    timerName = "Timer: \(timeRemaining)"
                }
            }
            .onAppear(perform: {
                if let time = UserDefaults.standard.value(forKey: "dayDuration") as? Int {
                    timerName = "Timer: \(time * 60)"
                } else {
                    timerName = "Timer: \(60)"
                }
                
            })
        }
    }
            
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView(playerStore: PlayerStorage(players: testData))
        }
    }
}

