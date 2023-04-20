import MultipeerConnectivity
import SwiftUI

struct MultipeerHeader: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var vm : ViewModel
    
    @Binding var isQueue: Bool
    @Binding var maxCapacity: Int
    @Binding var password: String
    @State var editDisplayName: String = ""
        
    //MARK: - Main
    var body: some View {
        HStack{
            Image(systemName: "\(vm.displayName.lowercased().first!).circle.fill")
                .font(.largeTitle)
                .padding([.leading,.top], 30)
            if(!vm.isMultipeerEditing){
                if(vm.multipeerPopUpView == 0){
                    Text(vm.displayName).padding(.top,30)
                    if(!vm.isMultipeerHosting && vm.connectedPeers.isEmpty){
                       editButton
                    }
                }
                Spacer()
                if(vm.multipeerPopUpView == 1){
                    cancelButton
                    createButton
                } else if(vm.isMultipeerHosting){
                    hostingButton
                } else if(!vm.connectedPeers.isEmpty){
                    connectedButton
                } else {
                    neutralButton
                }
            } else {
                nameEditor
            }
        }
    }
    
    //MARK: nameEditor
    var nameEditor: some View{
        HStack{
            TextField("", text: $editDisplayName)
            Button{
                vm.isMultipeerEditing.toggle()
                if(editDisplayName != vm.displayName && !editDisplayName.isEmpty){
                    vm.changeDisplayName(name: editDisplayName)
                    vm.destroyAllAnchors()
                }
            } label: {
                Image(systemName: "checkmark.circle.fill")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundColor(.rubGreen)
                    .font(.largeTitle)
            }
            Button{
                vm.isMultipeerEditing.toggle()
                editDisplayName = vm.displayName
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundColor(.red)
                    .font(.largeTitle)
            }
            Spacer()
        }
        .padding(.top, 30)
        .padding(.trailing, 50)
    }
    
    func resetCreate(){
        isQueue = false
        maxCapacity = 8
        password = ""
    }
    
    //MARK: - editButton
    var editButton: some View {
        Button{
            editDisplayName = vm.displayName
            withAnimation{
                vm.isMultipeerEditing.toggle()
            }
        } label: {
            Image(systemName: "pencil.line")
                .foregroundColor(colorScheme == .dark ? .blue: .rubBlue)
        }
        .buttonStyle(.plain)
        .padding(.top,30)
    }
    
    //MARK: - createButton
    var createButton: some View {
        Button{
            vm.createRoom(password: password, maxCapacity: maxCapacity, queue: isQueue)
            vm.multipeerPopUpView = 0
            vm.isMultipeerHosting = true
        } label: {
            Text("Create Room")
                .foregroundColor(colorScheme == .dark ? .blue: .rubBlue)
        }.padding([.trailing,.top], 30)
    }
    
    //MARK: - cancelButton
    var cancelButton: some View {
        Button{
            vm.multipeerPopUpView = 0
            resetCreate()
        } label: {
            Text("Cancel")
                .foregroundColor(.red)
        }.padding([.trailing,.top], 30)
    }
    
    //MARK: - hostingButton
    var hostingButton: some View {
        Button{
            vm.closeRoom()
            vm.isMultipeerHosting = false
            resetCreate()
            for peer in vm.multipeerQueue.keys{
                vm.declineQueueInvite(for: peer)
            }
        } label: {
            Text("Close Room")
                .foregroundColor(.red)
        }.padding([.trailing,.top], 30)
    }
    
    //MARK: - neutralButton
    var neutralButton: some View {
        Button{
            vm.multipeerPopUpView = 1
            resetCreate()
        } label: {
            Text("Create Room")
                .foregroundColor(colorScheme == .dark ? .blue: .rubBlue)
        }.padding([.trailing,.top], 30)
    }
    
    //MARK: - connectedButton
    var connectedButton: some View {
        Button{
            vm.session.disconnect()
            resetCreate()
        } label: {
            Text("Leave Room")
                .foregroundColor(.red)
        }.padding([.trailing,.top], 30)
    }
}

