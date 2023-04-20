import MultipeerConnectivity
import SwiftUI
import ARKit
import RealityKit

//MARK: - ARSession Handlers / ARView init
extension ViewModel{
    
    ///ARView initialiser
    func initARView(){
        arView = ARView(frame: .zero)
        
        #if !targetEnvironment(simulator)
        arView.automaticallyConfigureSession = false
        #endif
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        config.environmentTexturing = .automatic
        config.isCollaborationEnabled = true
        
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
        }
        
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth){
            config.frameSemantics.insert(.personSegmentationWithDepth)
        }
        
        arView.session.run(config)
        
        arView.scene.synchronizationService = try? MultipeerConnectivityService(session: session)
        
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingOverlay.session = arView.session
        coachingOverlay.goal = .horizontalPlane
        arView.addSubview(coachingOverlay)
        arView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:))))
        arView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleLongTap(recognizer:))))
    }
    
    ///Handles taps on ARView
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        if(modelSelected != nil){
            let tapLocation = recognizer.location(in: arView)
            let results = arView.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .horizontal)
            if let firstResult = results.first {
                ///Structure: [0]: ANCHOR, [1]: displayName, [2]:anchorID , [3]: modelName
                let name = "ANCHOR_\(displayName)_\(anchorID)_\(modelSelected!.modelName)"
                anchorID += 1
                placeModel(model: modelSelected!, location: firstResult.worldTransform, color: modelColor, name: name)
                modelSelected = nil
            }
        }else {
            if(isDetailActive){
                withAnimation{
                    isDetailActive = false
                }
            }
        }
    }
    
    ///Handles long taps/haptic taps on ARView
    @objc func handleLongTap(recognizer: UILongPressGestureRecognizer){
        if(modelSelected == nil){
            let tapLocation = recognizer.location(in: arView)
            if let entity = arView.entity(at: tapLocation) {
                focusEntity = entity
                infoArray = (entity.anchor?.name.description.components(separatedBy: "_"))!
                xOffset = tapLocation.x - UIScreen.main.bounds.width/2 + 100
                if((xOffset + 100 ) > UIScreen.main.bounds.width/2){
                    xOffset -= 200
                }
                yOffset = tapLocation.y - UIScreen.main.bounds.height/2 + 90
                if((yOffset + 90 ) > UIScreen.main.bounds.height/2){
                    yOffset -= 180
                }
                withAnimation{
                    isDetailActive = true
                }
            }
        }
    }
}

//MARK: - Custom ARSession Functions
extension ViewModel {
    
    
    //MARK: Laser
    ///Create a LaserPointer
    func startLaser(){
        let results = arView.raycast(from: arView.center, allowing: .estimatedPlane, alignment: .horizontal)
        if let firstResult = results.first {
            ///Structure: [0]:displayName, [1]:Laser
            let name = "LASER_\(displayName)"
            let color = arView.session.identifier.toRandomColor()
            let laserEntity = ModelEntity(mesh:MeshResource.generateSphere(radius: 0.01), materials:[SimpleMaterial(color: color, isMetallic: false)])
            laserValue = 1
            let anchorEntity = AnchorEntity(world: firstResult.worldTransform)
            anchorEntity.addChild(laserEntity)
            anchorEntity.name = name
            arView.scene.addAnchor(anchorEntity)
        }
        
        isLaserActive = true
    }
    
    ///End your LaserPointers miserable Life
    func endLaser(){
        isLaserActive = false
        let laserEntity = arView.scene.anchors.first(where: {
            $0.name == "LASER_\(displayName)"
        })
        laserEntity?.removeFromParent()
    }
    
    //MARK: Drawing
    func startDrawing(){
        if let oldDrawing = arView.scene.anchors.first(where: {$0.name == "DRAW_\(displayName)_\(drawAnchorID - 1)"}){
            oldDrawing.removeFromParent()
        }
        
        let raycast = arView.raycast(from: arView.center, allowing: .estimatedPlane, alignment: .any)
        if let result = raycast.first{
            
            let canvasAnchor = AnchorEntity()
            canvasAnchor.name = "DRAW_\(displayName)_\(drawAnchorID)"
            
            let cameraTranslation = arView.cameraTransform.translation
            let endPointTranslation = result.worldTransform.columns.3
            
            let startPointVector: SIMD3<Float> = [cameraTranslation.x, cameraTranslation.y, cameraTranslation.z]
            let endPointVector: SIMD3<Float> = [endPointTranslation.x, endPointTranslation.y, endPointTranslation.z]
            let dirVector: SIMD3<Float> = endPointVector - startPointVector
            
            let lengthDirVector = (pow(dirVector.x, 2) + pow(dirVector.y, 2) + pow(dirVector.z, 2)).squareRoot()

            let normalizeFactor = 1/lengthDirVector
            let normalizedDirVector: SIMD3<Float> = normalizeFactor * dirVector
            drawDirVector = normalizedDirVector
            let endVector = normalizedDirVector * 0.5
            distanceValue = 0.5
            var placeWorldPoint = arView.cameraTransform.matrix
            drawStartPoint = arView.cameraTransform.matrix
            placeWorldPoint.columns.3 += [endVector.x, endVector.y, endVector.z, 0]
            
            let canvas = ModelEntity(mesh: MeshResource.generateBox(width: 10, height: 10, depth: 0.005), materials: [SimpleMaterial(color: .clear, isMetallic: false)])
            canvas.name = "CANVAS_\(displayName)_\(drawAnchorID)"
            canvas.synchronization = nil
            canvas.generateCollisionShapes(recursive: true)
            
            canvasAnchor.move(to: placeWorldPoint , relativeTo: nil)
            canvasAnchor.addChild(canvas)
            arView.scene.addAnchor(canvasAnchor)
            
            drawAnchorID += 1
            isDrawActive = true
        }
    }
    
