import SwiftUI
import RealityKit

struct LaserHelper: View {
    
    @EnvironmentObject var vm: ViewModel
    
    var body: some View{
        HStack{
            if(vm.rightHandedBar){
                Spacer()
            }
            VStack{
                Spacer()
                Image(systemName: "plus")
                VStack{
                    Slider(value: $vm.laserValue, in: 0.5 ... 5, step: 0.1)
                        .colorScheme(.dark)
                        .frame(width: 190, height: 65)
                        .rotationEffect(.degrees(-90))
                        .onChange(of: vm.laserValue){ value in
                            ///Workaround cuz scale didnt work
                            if let laserAnchor = vm.arView.scene.anchors.first(where: {$0.name == "LASER_\(vm.displayName)"}){
                                let scaler:Float = Float(value)/100
                                let color = vm.arView.session.identifier.toRandomColor()
                                laserAnchor.removeChild(laserAnchor.children[0])
                                let newModel = ModelEntity(mesh:MeshResource.generateSphere(radius: scaler), materials:[SimpleMaterial(color: color, isMetallic: false)])
                                laserAnchor.addChild(newModel)
                            }
                        }
                }
                .frame(height: 190)
                .padding()
                Image(systemName: "minus")
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
        .offset(x: vm.rightHandedBar ? vm.isLaserActive ? vm.isModelPickerActive ? -80 : 0 : 100 : vm.isLaserActive ? vm.isModelPickerActive ? 80 : 0 : -100)
        .opacity(vm.isLaserActive ? 1 : 0)
    }
}
