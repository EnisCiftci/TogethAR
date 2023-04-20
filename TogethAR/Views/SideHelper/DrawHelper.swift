import SwiftUI

struct DrawHelper: View {
    @EnvironmentObject var vm: ViewModel
    
    var body: some View {
        HStack{
            if(vm.rightHandedBar){
                Spacer()
            }
            VStack{
                Spacer()
                Text(vm.distanceValue < 1 ? "\(String(format: "%.0f", vm.distanceValue * 100)) cm" : "\(String(format: "%.2f", vm.distanceValue)) m")
                    .padding(.vertical)
                Image(systemName: "chevron.up")
                VStack{
                    Slider(value: $vm.distanceValue, in: 0.1 ... 2.05, step: 0.05)
                        .colorScheme(.dark)
                        .frame(width: 170, height: 65)
                        .rotationEffect(.degrees(-90))
                        .onChange(of: vm.distanceValue){ value in
                            if let drawAnchor = vm.arView.scene.anchors.first(where: {$0.name == "DRAW_\(vm.displayName)_\(vm.drawAnchorID - 1)"}){
                                var worldPos = vm.drawStartPoint
                                let newVector = vm.drawDirVector * Float(value)
                                worldPos!.columns.3 += [newVector.x, newVector.y, newVector.z , 1]
                                drawAnchor.move(to: worldPos!, relativeTo: nil)
                            }
                        }
                }
                .frame(height: 170)
                .padding()
                Image(systemName: "chevron.down")
                Spacer()
            }
            .frame(width: 65, height: 300)
            .background(.thinMaterial)
            .cornerRadius(50)
            .padding()
            if(!vm.rightHandedBar){
                Spacer()
            }
        }
        .offset(x: vm.rightHandedBar ? vm.isDrawActive ? vm.isModelPickerActive ? -80 : 0 : 100 : vm.isDrawActive ? vm.isModelPickerActive ? 80 : 0 : -100)
        .opacity(vm.isDrawActive ? 1 : 0)
    }
}
