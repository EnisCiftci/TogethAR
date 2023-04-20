import SwiftUI

//MARK: - RoomPreview
///Custom Overview how the Room will look
struct RoomPreview: View {
    var name: String
    var isLocked: Bool
    var maxCapacity: Int
    var isQueue: Bool
    
    var body: some View{
        HStack{
            Image(systemName: "\(name.lowercased().first!).circle.fill").font(.title)
            VStack{
                HStack {
                    Text(name)
                    Text("\(maxCapacity) max")
                        .font(.caption)
                    Spacer()
                }
                HStack {
                    Text(isLocked ? "Locked Lobby" : "Open Lobby")
                        .font(.footnote)
                    Spacer()
                }
            }
            if(isQueue){
                Image(systemName: "person.3.sequence")
            }
            Image(systemName: isLocked ? "lock" : "lock.open")
        }
    }
}
