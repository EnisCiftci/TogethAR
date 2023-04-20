import MultipeerConnectivity
import Foundation
import RealityKit
import SwiftUI
import ARKit

//MARK: - ViewModel (Multipeer/ARSession/ViewModel)
///ViewModel contains the MCSession and ARSession
class ViewModel: NSObject, ObservableObject {
    
    let defaults = UserDefaults.standard
    
    ///ViewModel
    @Published var isModelPickerActive: Bool
    @Published var isMultipeerActive: Bool
    @Published var multipeerPopUpView: Int
    @Published var isMultipeerHosting: Bool
    @Published var models: [Model]
    @Published var modelSelected: Model?
    
    ///Multipeer
    static var serviceType = "ar-studiproj"
    public var myPeerID = MCPeerID(displayName: UIDevice.current.name)
    public var session: MCSession!
    public var advertiser: MCNearbyServiceAdvertiser!
    public var browser: MCNearbyServiceBrowser!
    
    ///Rooms
    @Published var availableRooms: [Room] = []
    @Published var connectedPeers: [MCPeerID: String] = [:]
    var multipeerRoomInfo: [String:String] = [:]
    typealias IvitationHandler = (Bool, MCSession?) -> Void
    @Published var multipeerQueue: [String: IvitationHandler] = [:]
    @Published var displayName: String
    @Published var isMultipeerEditing = false
    
    ///ARView
    @Published var arView: ARView!
    @Published var modelColor: Color
    var peerSessionIDs = [MCPeerID: String]()
    var anchorID: Int = 0
    var tempData: [Any]!
    
    ///Laserpointer
    @Published var isLaserActive = false
    @Published var laserValue: Double = 1
    
    ///Drawing
    @Published var isDrawActive = false
    @Published var isProjectingActive = false
    @Published var drawDirVector: SIMD3<Float>!
    @Published var drawStartPoint: simd_float4x4!
    @Published var distanceValue: Double = 0.5
    var projAnchorID: Int = 0
    var drawAnchorID: Int = 0
    
    ///DetailView
    @Published var xOffset: CGFloat = 0.0
    @Published var yOffset: CGFloat = 0.0
    @Published var isDetailActive: Bool = false
    @Published var focusEntity: Entity?
    @Published var infoArray: [String] = ["ERR", "ERR", "ERR", "ERR"]
    
    ///ToolBar
    @Published var toolbarOffset: CGSize = .zero
    @Published var rightHandedBar: Bool = true
    
    override init() {
        ///ViewModel
        isModelPickerActive = false
        isMultipeerActive = false
        isDetailActive = false
        multipeerPopUpView = 0
        isMultipeerHosting = false
        models = {
            let filemanager = FileManager.default
            var availableModels: [Model] = []
            
            ///Load Models from Main Bundle
            guard let mainPath = Bundle.main.resourcePath, let mainFiles = try? filemanager.contentsOfDirectory(atPath: mainPath)
            else {return []}
            for mainFile in mainFiles where mainFile.hasSuffix("usdz") {
                let model = Model(modelName: mainFile)
                availableModels.append(model)
            }

            ///Load Models from Documents
            let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let documentFiles = try! filemanager.contentsOfDirectory(atPath: documentPath[0].path)
            for documentFile in documentFiles where documentFile.hasSuffix("usdz") {
                let model = Model(modelName: documentFile, url: documentPath[0].appendingPathComponent(documentFile))
                availableModels.append(model)
            }
            
            return availableModels
        }()
        
        modelColor = .clear
        displayName = defaults.object(forKey: "DisplayName") as? String ?? myPeerID.displayName
        
        super.init()
        
        defaults.set(displayName, forKey: "DisplayName")
                
        ///Multipeer
        session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: ViewModel.serviceType)
        browser.startBrowsingForPeers()
        browser.delegate = self
        session.delegate = self
        
        ///ARView
        initARView()
    }
    deinit{
        advertiser.stopAdvertisingPeer()
        browser.stopBrowsingForPeers()
    }
}

//MARK: - Custom ViewModel Functions
extension ViewModel {
    
    ///Moves a given Model to the documents folder for storage
    func moveModelToDocuments(url: URL, model: String){
        let usdzFile = try? Data.init(contentsOf: url)
        let documentsURL = getDocumentsURL().appendingPathComponent(model)
        do{
            try usdzFile?.write(to: documentsURL)
        } catch {
            print("DEBUG: Error: \(error.localizedDescription)")
        }
    }
    
    ///Return the path to the documents folder
    func getDocumentsURL() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
