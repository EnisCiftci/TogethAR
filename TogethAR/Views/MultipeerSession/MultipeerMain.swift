import SwiftUI

struct MultipeerMain: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var vm: ViewModel
    
    @Binding var isQueue: Bool
    @Binding var maxCapacity: Int
    @Binding var password: String
    
    //MARK: - Main
    var body: some View {
        if(vm.multipeerPopUpView == 0){
            mainView
        } else {
            createView
        }
    }
    
    //MARK: - createView
    var createView: some View{
        List{
            Section(header: Text("Room Overview")){
                RoomPreview(name: vm.displayName, isLocked: !password.isEmpty, maxCapacity: maxCapacity, isQueue: isQueue)
            }
            Section(header: Text("Settings")){
                TextField("Enter Password", text: $password)
                Toggle("Queueing", isOn: $isQueue)
                HStack{
                    Text("Max People")
                    Spacer()
                    Picker("", selection: $maxCapacity) {
                        ForEach(2...8, id: \.self){
                            Text("\($0)")
                        }
                    }
                }
            }
        }
        .scrollDisabled(true)
        .scrollContentBackground(.hidden)
        .scrollIndicators(.hidden)
        .padding(.bottom,20)
    }
    
    //MARK: - mainView
    var mainView: some View{
        Section(header: Text(vm.isMultipeerHosting ? "Joined Peers" : vm.connectedPeers.isEmpty ? "Available Rooms" : "Connected Peers").padding(.top)){
            if(vm.connectedPeers.isEmpty && !vm.isMultipeerHosting){
                availableList
            } else {
                connectedList
            }
        }
        .scrollContentBackground(.hidden)
        .scrollIndicators(.hidden)
    }
    
    //MARK: - connectedList
    var connectedList: some View{
        List{
            ForEach(Array(vm.connectedPeers.keys), id: \.self){peer in
                PeerButton(name: vm.connectedPeers[peer]! ,peerID: peer)
            }
        }
        .padding(.bottom)
        .opacity(vm.connectedPeers.isEmpty ? 0 : 1)
    }
    
    //MARK: - availableList
    var availableList: some View{
        List{
            ForEach(vm.availableRooms, id:\.self){ room in
                RoomButton(room: room)
                    .foregroundColor(colorScheme == .dark ? .blue : .rubBlue)
                    .disabled(vm.isMultipeerEditing)
            }
        }
        .padding(.bottom)
        .opacity(vm.availableRooms.isEmpty ? 0 : 1)
    }
}
