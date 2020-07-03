//
//  ContentView.swift
//  IOS14Test
//
//  Created by Florian Scholz on 24.06.20.
//

import SwiftUI
import Combine

struct FaithsView: View {
    var faith: Faith
    
    var body: some View {
        Image(systemName: faith.imageName)
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
            
            if player.faith != .none {
                FaithsView(faith: player.faith)
            }
            
            Image(systemName: player.state == .alive ? "checkmark.circle" : "multiply.circle")
            
        }.contextMenu {
            
            if playerStore.needSetup() {
                Button(action: {
                    playerStore.setLoved(player: player)
                }) {
                    Image(systemName: "heart.circle")
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
        
    @State var showSettings = false
    @State var showAddPlayerView = false
    
    @ObservedObject var playerStore: PlayerStorage
    @Environment(\.presentationMode) var presentationMode
    
    @State var showAmorAlert = false
    
    func startGame() {
        if playerStore.needSetup() {
            showAmorAlert.toggle()
        }
    }
    
    var body: some View {
        NavigationView {
            
            List {
                ForEach(playerStore.players) { player in
                    PlayerRow(player: player, playerStore: playerStore)
                }
                
            }.listStyle(InsetGroupedListStyle())
            .navigationTitle("iWere")
            
            .navigationBarItems(leading: Button(action: {
                startGame()
            }, label: {
                Text("Starten")
            })
            .sheet(isPresented: $showAddPlayerView) {
                AddPlayerView(playerStore: playerStore)
            }, trailing: Button(action: { showSettings.toggle() }, label: {
                Image(systemName: "gear")
            })
            .sheet(isPresented: $showSettings) {
                SettingsView()
            })
            .alert(isPresented: $showAmorAlert) {
                Alert(title: Text("iWere"), message: Text("Wähle einen Verliebten aus"), dismissButton: .default(Text("OK")))
            }
        }
        .gesture(DragGesture(minimumDistance: 50)
                    .onEnded { _ in
                        showAddPlayerView.toggle()
                    }
                )
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView(playerStore: PlayerStorage(players: testData))
        }
    }
}

