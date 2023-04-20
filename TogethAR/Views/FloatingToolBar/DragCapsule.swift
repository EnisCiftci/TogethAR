import SwiftUI

struct DragCapsule: View {
    
    @EnvironmentObject var vm: ViewModel
    
    var body: some View {
        Capsule()
            .frame(width: 40, height: 8)
            .foregroundColor(.gray)
            .padding(.top, 10)
            .padding(.bottom, 0)
            .gesture(DragGesture().onChanged{ value in
                withAnimation(.spring()){
                    vm.toolbarOffset = value.translation
                }
            }.onEnded{ value in
                withAnimation(.spring()){
                    if (value.translation.width < -UIScreen.main.bounds.width/2 + 600) {
                        vm.rightHandedBar = false
                    }
                    if (value.translation.width > UIScreen.main.bounds.width/2 - 600){
                        vm.rightHandedBar = true
                    }
                    vm.toolbarOffset = .zero
                }
            })
    }
}

