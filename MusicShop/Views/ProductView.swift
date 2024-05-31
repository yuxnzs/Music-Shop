import SwiftUI

// 擴展 UIApplication 的關閉鍵盤方法
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct ProductView: View {
    @EnvironmentObject var spotifyService: SpotifyService
    @EnvironmentObject var cartManager: CartManager
    
    // 傳給 API 要搜尋專輯或單曲的參數
    let productType: String
    
    // 標題文字
    let displayProductType: String
    
    @Binding var artistNameInput: String // 使用者輸入的歌手名稱
    @Binding var artistName: String? // 透過使用者輸入取得 Spotify 回傳的完整歌手名稱
    
    // 從父 View 傳來決定是否要顯示底部導航列的 Bool
    @Binding var isShowingTabBar: Bool
    @State private var isDetailViewActive = false
    
    // 顯示錯誤訊息的 Alert
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var columns = [
        // 一行最多顯示兩個 Card
        GridItem(.adaptive(minimum: 160), spacing: 20),
        GridItem(.adaptive(minimum: 160), spacing: 20),
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                HStack(spacing: 0) {
                    TextField("輸入歌手名稱", text: $artistNameInput)
                        .padding(.leading, 10)
                        .padding(.vertical, 5)
                        .frame(height: 50)
                    
                    Button {
                        UIApplication.shared.endEditing() // 按下搜尋時關閉鍵盤
                        spotifyAction(type: productType)
                    } label: {
                        Text("搜尋")
                            .padding(.horizontal, 20)
                            .frame(height: 50)
                            .background(.black)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                } //: HStack
                .background(.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal)
                .padding(.vertical, 5)
                
                if let artistName = artistName {
                    Text("搜索商品：\(artistName) 的\(displayProductType)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading)
                        .padding(.top, 5)
                }
                
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(spotifyService.productList) { product in
                        // 使用 NavigationLink 會自動變成可點擊區域
                        // 不需要使用 onTapGesture
                        NavigationLink {
                            ProductDetailView(isShowingTabBar: $isShowingTabBar)
                                .environmentObject(product)
                                .environmentObject(cartManager)
                        } label: {
                            ProductCard(product: product)
                                .environmentObject(cartManager)
                        }
                    }
                } //: LazyVGrid
                .padding()
                .padding(.bottom, 50)
            } //: ScrollView
            .navigationTitle("\(displayProductType)商店")
            .toolbar {
                NavigationLink {
                    // destination: CartView()
                    CartView(isShowingTabBar: $isShowingTabBar)
                        .environmentObject(cartManager)
                } label: {
                    CartButton(numberOfProducts: cartManager.productsInCart.count)
                }
            }
            .alert(Text(alertMessage), isPresented: $showAlert) {
                Button("確定") {
                    showAlert = false
                }
            }
        }
        
    }
    
    func spotifyAction(type: String) -> Void {
        spotifyService.getAccessToken { accessToken in
            if let token = accessToken {
                Task {
                    do {
                        let (artistID, spotifyArtistName) = try await spotifyService.getArtistID(artistNameInput: artistNameInput, accessToken: token)
                        if let artistID = artistID, let spotifyArtistName = spotifyArtistName {
                            self.artistName = spotifyArtistName // 更新畫面上顯示的歌手名稱
                            // 將取得的專輯資料存入 SpotifyService 類別的 productList 陣列
                            spotifyService.productList = try await spotifyService.getArtistProducts(artistID: artistID, accessToken: token, type: type)
                        } else {
                            self.alertMessage = "無法取得歌手\(displayProductType)資料，請確認是否輸入正確的歌手名稱"
                            self.showAlert = true
                            print("無法取得 Artist ID")
                        }
                    } catch {
                        self.alertMessage = "無法取得歌手\(displayProductType)資料，請確認是否輸入正確的歌手名稱"
                        self.showAlert = true
                        print("無法取得歌手\(displayProductType)資料：\(error.localizedDescription)")
                    }
                }
            } else {
                print("無法取得 Access Token")
            }
        }
    }
}


#Preview {
    ProductView(productType: "album",
                displayProductType: "專輯",
                artistNameInput: .constant(""),
                artistName: .constant(nil),
                isShowingTabBar: .constant(false))
        .environmentObject(CartManager())
        .environmentObject(SpotifyService())
}
