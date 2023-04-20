import SwiftUI
import RealityKit

struct MultipeerSession: View {
    @EnvironmentObject var vm : ViewModel
    
    @State var isQueue = false
    @State var maxCapacity = 8
    @State var password = ""
    
    var body: some View {
        VStack{
            MultipeerHeader(isQueue: $isQueue, maxCapacity: $maxCapacity, password: $password)
            MultipeerMain(isQueue: $isQueue, maxCapacity: $maxCapacity, password: $password)
            MultipeerFooter()
        }
        .background(.thinMaterial)
        .cornerRadius(25)
        .frame(width: 540, height: 400)
        .offset(y: vm.isMultipeerActive ? 0 : UIScreen.main.bounds.height/2 + 200 )
        .simultaneousGesture(DragGesture(minimumDistance: 180, coordinateSpace: .local)
            .onEnded({ value in
                if value.translation.height > 200 {
                    withAnimation{
                        vm.isMultipeerActive = false
                    }
                }
            }))
    }
}

