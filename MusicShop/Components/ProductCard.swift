import SwiftUI

struct ProductCard: View {
    // @EnvironmentObject 允許在 View 層次結構中傳遞和共享一個 ObservableObject
    // 跟 @StateObject 類似，但不會創建新的 ObservableObject
    // 這裡不使用 CartManager() 來初始化，因為會創建一個新的物件
    // 而 @EnvironmentObject 的目的是共享父 View 中已經存在的物件
    // 類似於 React 的 Context API
    @EnvironmentObject var cartManager: CartManager
    
    var product: Product
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            ZStack(alignment: .bottom) {
                // 產品圖片
                AsyncImage(url: URL(string: product.image)) { image in
                    image
                        .resizable()
                        .frame(width: 170, height: 170)
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                } placeholder: {
                    // 在圖片加載過程中顯示一個進度指示器
                    ProgressView()
                        .frame(width: 170, height: 170)
                    // 讓 ProgressView 顯示於圖片正中央
                        .offset(y: -25)
                }
                
                // 產品訊息
                VStack(alignment: .leading) {
                    Text(product.productName)
                        .bold()
                        .font(.system(size: 15))
                    
                    Text("$\(product.price, specifier: "%.2f")")
                        .font(.caption)
                } //: VStack
                .padding()
                .frame(width: 170, alignment: .leading)
                .frame(maxHeight: 50)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            } //: ZStack
            .frame(width: 170, height: 170)
            .shadow(radius: 3)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 20))
            
            Button {
                cartManager.addToCart(product: product)
            } label: {
                Image(systemName: "plus")
                    .padding(10)
                    .foregroundStyle(.black)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .padding(10)
            }
            
        } //: ZStack
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    ProductCard(product: Product(
        productName: "Red (Taylor's Version)",
        image: "https://i.scdn.co/image/ab67616d0000b273318443aab3531a0558e79a4d",
        artistName: "Taylor Swift",
        artistImage: "https://i.scdn.co/image/ab67616100005174859e4c14fa59296c8649e0e4",
        release_date: "2021-11-12",
        type: "Album",
        price: 35.0,
        stock: 10)
    )
    .padding()
    .environmentObject(CartManager())
}
