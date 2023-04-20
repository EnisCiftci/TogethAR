import SwiftUI

//MARK: - ModelPickerScroll
///Shows a ScrollView of ModelPickerButtons with the ability to slide in and out of frame
struct ModelPickerScroll: View {
    @EnvironmentObject var vm : ViewModel
    
    var body: some View {
        if(vm.rightHandedBar){
            rightSide
                .opacity(vm.isModelPickerActive ? 1 : 0)
        } else {
            leftSide
                .opacity(vm.isModelPickerActive ? 1 : 0)
        }
    }
    
    var rightSide: some View {
        HStack (spacing: 0){
            ScrollView(.vertical, showsIndicators: false){
                VStack{
                    ForEach(vm.models.indices, id:\.self) { index in
                        ModelButton(model: vm.models[index])
                    }
                }.padding(.top)
                FileImporterButton()
            }
            .frame(width: 240)
            .background(.thinMaterial)
            .padding(.top)
            SideButton()
            Spacer()
            VStack{
                Spacer()
                HelperView().offset(x: vm.isModelPickerActive ? 0 : 350)
                Spacer()
            }
        }
        .ignoresSafeArea(.all)
        .offset(x: vm.isModelPickerActive ? 0 : -260)
    }
    
    var leftSide: some View {
        HStack (spacing: 0){
            VStack{
                Spacer()
                HelperView().offset(x: vm.rightHandedBar ? vm.isModelPickerActive ? 0 : 350 : vm.isModelPickerActive ? 0 : -350)
                Spacer()
            }
            Spacer()
            SideButton()
            ScrollView(.vertical, showsIndicators: false){
                VStack{
                    ForEach(vm.models.indices, id:\.self) { index in
                        ModelButton(model: vm.models[index])
                    }
                }.padding(.top)
                FileImporterButton()
            }
            .frame(width: 240)
            .background(.thinMaterial)
            .padding(.top)
            
        }
        .ignoresSafeArea(.all)
        .offset(x: vm.isModelPickerActive ? 0 : 260)
    }
}
