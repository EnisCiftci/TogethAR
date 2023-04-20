import QuickLookThumbnailing
import SwiftUI

//MARK: - ThumbnailImage
///Struct to automaticaly generate thumbnails for usdz files
struct ThumbnailImage: View{
    let url: URL
    
    @State private var thumbnail: CGImage? = nil
    
    var body: some View{
        if thumbnail != nil {
            Image(self.thumbnail!, scale: (UIScreen.main.scale), label: Text("Preview"))
                .frame(width: 180, height: 180)
                .cornerRadius(25)
        } else {
            Image(systemName: "photo")
                .onAppear(perform: generateThumbnail)
        }
    }
    
    func generateThumbnail(){
        let size: CGSize = CGSize(width: 180, height: 180)
        let request = QLThumbnailGenerator.Request(fileAt: url, size: size, scale: (UIScreen.main.scale), representationTypes: .all)
        let generator = QLThumbnailGenerator.shared
        
        generator.generateRepresentations(for: request){ (thumbnail, type, error) in
            DispatchQueue.main.async {
                if thumbnail == nil || error != nil{
                    print("DEBUG: Thumbnail failed")
                } else {
                    DispatchQueue.main.async {
                        self.thumbnail = thumbnail!.cgImage
                    }
                }
            }
        }
    }
}
