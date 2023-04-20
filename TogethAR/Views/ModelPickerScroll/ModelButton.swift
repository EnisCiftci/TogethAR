import SwiftUI

//MARK: - ModelButton
///Button used in the ModelPicker ScrollView,
struct ModelButton: View{
    @EnvironmentObject var vm: ViewModel
    @State var isExpanded = false
    var model: Model
    
    var body: some View{
        if(model.url == nil){
            defaultModel
        } else {
            ZStack{
                customModel
                if(isExpanded){
                    deleteButton
                }
            }
        }
    }
    
    var defaultModel: some View {
        Button{
            if(vm.modelSelected?.modelName == model.modelName){
                vm.modelSelected = nil
            } else {
                vm.modelSelected = model
            }
        } label: {
            buttonLabel
        }
        .padding(.vertical)
    }
    
    var customModel: some View {
        Button{
        } label: {
            buttonLabel
        }
        .simultaneousGesture(LongPressGesture().onEnded{ _ in
            isExpanded.toggle()
            let impactMed = UIImpactFeedbackGenerator(style: .medium)
            impactMed.impactOccurred()
        })
        .highPriorityGesture(TapGesture().onEnded{ _ in
            if(vm.modelSelected?.modelName == model.modelName){
                vm.modelSelected = nil
            } else {
                vm.modelSelected = model
            }
        })
        .padding(.vertical)
    }
    
    var deleteButton: some View {
        VStack{
            HStack{
                Button{
                    do{
                        try FileManager.default.removeItem(atPath: vm.getDocumentsURL().appendingPathComponent("\(model.modelName).usdz").path)
                        vm.models.removeAll(where: {$0.modelName == model.modelName})
                    } catch {
                        print("DEBUG: Error deleting \(model.modelName).usdz")
                    }
                } label: {
                    Image(systemName: "trash.fill")
                        .foregroundColor(.red)
                        .font(.title)
                }.padding(8)
                Spacer()
            }
            Spacer()
        }.frame(width: 190, height: 190)
        
    }
    
    //MARK: - buttonLabel
    var buttonLabel: some View{
        ZStack{
            RoundedRectangle(cornerRadius: 25)
                .foregroundColor(.white)
                .frame(width: 190, height: 190)
            ThumbnailImage(url: model.url ?? Bundle.main.url(forResource: model.modelName, withExtension: "usdz")!)
                .overlay(vm.modelSelected?.modelName == model.modelName ?
                         RoundedRectangle(cornerRadius: 25).stroke(Color.rubGreen, lineWidth: 4) : nil)
        }
    }
}


   
