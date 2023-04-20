import SwiftUI

//MARK: - SideButton
///SideButton to close the ModelPicker ScrollView
struct SideButton: View{
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var vm : ViewModel
    var body: some View{
        Button{
            withAnimation{
                vm.isModelPickerActive = false
            }
        } label: {
            Image(systemName: vm.rightHandedBar ? "chevron.left" : "chevron.right")
                .foregroundColor(colorScheme == .dark ? .blue : .rubBlue)
                .font(.title2)
        }
        .buttonStyle(.plain)
        .frame(width: 20, height: 100)
        .background(.thinMaterial)
        .cornerRadius(25, corners: vm.rightHandedBar ? [.topRight,.bottomRight] : [.topLeft, .bottomLeft])
    }
}
