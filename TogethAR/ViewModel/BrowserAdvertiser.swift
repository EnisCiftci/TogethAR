import MultipeerConnectivity

//MARK: - BrowserDelegate
extension ViewModel: MCNearbyServiceBrowserDelegate {
    
    ///FoundPeer
    public func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        let room = Room(peer: peerID, name: info!["name"]!, password: info!["password"]!, maxCapacity: Int(info!["maxCapacity"]!)!, queue: (info!["queue"]! == "true"))
        DispatchQueue.main.async {
            self.availableRooms.append(room)
        }
    }
    
    ///LostPeer
    public func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            self.availableRooms.removeAll(where: {
                $0.peer == peerID
            })
        }
    }
}

//MARK: - AdvertiserDelegate
extension ViewModel: MCNearbyServiceAdvertiserDelegate {
    
    ///ReceivedRequest
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID,
                    withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {

        if let nameString = String(data: context!, encoding: .utf8), nameString.hasPrefix("REQUEST") {
            let name = String(nameString.dropFirst("REQUEST_".count))
            if(multipeerRoomInfo["queue"]=="false"){
                if(session.connectedPeers.count + 1 < Int(multipeerRoomInfo["maxCapacity"]!)!){
                    invitationHandler(true, self.session)
                }
            } else {
                DispatchQueue.main.async {
                    self.multipeerQueue[name] = invitationHandler
                }
            }
        }
    }
}


//MARK: - Custom Room Functions
extension ViewModel {
    
    ///Change your display Name
    func changeDisplayName(name: String){
        displayName = name
        defaults.set(displayName, forKey: "DisplayName")
    }
    
    ///Send request to join Room
    func sendRoomRequest(peer: MCPeerID){
        browser.invitePeer(peer, to: session, withContext: "REQUEST_\(displayName)".data(using: .utf8), timeout: 10)
    }
    
    ///Create a Room
    func createRoom(password: String, maxCapacity: Int, queue: Bool){
        multipeerRoomInfo = ["name":"\(displayName)", "password":"\(password)", "maxCapacity":"\(maxCapacity)", "queue":"\(queue)"]
        advertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: multipeerRoomInfo, serviceType: ViewModel.serviceType)
        advertiser.startAdvertisingPeer()
        advertiser.delegate = self
    }
    
    ///Close the Room
    func closeRoom(){
        sendToAllPeers("DISCONNECT".data(using: .utf8)!, reliably: true)
        advertiser.stopAdvertisingPeer()
    }
    
    ///Disconnect the Peer
    func disconnectPeer(peer: MCPeerID){
        try! session.send("DISCONNECT".data(using: .utf8)!, toPeers: [peer], with: .reliable)
    }
    
    ///Accept requests in the queue
    func acceptQueueInvite(for name: String){
        multipeerQueue[name]?(true, self.session)
        multipeerQueue.removeValue(forKey: name)
    }
    
    ///Decline requests in teh queue
    func declineQueueInvite(for name: String){
        multipeerQueue[name]?(false, self.session)
        multipeerQueue.removeValue(forKey: name)
    }
}

//MARK: - Room
///Rooms contain the information a peer needs for its connection
struct Room: Hashable{
    var peer: MCPeerID
    var name: String
    var password: String
    var maxCapacity: Int
    var queue: Bool
}
