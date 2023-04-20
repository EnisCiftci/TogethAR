import SwiftUI

//MARK: DrawButton
struct DrawButton: View {
    @EnvironmentObject var vm: ViewModel
    @Environment(\.colorScheme) var colorScheme
    @State var isExtended = false
    
    var body: some View{
        HStack{
            if(!isExtended){
                if(vm.isDrawActive){
                    drawButton
                } else if (vm.isProjectingActive){
                    projectButton
                } else {
                    mainButton
                }
            } else {
                HStack{
                    if(vm.rightHandedBar){
                        eraseButton
                        projectButton
                        mainButton
                    } else {
                        mainButton
                        projectButton
                        eraseButton
                    }
                }
                .background(.thinMaterial)
                .cornerRadius(50)
                .padding(.horizontal)
            }
        }
        .padding(.bottom, 20)
        .foregroundColor(colorScheme == .dark ? .blue : .rubBlue)
        .animation(.interactiveSpring(response: 0.5, dampingFraction: 0.5, blendDuration: 0.5), value: isExtended)
        .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onEnded({ value in
                if value.translation.width < 0 {
                    if(!vm.isDrawActive && !vm.isProjectingActive){
                        withAnimation{
                            if(vm.rightHandedBar){
                                isExtended = true
                            } else {
                                isExtended = false
                            }
                        }
                    }
                }
                if value.translation.width > 0 {
                    if(!vm.isDrawActive && !vm.isProjectingActive){
                        withAnimation{
                            if(vm.rightHandedBar){
                                isExtended = false
                            } else {
                                isExtended = true
                            }
                        }
                    }
                }
            }))
    }
    
    //MARK: - mainButton
    var mainButton: some View {
        Button{
            
        } label: {
            Image(systemName:"pencil.and.outline")
                .font(.largeTitle)
                .padding(.horizontal ,20)
        }
        .simultaneousGesture(LongPressGesture().onEnded{ _ in
            isExtended.toggle()
        })
        .highPriorityGesture(TapGesture().onEnded{ _ in
            if(!vm.isDrawActive){
                withAnimation{
                    vm.startDrawing()
                }
            } else {
                withAnimation{
                    vm.endDrawing()
                }
            }
            if(vm.isLaserActive){
                withAnimation{
                    vm.endLaser()
                }
            }
            isExtended = false
        })
    }
    
    //MARK: - drawButton
    var drawButton: some View {
        Button {
            if(!vm.isDrawActive){
                withAnimation{
                    vm.startDrawing()
                }
            } else {
                withAnimation{
                    vm.endDrawing()
                }
            }
            if(vm.isLaserActive){
                withAnimation{
                    vm.endLaser()
                }
            }
            isExtended = false
        } label : {
            if(vm.isDrawActive){
                Image(systemName:"pencil.and.outline")
                    .font(.largeTitle)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(colorScheme == .dark ? .blue : .rubBlue, .red)
                    .padding(.horizontal ,20)
            } else {
                Image(systemName:"pencil.and.outline")
                    .font(.largeTitle)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(colorScheme == .dark ? .blue : .rubBlue, colorScheme == .dark ? .blue : .rubBlue)
                    .padding(.horizontal ,20)
            }
            
        }
    }
    
    //MARK: - projectButton
    var projectButton: some View {
        Button{
            if(!vm.isProjectingActive){
                vm.startProjecting()
            } else {
                vm.endProjecting()
            }
            if(vm.isLaserActive){
                withAnimation{
                    vm.endLaser()
                }
            }
            isExtended = false
        } label: {
            if(vm.isProjectingActive){
                Image(systemName:"pencil.line")
                    .font(.largeTitle)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(colorScheme == .dark ? .blue : .rubBlue, .red)
                    .padding(.horizontal, isExtended ? 0 : 20)
            } else {
                Image(systemName:"pencil.line")
                    .font(.largeTitle)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(colorScheme == .dark ? .blue : .rubBlue, colorScheme == .dark ? .blue : .rubBlue)
            }
        }
    }
    
    var eraseButton: some View {
        Button{
            withAnimation{
                vm.deleteAllDrawings()
                vm.isDrawActive = false
                vm.isProjectingActive = false
            }
        } label: {
            Image(systemName: "xmark")
                .font(.largeTitle)
                .padding(.horizontal ,20)
                .padding(.vertical, 10)
                .foregroundColor(.red)
        }
    }
}
