import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .album
    // @StateObject 與 @State 類似
    // @State 是用在當前 View 內管理狀態
    // 而 @StateObject 是用在 ObservableObject 類別內管理狀態，並允許跨 View 共享同個物件
    // 專輯跟單曲頁面共享購物車
    @StateObject private var cartManager = CartManager()
    // 分別為兩個頁面建立各自的 SpotifyService，在切換頁面後保持上次搜尋結果，而不是在 ProductView 內創建，導致每次重置
    @StateObject private var albumSpotifyService = SpotifyService() // 專輯的 SpotifyService
    @StateObject private var singleSpotifyService = SpotifyService() // 單曲的 SpotifyService
    
    // 傳遞給 ProductView，ProductView 再傳給 ProductDetailView 共享此變數
    // 用於判斷是否顯示產品詳情頁面，以決定是否渲染底部導航列
    @State private var isShowingTabBar = true
    
    // 保持上次搜尋結果，而不是在 ProductView 內創建，導致每次重置
    @State private var albumArtistNameInput = ""
    @State private var albumArtistName: String?
    @State private var singleArtistNameInput = ""
    @State private var singleArtistName: String?
    
    var body: some View {
        GeometryReader { geometry in
            // 使用 ZStack 讓 View 跟導航列不會分成兩塊，而是疊在一起
            ZStack {
                VStack {
                    Spacer()
                    
                    // 根據選中的 tab 顯示對應的頁面
                    switch selectedTab {
                    case .album:
                        ProductView(productType: "album",
                                    displayProductType: "專輯",
                                    artistNameInput: $albumArtistNameInput,
                                    artistName: $albumArtistName,
                                    isShowingTabBar: $isShowingTabBar)
                        .environmentObject(cartManager)
                        .environmentObject(albumSpotifyService)
                    case .single:
                        ProductView(productType: "single",
                                    displayProductType: "單曲",
                                    artistNameInput: $singleArtistNameInput,
                                    artistName: $singleArtistName,
                                    isShowingTabBar: $isShowingTabBar)
                            .environmentObject(cartManager)
                            .environmentObject(singleSpotifyService)
                    case .orders:
                        EmptyView()
                    }
                }
                .ignoresSafeArea()
                
                if isShowingTabBar {
                    VStack {
                        // 底部導航列
                        ExpandTextTabBar(selectedTab: $selectedTab)
                            .frame(width: 350)
                    }
                    // 透過 GeometryReader 計算相對底部位置，以在不同裝置上顯示正確
                    // x：將螢幕寬度除以 2，獲得中心位置，讓導航列的水平中心位置
                    // y：導航列的垂直位置，減去一個值表示與底部的距離
                    .position(x: geometry.size.width / 2, y: geometry.size.height - 20)
                    .animation(.easeInOut(duration: 0.6), value: isShowingTabBar)
                    .transition(.move(edge: .bottom))
                }
            }
            .animation(.easeInOut(duration: 0.6), value: isShowingTabBar)
            .transition(.move(edge: .bottom))
            .onAppear {
                addKeyboardObservers()
            }
            .onDisappear {
                removeKeyboardObservers()
            }
        }
    }
    
    // 讓鍵盤彈上來時隱藏底部導航列，避免導航列跟著彈上來
    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { _ in
            withAnimation {
                isShowingTabBar = false
            }
        }
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            withAnimation {
                isShowingTabBar = true
            }
        }
    }
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

#Preview {
    ContentView()
}
