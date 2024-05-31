import SwiftUI

struct ProductDetailView: View {
    @EnvironmentObject var product: Product
    @EnvironmentObject var cartManager: CartManager
    
    @Binding var isShowingTabBar: Bool
    
    var body: some View {
        ZStack {
            VStack {
                AsyncImage(url: URL(string: product.image)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    ProgressView()
                }
                .frame(maxWidth: .infinity, maxHeight: 400)
                Spacer()
            }
            .ignoresSafeArea()
            
            // 產品資訊部分
            // 用 VStack 包住，避免往下滑時整個 ScrollView 跟著滑動蓋住圖片
            VStack {
                // 不使用 .offset(y: -20)，因為會將整個 ScrollView 往上移，底部會留白
                // 不往下推 400，推 380，達到資訊欄位部分壓到圖片底部
                Spacer(minLength: 380)
                ScrollView {
                    // 資訊 + 按鈕 Wrapper
                    VStack {
                        VStack {
                            // 產品名稱和價格
                            VStack(alignment: .leading) {
                                Text(product.productName)
                                    .font(.title)
                                    .padding(.bottom, 1)
                                    .foregroundStyle(Color.themeColor)
                                
                                Text("$\(product.price, specifier: "%.2f")")
                                    .font(.title3)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .bold()
                            .background(.white)
                            
                            Spacer(minLength: 10)
                            
                            // 詳細資訊
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    AsyncImage(url: URL(string: product.artistImage)) { image in
                                        image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 50, height: 50)
                                            .clipShape(Circle())
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    
                                    VStack(alignment: .leading) {
                                        Text("演出者")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                        
                                        Text(product.artistName)
                                            .font(.headline)
                                    }
                                    .padding(.leading, 2)
                                }
                                .padding(.bottom, 5)
                                
                                Text("類型：\(product.type.capitalized)")
                                    .font(.subheadline)
                                
                                Text("庫存量：\(product.stock)")
                                    .font(.subheadline)
                                
                                Text("發行日期：\(product.release_date)")
                                    .font(.subheadline)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .bold()
                            .background(.white)
                            
                            Spacer(minLength: 60)
                            
                            Button {
                                cartManager.addToCart(product: product)
                            } label: {
                                ActionButton(title: "加入購物車", backgroundColor: .themeColor, foregroundColor: .white)
                            }
                            
                            Button {
                                
                            } label: {
                                ActionButton(title: "查看優惠券", backgroundColor: .gray.opacity(0.3), foregroundColor: .black)
                            }
                            
                            Spacer(minLength: 25)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                }
                .background(Color(red: 0.956, green: 0.956, blue: 0.956))
                .clipShape(RoundedRectangle(cornerRadius: 30)) // 因為有背景顏色，所以也要圓角
                .shadow(radius: 50)
            }
            .ignoresSafeArea() // 確保與圖片的起始點位置一樣，才可透過圖片高度往下推
        }
        .onAppear {
            // 進入產品詳情畫面時隱藏底部導航列
            isShowingTabBar = false
        }
        .onDisappear {
            /* 透過在 ProductDetailView、CartView 消失時設為 true
               而不是在 ProductView 出現時設為 true，可以解決 ProductDetailView 透過手勢返回到一半卻取消
               就出現導航列的問題 */
            isShowingTabBar = true
        }
    }
}

#Preview {
    ProductDetailView(isShowingTabBar: .constant(false))
        .environmentObject(Product(
            productName: "1989 (Taylor's Version)",
            image: "https://i.scdn.co/image/ab67616d0000b273904445d70d04eb24d6bb79ac",
            artistName: "Taylor Swift",
            artistImage: "https://i.scdn.co/image/ab67616100005174859e4c14fa59296c8649e0e4",
            release_date: "2023-10-21",
            type: "album",
            price: 35.0,
            stock: 10)
        )
        .environmentObject(CartManager())
}
