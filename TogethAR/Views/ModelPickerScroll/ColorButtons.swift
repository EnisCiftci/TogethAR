import SwiftUI

//MARK: - ColorButton
///Round Buttons with a primary Color
struct ColorButton: View{
    @Binding var bindingColor: Color
    var myColor: Color
    
    var body: some View{
        Button{
            bindingColor = myColor
        } label: {
            Circle()
                .foregroundColor(myColor)
                .frame(width: 35)
        }
    }
}

//MARK: - CustomColorPicker
///ColorPicker with a custom RGB-Wheel Design
struct CustomColorPicker: View{
    @Binding var color: Color
    
    var body: some View{
        Circle()
            .strokeBorder(
                AngularGradient(gradient: Gradient(colors: [.red, .yellow, .green, .blue, .purple, .red]), center: .center, startAngle: .zero, endAngle: .degrees(360)),
                lineWidth: 35
            )
            .frame(width: 35, height: 35)
            .overlay(ColorPicker("", selection: $color, supportsOpacity: false).labelsHidden().opacity(0.05))
    }
}
