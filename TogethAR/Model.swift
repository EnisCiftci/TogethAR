import Combine
import RealityKit
import SwiftUI

//MARK: - Model
///Model is a custom struct that contains a preloaded ModelEntity, modelName, optional url for importet assets and a color
class Model {
    var modelName: String
    var modelEntity: ModelEntity?
    var url: URL?
    var arView : ARView?
    
    private var cancellable: AnyCancellable? = nil
    
    init(modelName: String, url: URL? = nil, arView: ARView? = nil) {
        self.url = url
        self.arView = arView
        self.modelName = modelName.replacingOccurrences(of: ".usdz", with: "")
        //TODO: Redo with Document folder
        if(url != nil){
            ///Custom Models with their URLS
            self.cancellable = ModelEntity.loadModelAsync(contentsOf: url!)
                .sink(receiveCompletion: { loadCompletion in
                }, receiveValue: { modelEntity in
                    self.modelEntity = modelEntity
                    if(arView != nil){
                        self.putModelOnAnchors()
                    }
                })
        } else {
            ///Defaults in Bundle.Main
            self.cancellable = ModelEntity.loadModelAsync(named: modelName)
                .sink(receiveCompletion: { loadCompletion in
                }, receiveValue: { modelEntity in
                    self.modelEntity = modelEntity
                })
            
        }
    }
    
    func putModelOnAnchors(){
        let anchors = arView!.scene.anchors
        for anchor in anchors{
            if(anchor.name.contains(modelName)){
                print("DEBUG: AnchorName: \(anchor.name)")
                let tempEntity = modelEntity!.clone(recursive: true)
                tempEntity.synchronization = nil
                print("DEBUG: Got Model Loading it")
                anchor.children[0] = tempEntity
            }
        }
    }
}
