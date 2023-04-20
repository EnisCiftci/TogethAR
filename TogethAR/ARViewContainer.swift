import SwiftUI
import RealityKit
import ARKit

//MARK: ARViewContainer
struct ARViewContainer: UIViewRepresentable {
    @EnvironmentObject var vm : ViewModel
    
    typealias UIViewType = ARView
    
    func makeUIView(context: Context) -> ARView {
        vm.arView.session.delegate = context.coordinator
        
        return vm.arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        
    }
    
    //MARK: - Coordinator
    class Coordinator: NSObject, ARSessionDelegate {
        var parent: ARViewContainer
        
        init(_ parent: ARViewContainer) {
            self.parent = parent
        }
        
        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            if(parent.vm.isLaserActive){
                let raycast = parent.vm.arView.raycast(from: parent.vm.arView.center, allowing: .estimatedPlane, alignment: .any)
                if let result = raycast.first{
                    var worldPosition = result.worldTransform
                    let ray = parent.vm.arView.ray(through: parent.vm.arView.center)
                    let sceneRaycast = parent.vm.arView.scene.raycast(origin: ray!.origin, direction: ray!.direction)
                    if let hitPosition = sceneRaycast.first{
                        worldPosition.columns.3 = [hitPosition.position.x, hitPosition.position.y, hitPosition.position.z, 1.0]
                    }
                    if let laser = parent.vm.arView.scene.anchors.first(where: {$0.name == "LASER_\(parent.vm.displayName)"}){
                        if let laserEntity = laser.children[0] as? ModelEntity {
                            laserEntity.move(to: worldPosition, relativeTo: nil)
                        }
                    }
                }
            }
        }
                        
        ///Anchor added to scene
        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            for anchor in anchors {
                ///Positional Anchor of another Peer
                if let participantAnchor = anchor as? ARParticipantAnchor{
                    #if !targetEnvironment(simulator)
                    let anchorEntity = AnchorEntity(anchor: participantAnchor)
                    let tabletOuter = MeshResource.generateBox(width: 0.24, height: 0.17, depth: 0.006, cornerRadius: 50)
                    let tabletInner = MeshResource.generateBox(width: 0.22, height: 0.15, depth: 0.01, cornerRadius: 50)
                    let color = participantAnchor.sessionIdentifier?.toRandomColor() ?? .white
                    let outerColor = SimpleMaterial(color: .black, isMetallic: false)
                    let innerColor  = SimpleMaterial(color: color, isMetallic: false)
                    let innerAvatar  = ModelEntity(mesh: tabletInner, materials:[innerColor])
                    let outerAvatar = ModelEntity(mesh: tabletOuter, materials: [outerColor])
                    anchorEntity.addChild(innerAvatar)
                    anchorEntity.addChild(outerAvatar)
                    parent.vm.arView.scene.addAnchor(anchorEntity)
                    #endif
                }
            }
        }
        
        ///CollaborationData was send
        func session(_ session: ARSession, didOutputCollaborationData data: ARSession.CollaborationData) {
            if(!parent.vm.session.connectedPeers.isEmpty) {
                guard let encodedData = try? NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: true)
                else { fatalError("DEBUG: Unexpectedly failed to encode collaboration data.") }
                let dataIsCritical = data.priority == .critical
                parent.vm.sendToAllPeers(encodedData, reliably: dataIsCritical)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
}
