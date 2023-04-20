import SwiftUI
import MultipeerConnectivity

//MARK: - PeerButton
///Overview of the connected/joined Peers
struct PeerButton: View {
    @EnvironmentObject var vm : ViewModel
    var name: String
    var peerID: MCPeerID
    
    var body: some View{
        if(vm.isMultipeerHosting){
            HStack{
                Image(systemName: "\(name.lowercased().first!).circle.fill")
                    .font(.largeTitle)
                Text(name)
                Spacer()
            }.swipeActions(allowsFullSwipe: false){
                Button(role: .destructive){
                    vm.disconnectPeer(peer: peerID)
                } label: {
                    Label("Remove", systemImage: "person.fill.badge.minus")
                }
            }
        } else {
            HStack{
                Image(systemName: "\(name.lowercased().first!).circle.fill")
                    .font(.largeTitle)
                Text(name)
                Spacer()
            }
        }
    }
}
