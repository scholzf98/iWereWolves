//
//  ContentView.swift
//  IOS14Test
//
//  Created by Florian Scholz on 24.06.20.
//

import SwiftUI
import Combine

struct FaithsView: View {
    var faiths: [Faith]
    
    var body: some View {
        HStack {
            ForEach(faiths, id: \.self) { faith in
                Image(systemName: faith.imageName)
            }
        }
        
    }
    
}

struct PlayerRow: View {
    
    @State var player: Player
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
            
            if playerStore.needSetup() != .none {
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
                    playerStore.perform(player: player, state: .dead, cause: .killed)
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
                    playerStore.perform(player: player, state: .alive, cause: .revive)
                }) {
                    Text("Wiederbeleben")
                    Image(systemName: "checkmark.circle")
                }
            }
        }
    }
}

struct SettingsView: View {
    
    @AppStorage("createLogs") private var createLogs: Bool = false
    @AppStorage("dayDuration") private var dayDuration: Int = 2

    var body: some View {
        
        VStack {
            Toggle(isOn: $createLogs, label: {
                Text("Logs speichern")
            }).toggleStyle(SwitchToggleStyle())
            Stepper("Länge der Tage \(dayDuration)", value: $dayDuration, in: 1...5)
            Spacer()
            
        }.padding()
    }
    
}

struct AddPlayerView: View {
    
    @ObservedObject var playerStore: PlayerStorage
    @Environment(\.presentationMode) private var presentationMode
    
    @State var playerRole: RoleType = .villager
    @State var playerName: String = ""
    
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
        
    @State private var showSettings = false
    @State private var showAddPlayerView = false
    
    @ObservedObject var playerStore: PlayerStorage
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showAlert = false
    @State private var activeAlert: ActiveAlert = .none
    
    @State private var timeRemaining = 20
    @State private var headerName =  "Timer"
    let timer = Timer.publish(every: 1, on: .main, in: .common)
    
    func startGame() {
        switch playerStore.needSetup() {
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
    
    var body: some View {
        
        NavigationView {
                
            Form {
                
                Section(header: Text(headerName).font(.title)) {
                    Button(action: {
                        timer.connect()
                    }, label: {
                        Text("Timer starten")
                    })
                }
                
                List {
                    ForEach(playerStore.players) { player in
                        PlayerRow(player: player, playerStore: playerStore)
                    }.listStyle(GroupedListStyle())
                    
                }
                .navigationTitle("iWere")
                
                .navigationBarItems(leading:
                                        HStack {
                                            Button(action: {
                                                startGame()
                                            }, label: {
                                                Text("Starten")
                                            })
                                            
                                            Button(action: {
                                                print("hello world")
                                                
                                            }, label: {
                                                Text("test")
                                            })
                                            
                                        }, trailing:
                                            Button(action: {
                                                showSettings.toggle()
                                            }, label: {
                                                Image(systemName: "gear")
                                            })
                                            .sheet(isPresented: $showSettings) {
                                                SettingsView()
                                            })
                .alert(isPresented: $showAlert) {
                    if activeAlert == .loved {
                        return Alert(title: Text("iWere"), message: Text("Wähle einen Verliebten aus"), dismissButton: .default(Text("OK")))
                    } else if activeAlert == .timer {
                        return Alert(title: Text("iWere"), message: Text("Der Timer ist abgelaufen"), dismissButton: .default(Text("OK")))
                    } else {
                        return Alert(title: Text("iWere"), message: Text("Wähle einen Bürgermeister aus"), dismissButton: .default(Text("OK")))
                    }
                }
                .sheet(isPresented: $showAddPlayerView) {
                    AddPlayerView(playerStore: playerStore)
                }
            }
            .gesture(DragGesture(minimumDistance: 50)
                        .onEnded { _ in
                            showAddPlayerView.toggle()
                        }
                    )
            .onReceive(timer) { time in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                    headerName = "Timer: \(timeRemaining)"
                } else if timeRemaining == 0 {
                    showAlert.toggle()
                    timer.connect().cancel()
                    activeAlert = .timer
                    timeRemaining = 20
                    headerName = "Timer: \(timeRemaining)"
                }
            }
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

