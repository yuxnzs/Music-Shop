import Foundation

// ObservableObject 讓 CartManager 變成可被監聽的類別，用來讓類別可以被監聽
// 當這個類別的屬性被改變時，可以通知其他的物件
// 類別中的更改會立即在 UI 中更新
class CartManager: ObservableObject {
    // 當 products 改變時，通知所有監聽者
    // private(set) 表示只有 CartManager 這個類別可以更改 products 的值
    // 亦即：允許外部程式讀取屬性值，但只能在類別內部修改屬性值
    // @Published 用來標記 ObservableObject 中的屬性
    // 讓這些屬性在發生變化時通知所有監聽該對象的 View 進行更新
    @Published private(set) var productsInCart: [Product] = []
    
    // 當 total 改變時，通知所有監聽者
    @Published private(set) var total: Double = 0
    
    func addToCart(product: Product) {
        // 將 product 加入 products
        productsInCart.append(product)
        
        total += product.price
    }
    
    func removeFromCart(product: Product, removeIndex: Int) {
        // 將 product 從 products 移除
        // 過濾掉 id 與傳進來 product.id 相同的產品
        productsInCart.remove(at: removeIndex)

        total -= product.price
    }
}
