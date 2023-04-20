import SwiftUI

struct MultipeerFooter: View {
    @EnvironmentObject var vm : ViewModel
    
    var body: some View {
        if(!vm.multipeerQueue.isEmpty){
            Section(header: Text("Pending Peers")){
                ForEach(Array(vm.multipeerQueue.keys), id: \.hash) { name in
                    List{
                        HStack{
                            Image(systemName: "\(name.lowercased().first!).circle.fill")
                                .font(.largeTitle)
                            Text(name)
                            Spacer()
                            Button{
                                vm.acceptQueueInvite(for: name)
                            } label: {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.largeTitle)
                            }.buttonStyle(BorderlessButtonStyle())
                            Button{
                                vm.declineQueueInvite(for: name)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.largeTitle)
                            }.buttonStyle(BorderlessButtonStyle())
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .scrollIndicators(.hidden)
        }
    }
}
