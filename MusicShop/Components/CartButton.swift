import SwiftUI

struct CartButton: View {
    var numberOfProducts: Int
    
    var body: some View {
        ZStack {
            Image(systemName: "cart")
                .padding(.top, 5)
            
            if numberOfProducts > 0 {
                Text("\(numberOfProducts)")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(5)
                    .background(.red)
                    .clipShape(Circle())
                    // 將原本在正中間的往右上角移動
                    .offset(x: 10, y: -10)
            }
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    CartButton(numberOfProducts: 1)
        .padding()
}
