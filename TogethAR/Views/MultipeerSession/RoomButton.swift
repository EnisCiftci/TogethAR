import SwiftUI

//MARK: - RoomButton
///Custom Button with Room Info
struct RoomButton: View {
    @EnvironmentObject var vm: ViewModel
    @State var isExpanded = false
    @State var isFalse = false
    @State var enterPassword = ""
    var room : Room
    
    var body: some View{
        Button{
            if(!room.password.isEmpty){
                withAnimation{
                    isExpanded.toggle()
                }
            } else {
                vm.sendRoomRequest(peer: room.peer)
            }
        } label: {
            buttonLabel
        }
        if(isExpanded){
            passwordSection
        }
    }
    
    //MARK: - passwordSection
    var passwordSection: some View{
        HStack{
            if(isFalse){
                Image(systemName: "xmark.octagon").foregroundColor(.red)
            }
            TextField("Password", text: $enterPassword)
                .onSubmit {
                    checkPassword()
                }
            Button{
                checkPassword()
            } label: {
                Image(systemName: "arrow.right.circle")
            }
            
        }
    }
    
    //MARK: - buttonLabel
    var buttonLabel: some View{
        HStack{
            Image(systemName: "\(room.name.lowercased().first!).circle.fill").font(.title)
            VStack{
                HStack {
                    Text(room.name)
                    Text("\(room.maxCapacity) max")
                        .font(.caption)
                    Spacer()
                }
                HStack {
                    Text(!room.password.isEmpty ? "Locked Lobby" : "Open Lobby")
                        .font(.footnote)
                    Spacer()
                }
            }
            if(room.queue){
                Image(systemName: "person.3.sequence")
            }
            Image(systemName: !room.password.isEmpty ? "lock" : "lock.open")
        }
    }
    
    func checkPassword(){
        if(!enterPassword.isEmpty){
            if(enterPassword == room.password){
                vm.sendRoomRequest(peer: room.peer)
            } else {
                enterPassword = ""
                isFalse = true
            }
        }
    }
}
