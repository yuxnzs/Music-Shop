import SwiftUI

struct CartView: View {
    @EnvironmentObject var cartManager: CartManager
    
    // 從 ContentView 傳來決定是否要顯示底部導航列的 Bool
    @Binding var isShowingTabBar: Bool
    
    var body: some View {
        ScrollView {
            if cartManager.productsInCart.isEmpty {
                Text("你的購物車目前是空的")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                // .enumerated() 返回一個序列，序列中的每個元素都是一個元組
                // Array() 將序列轉換為陣列，讓 ForEach 能夠識別和迭代
                // \.offset 告訴 ForEach 使用元組的第一個元素（index）作為每個元素的唯一標識符
                // 這樣即使產品重複，也不會有重複的 id 錯誤
                ForEach(Array(cartManager.productsInCart.enumerated()), id: \.offset) { index, product in
                    ProductRow(product: product, removeIndex: index)
                    
                    Divider()
                        .padding()
                }
                
                HStack {
                    Text("總計")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Text("$\(cartManager.total, specifier: "%.2f")")
                        .font(.headline)
                        .fontWeight(.bold)
                } //: HStack
                .padding()
            }
        } //: ScrollView
        .navigationTitle("購物車")
        .padding(.top)
        .onAppear {
            // 隱藏底部導航列
            isShowingTabBar = false
        }
        .onDisappear {
            // 顯示底部導航列
            isShowingTabBar = true
        }
    }
}

#Preview {
    CartView(isShowingTabBar: .constant(false))
        .environmentObject(CartManager())
}
