import SwiftUI

struct ProductRow: View {
    @EnvironmentObject var cartManager: CartManager
    
    var product: Product
    // 使用 removeIndex 來刪除購物車中的產品
    // 這樣在產品重複的情況下，不會發生要刪除後面加進來的產品
    // 卻刪除最前面加進來的產品
    // 一開始 removeFromCart() 使用 .filter，導致所有同名產品都被刪除
    // 改用 .first 卻導致只刪除第一個同名產品
    // 最後使用 remove(at:)，並傳入 removeIndex 直接指定要刪除的產品來解決
    // CartView 的 ForEach() 每次變動都會重新渲染，所以 removeIndex 會隨著重新渲染而變動
    @State var removeIndex: Int
    
    var body: some View {
        HStack(spacing: 20) {
            AsyncImage(url: URL(string: product.image)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } placeholder: {
                // 在圖片加載過程中顯示一個進度指示器
                ProgressView()
                    .frame(width: 50, height: 50)
                // 讓 ProgressView 顯示於圖片正中央
                    .offset(y: -30)
            }
            
            
            VStack(alignment: .leading) {
                Text(product.productName)
                    .bold()
                
                Text("$\(product.price, specifier: "%.2f")")
            }
            
            Spacer()
            
            Image(systemName: "trash")
                .foregroundStyle(.red)
                .onTapGesture {
                    withAnimation {
                        cartManager.removeFromCart(product: product, removeIndex: removeIndex)
                    }
                }
        } //: HStack
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    ProductRow(product: Product(
        productName: "Red (Taylor's Version)",
        image: "https://i.scdn.co/image/ab67616d0000b273318443aab3531a0558e79a4d",
        artistName: "Taylor Swift",
        artistImage: "https://i.scdn.co/image/ab67616100005174859e4c14fa59296c8649e0e4",
        release_date: "2021-11-12",
        type: "Album",
        price: 35.0,
        stock: 10), removeIndex: 5)
    .environmentObject(CartManager())
    .padding()
}
