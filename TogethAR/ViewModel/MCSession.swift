import MultipeerConnectivity
import SwiftUI
import Foundation
import RealityKit
import ARKit

//MARK: - MCSessionDelegate
extension ViewModel: MCSessionDelegate {
    
    ///StateChanged
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        
        ///Connected State
        if state == .connected {
            sendToPeers("CONNECTED_\(displayName)".data(using: .utf8)!, reliably: true, peers: [peerID])
        }
        
        ///Not Connected State
        else if state == .notConnected {
            DispatchQueue.main.async {
                self.connectedPeers.removeValue(forKey: peerID)
            }
        }
    }
    
    ///DataReceiver
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
        ///Use collaborationData
        if let collaborationData = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARSession.CollaborationData.self, from: data) {
            arView.session.update(with: collaborationData)
            return
        }
        
        if let encodedData = String(data: data, encoding: .utf8){
            
            ///Peer asks if you have a certain custom Model
            if encodedData.starts(with: "HAVE"){
                let modelName = String(encodedData.dropFirst("HAVE_".count))
                if(!models.contains(where: {$0.modelName == modelName})){
                    let data = "NOHAVE_\(modelName)".data(using: .utf8)!
                    sendToPeers(data, reliably: true, peers: [peerID])
                }
            }
            
            ///Peer doenst have a certain custom Model and requests it
            if encodedData.starts(with: "NOHAVE"){
                let modelName = String(encodedData.dropFirst("NOHAVE_".count))
                if let model = models.first(where: {$0.modelName == modelName}){
                    let url = model.url!
                    session.sendResource(at: url, withName: modelName, toPeer: peerID)
                }
            }
            
            ///When the peer loads the custom model reload the anchor th show it
            if(encodedData.starts(with: "LOADED")){
                let loadedModel = String(encodedData.dropFirst("LOADED_".count))
                let anchors = arView.scene.anchors
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    for anchor in anchors {
                        if(anchor.name.contains(loadedModel)){
                            anchor.removeFromParent()
                            ///Structure [0]: model, [1]: location,  [2]: color,  [3]: name,
                            self.placeModel(model: self.tempData[0] as! Model, location: self.tempData[1] as! float4x4, color: self.tempData[2] as! Color, name: self.tempData[3] as! String)
                            self.tempData = []
                        }
                    }
                }
            }
            
            ///The peer you connected with shared its displayName
            if encodedData.starts(with: "CONNECTED"){
                let name = String(encodedData.dropFirst("CONNECTED_".count))
                if(!connectedPeers.keys.contains(peerID)){
                    DispatchQueue.main.async {
                        self.connectedPeers[peerID] = name
                    }
                }
            }
            
            ///Disconnect from Session
            if (encodedData == "DISCONNECT"){
                session.disconnect()
            }
        }
    }
    
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String,
                 fromPeer peerID: MCPeerID) {
        fatalError("DEBUG: This service does not send/receive streams.")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID, with progress: Progress) {
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
        ///Load the resource send and store it in documents
        let modelName = "\(resourceName).usdz"
        moveModelToDocuments(url: localURL!, model: modelName)
        let newURL = getDocumentsURL().appendingPathComponent(modelName)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let model = Model(modelName: resourceName, url: newURL, arView: self.arView)
            self.models.append(model)
            let data = "LOADED_\(resourceName)".data(using: .utf8)!
            self.sendToPeers(data, reliably: true, peers: [peerID])
        }
    }
}

//MARK: - Custom MCSession Functions
extension ViewModel {
    
    ///Send Data to All Peers
    func sendToAllPeers(_ data: Data, reliably: Bool) {
        sendToPeers(data, reliably: reliably, peers: session.connectedPeers)
    }
    
    ///Send Data to select Peers
    func sendToPeers(_ data: Data, reliably: Bool, peers: [MCPeerID]) {
        guard !peers.isEmpty else { return }
        do {
            try session.send(data, toPeers: peers, with: reliably ? .reliable : .unreliable)
        } catch {
            print("DEBUG: error sending data to peers \(peers): \(error.localizedDescription)")
        }
    }
}