    func drawCircle(location: CGPoint){
        let hitTest = arView.hitTest(location)
        let color = arView.session.identifier.toRandomColor()
        if (hitTest.first?.entity.name == "CANVAS_\(displayName)_\(drawAnchorID - 1)"){
            let raycast = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .any)
            if let result = raycast.first{
                var worldPosition = result.worldTransform
                let ray = arView.ray(through: location)
                let sceneRaycast = arView.scene.raycast(origin: ray!.origin, direction: ray!.direction)
                if let hitPosition = sceneRaycast.first{
                    worldPosition.columns.3 = [hitPosition.position.x, hitPosition.position.y, hitPosition.position.z, 1.0]
                }
                if let drawAnchor = arView.scene.anchors.first(where: {$0.name == "DRAW_\(displayName)_\(drawAnchorID - 1)"}){
                    let dot = ModelEntity(mesh:MeshResource.generateSphere(radius: 0.005), materials:[SimpleMaterial(color: color, isMetallic: false)])
                    dot.name = "DRAWDOT_\(displayName)"
                    drawAnchor.addChild(dot)
                    dot.move(to: worldPosition, relativeTo: nil)
                }
            }
        }
    }
    
    func endDrawing(){
        isDrawActive = false
        
        if let canvasAnchor = arView.scene.anchors.first(where: {$0.name == "DRAW_\(displayName)_\(drawAnchorID - 1)"}){
            canvasAnchor.removeChild(canvasAnchor.children.first(where: {$0.name == "CANVAS_\(displayName)_\(drawAnchorID - 1)"})!)
        }
    }
    
    //MARK: Projecting
    func startProjecting(){
        if let oldProj = arView.scene.anchors.first(where: {$0.name == "PROJ_\(displayName)_\(projAnchorID - 1)"}){
            oldProj.removeFromParent()
        }
        let results = arView.raycast(from: arView.center, allowing: .estimatedPlane, alignment: .horizontal)
        if let firstResult = results.first {
            let projAnchor = AnchorEntity(world: firstResult.worldTransform)
            projAnchor.name = "PROJ_\(displayName)_\(projAnchorID)"
            arView.scene.addAnchor(projAnchor)
            
            projAnchorID += 1
            isProjectingActive = true
        }
    }
    
    func drawProjection(location: CGPoint){
        let raycast = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .any)
        let color = arView.session.identifier.toRandomColor()
        if let result = raycast.first{
            var worldPosition = result.worldTransform
            let ray = arView.ray(through: location)
            let sceneRaycast = arView.scene.raycast(origin: ray!.origin, direction: ray!.direction)
            if let hitPosition = sceneRaycast.first{
                worldPosition.columns.3 = [hitPosition.position.x, hitPosition.position.y, hitPosition.position.z, 1.0]
            }
            if let projAnchor = arView.scene.anchors.first(where: {$0.name == "PROJ_\(displayName)_\(projAnchorID - 1)"}){
                let proj = ModelEntity(mesh:MeshResource.generateSphere(radius: 0.01), materials:[SimpleMaterial(color: color, isMetallic: false)])
                projAnchor.addChild(proj)
                proj.move(to:worldPosition, relativeTo: nil)
            }
        }
    }
    
    func endProjecting(){
        isProjectingActive = false
    }
    
    func deleteAllDrawings(){
        if let oldProj = arView.scene.anchors.first(where: {$0.name == "PROJ_\(displayName)_\(projAnchorID - 1)"}){
            oldProj.removeFromParent()
        }
        
        if let oldDrawing = arView.scene.anchors.first(where: {$0.name == "DRAW_\(displayName)_\(drawAnchorID - 1)"}){
            oldDrawing.removeFromParent()
        }
    }
    
    //MARK: - Place/Delete Anchors
    ///Invoke immediate destruction for all Anchors (No Escape for mere Mortals)
    func destroyAllAnchors(){
        let allAnchors = arView.scene.anchors
        for anchor in allAnchors {
            if(anchor.name.contains(displayName) && anchor.name.hasPrefix("ANCHOR")){
                anchor.removeFromParent()
            }
        }
    }
    
    ///Place the selected Model into the ARView
    func placeModel(model: Model, location: float4x4, color: Color, name: String){
        if (model.url != nil){
            let data = "HAVE_\(model.modelName)".data(using: .utf8)!
            sendToAllPeers(data, reliably: true)
        }
        
        #if !targetEnvironment(simulator)
        let tempEntity = model.modelEntity!.clone(recursive: true)
        if(color != .clear){
            tempEntity.model?.materials = [SimpleMaterial(color: UIColor(color), isMetallic: false)]
        }
        tempEntity.generateCollisionShapes(recursive: true)
        arView.installGestures([.all], for: tempEntity)
        let anchorEntity = AnchorEntity(world: location)
        anchorEntity.addChild(tempEntity)
        anchorEntity.name = name
        arView.scene.addAnchor(anchorEntity)
        #endif
        
        if (model.url != nil){
            ///Structure [0]: model, [1]: location,  [2]: color,  [3]: name,
            tempData = [model, location, color, name]
        }
    }
}
