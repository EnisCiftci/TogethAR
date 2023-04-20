import SwiftUI
import RealityKit
import ARKit

struct ModelDetailView: View {
    @EnvironmentObject var vm : ViewModel
    
    var body: some View {
        ZStack{
            if let focus = vm.focusEntity{
                if let anchor = focus.anchor{
                    if (anchor.synchronization!.isOwner){
                        ownerView
                    } else {
                        peerView
                    }
                }
            }
        }
        .offset(x: vm.xOffset, y: vm.yOffset)
        .opacity(vm.isDetailActive ? 1 : 0)
    }
    
    //MARK: - ownerView
    var ownerView: some View {
        VStack{
            VStack{
                HStack {
                    ///Structure: [0]: ANCHOR, [1]: displayName, [2]:anchorID , [3]: modelName
                    Text("Model: \(vm.infoArray[3])")
                    Spacer()
                    Button{
                        deleteModel()
                        vm.isDetailActive = false
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .offset(x: -5, y: 10)
                    }
                }
                HStack {
                    Text("ID: \(vm.infoArray[2])")
                    Spacer()
                }
            }.padding()
            HStack{
                VStack{
                    colorButton(color: .blue)
                    colorButton(color: .green)
                }.padding(5)
                VStack{
                    colorButton(color: .yellow)
                    colorButton(color: .red)
                }.padding(5)
                VStack{
                    colorButton(color: .black)
                    colorButton(color: .white)
                }.padding(5)
            }
            .padding(.bottom)
        }
        .frame(width: 200, height: 180)
        .background(.thinMaterial)
        .cornerRadius(25)
    }
    
    //MARK: - peerView
    var peerView: some View {
        VStack{
            VStack{
                Spacer()
                HStack{
                    Text("Model: \(vm.infoArray[3])")
                    Spacer()
                }
                Spacer()
                HStack{
                    Text("Owner: \(vm.infoArray[1])")
                    Spacer()
                }
                Spacer()
            }.padding()
        }
        .frame(width: 200, height: 100)
        .background(.thinMaterial)
        .cornerRadius(25)
    }
    
    //MARK: - colorButton
    func colorButton(color: Color) -> some View{
        Button{
            changeColor(color: color)
        } label: {
            Circle()
                .foregroundColor(color)
                .frame(width: 35)
                .overlay(Circle().stroke(.white .opacity(0.2), lineWidth: 3))
        }
    }
    
    //MARK: - changeColor
    func changeColor(color: Color){
        let modelEntity = vm.focusEntity?.anchor?.children[0] as! ModelEntity
        modelEntity.model?.materials = [SimpleMaterial(color: UIColor(color), isMetallic: false)]
    }
    
    //MARK: - deleteModel
    func deleteModel(){
        vm.focusEntity?.anchor?.removeFromParent()
        vm.focusEntity = nil
    }
}



