import SwiftUI

struct HelperView: View {
    @EnvironmentObject var vm: ViewModel
    
    var body: some View{
        VStack{
            Button{
                vm.modelColor = .clear
            } label: {
                Circle()
                    .foregroundColor(vm.modelColor)
                    .frame(width: 35)
                    .padding()
            }
            ScrollView(.vertical, showsIndicators: false){
                VStack{
                    ColorButton(bindingColor: $vm.modelColor, myColor: .blue)
                    ColorButton(bindingColor: $vm.modelColor, myColor: .green)
                    ColorButton(bindingColor: $vm.modelColor, myColor: .yellow)
                    ColorButton(bindingColor: $vm.modelColor, myColor: .red)
                    ColorButton(bindingColor: $vm.modelColor, myColor: .black)
                    CustomColorPicker(color: $vm.modelColor)
                }
                .frame(width: 40)
            }
            .frame(height: 130)
            Button{
                vm.destroyAllAnchors()
            } label: {
                Image(systemName: "trash")
                    .font(.largeTitle)
                    .foregroundColor(.red)
                    .padding()
            }.buttonStyle(.plain)
        }
        .opacity(vm.isModelPickerActive ? 1 : 0)
        .frame(width: 65, height: 300)
        .background(.thinMaterial)
        .cornerRadius(50)
        .padding()
    }
}
