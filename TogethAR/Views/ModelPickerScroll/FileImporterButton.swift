import SwiftUI

//MARK: - FileImporterButton
///Little Button at the end of the ScrollView to import new usdz files
struct FileImporterButton: View{
    @EnvironmentObject var vm : ViewModel
    @State var isFileImporter = false
    
    var body: some View{
        Button{
            isFileImporter.toggle()
        } label: {
            Image(systemName: "plus")
                .font(.largeTitle)
                .frame(width: 75, height: 75)
                .background(.white)
                .cornerRadius(25)
        }
        .padding(.bottom)
        .fileImporter(isPresented: $isFileImporter, allowedContentTypes: [.usdz]) {  result in
            switch result {
            case .success(let url):
                _ = url.startAccessingSecurityScopedResource()
                let foundModel: String = url.lastPathComponent
                let model = Model(modelName: foundModel, url: url)
                vm.models.append(model)
                vm.moveModelToDocuments(url: url, model: foundModel)
            case.failure(let error):
                print("DEBUG: Error with fileImporter: \(error)")
            }
        }
    }
}
