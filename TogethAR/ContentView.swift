import SwiftUI
import RealityKit

struct ContentView : View {
    @StateObject var vm = ViewModel()
    
    var body: some View {
        ZStack {
            ARViewContainer()
                .edgesIgnoringSafeArea(.all)
                .gesture(vm.isDrawActive ? DragGesture().onChanged({ value in vm.drawCircle(location: value.location)}) : nil)
                .gesture(vm.isProjectingActive ? DragGesture().onChanged({ value in vm.drawProjection(location: value.location)}) : nil)
            FloatingToolBar()
            ModelDetailView()
            LaserHelper()
            DrawHelper()
            ModelPickerScroll()
            MultipeerSession()
        }
        .environmentObject(vm)
        .gesture(DragGesture(coordinateSpace: .local)
            .onEnded({ value in
                if value.translation.width > 75 {
                    withAnimation{
                        if(vm.rightHandedBar){
                            vm.isModelPickerActive = true
                        } else {
                            vm.isModelPickerActive = false
                        }
                    }
                }
                if value.translation.width < -75 {
                    withAnimation{
                        if(vm.rightHandedBar){
                            vm.isModelPickerActive = false
                        } else {
                            vm.isModelPickerActive = true
                        }
                    }
                }
            }))
    }
}

