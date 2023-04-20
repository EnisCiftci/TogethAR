import SwiftUI
import AVFoundation

struct FloatingToolBar: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var vm: ViewModel
    @State var isExpand = false
    @State var isFlashlight = false
    
    //MARK: - Main
    var body: some View {
        HStack {
            if(vm.rightHandedBar){
                Spacer()
            }
            VStack {
                Spacer()
                HStack {
                    if(!isExpand){
                        openButton
                    } else {
                        if(vm.rightHandedBar){
                            rightSide
                        } else {
                            leftSide
                        }
                    }
                }
                .background(.thinMaterial)
                .cornerRadius(50)
                .foregroundColor(colorScheme == .dark ? .blue : .rubBlue)
                .animation(.interactiveSpring(response: 0.5, dampingFraction: 0.5, blendDuration: 0.5), value: isExpand)
                .padding()
            }
            if(!vm.rightHandedBar){
                Spacer()
            }
        }
        .offset(vm.toolbarOffset)
        .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onEnded({ value in
                if value.translation.width < 0 {
                    if(vm.rightHandedBar){
                        isExpand = true
                    } else  {
                        isExpand = false
                    }
                }
                if value.translation.width > 0 {
                    if(vm.rightHandedBar){
                        isExpand = false
                    } else  {
                        isExpand = true
                    }
                }
            }))
    }
    
    //MARK: - leftSide
    var leftSide: some View {
        VStack{
            DragCapsule()
            HStack{
                multipeerButton
                modelButton
                flashlightButton
                laserButton
                DrawButton()
                closeButton
            }
        }
    }
    
    //MARK: - rightSide
    var rightSide: some View {
        VStack{
            DragCapsule()
            HStack{
                closeButton
                DrawButton()
                laserButton
                flashlightButton
                modelButton
                multipeerButton
            }
        }
    }
    
    //MARK: - laserButton
    var laserButton: some View{
        Button{
            if(!vm.isLaserActive){
                withAnimation{
                    vm.startLaser()
                }
            } else {
                withAnimation{
                    vm.endLaser()
                }
            }
            if(vm.isDrawActive){
                withAnimation{
                    vm.endDrawing()
                }
            }
            if(vm.isProjectingActive){
                withAnimation{
                    vm.endProjecting()
                }
            }
        } label: {
            if(!vm.isLaserActive){
                Image("laserpointer.off")
                    .imageScale(.large)
                    .font(Font.system(size: 60))
            } else {
                Image("laserpointer.on")
                    .imageScale(.large)
                    .font(Font.system(size: 43))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(colorScheme == .dark ? .blue : .rubBlue, .red)
            }
        }
        .padding(vm.rightHandedBar ? .trailing : .leading)
        .padding(.bottom, 20)
    }
    
    //MARK: - openButton
    var openButton: some View{
        Button{
            isExpand = true
        } label: {
            Image(systemName: vm.rightHandedBar ? "chevron.backward" : "chevron.forward")
                .font(.largeTitle)
                .padding(20)
        }
    }
    
    //MARK: - closeButton
    var closeButton: some View{
        Button{
            isExpand = false
        } label: {
            Image(systemName: vm.rightHandedBar ? "chevron.forward" : "chevron.backward")
                .font(.largeTitle)
                .padding([.bottom, vm.rightHandedBar ? .leading : .trailing], 20)
        }
    }
    
    //MARK: - flashlightButton
    var flashlightButton: some View {
        Button{
            isFlashlight.toggle()
            toggleTorch(on: isFlashlight)
        } label: {
            Image(systemName: isFlashlight ? "flashlight.on.fill" : "flashlight.off.fill")
                .font(.largeTitle)
                .padding(.bottom, 20)
                .padding(vm.rightHandedBar ? .trailing : .leading)
        }
    }
    
    //MARK: - modelButton
    var modelButton: some View {
        Button{
            withAnimation{
                vm.isModelPickerActive.toggle()
            }
        } label: {
            Image(systemName: "arkit")
                .font(.largeTitle)
        }
        .padding(.bottom, 20)
        .padding(.leading, vm.rightHandedBar ? 0 : 20)
    }
    
    //MARK: - multipeerButton
    var multipeerButton: some View {
        Button{
            withAnimation{
                vm.isMultipeerActive.toggle()
            }
        } label: {
            Image(systemName: "person.2.wave.2.fill")
                .font(.largeTitle)
                .padding([.bottom, vm.rightHandedBar ? .trailing : .leading], 20)
        }
    }
    
    //MARK: - toggleTorch
    func toggleTorch(on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        if device.hasTorch {
            do {
                try device.lockForConfiguration()

                if on == true {
                    device.torchMode = .on
                } else {
                    device.torchMode = .off
                }

                device.unlockForConfiguration()
            } catch {
                print("DEBUG: Torch could not be used")
            }
        } else {
            print("DEBUG: Torch is not available")
        }
    }
}
