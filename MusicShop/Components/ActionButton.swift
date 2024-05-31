import SwiftUI

struct ActionButton: View {
    let title: String
    let backgroundColor: Color
    let foregroundColor: Color
    
    var body: some View {
        Text(title)
            .font(.headline)
            .bold()
            .padding()
            .frame(width: 300, height: 50)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .foregroundStyle(foregroundColor)
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    ActionButton(title: "加入購物車", backgroundColor: .themeColor, foregroundColor: .white)
        .padding()
}
