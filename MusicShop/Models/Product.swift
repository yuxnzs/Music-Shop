import Foundation

class Product: Identifiable, ObservableObject {
    var id = UUID()
    let productName: String
    var image: String
    var artistName: String
    var artistImage: String
    let release_date: String
    let type: String
    var price: Double
    var stock: Int
    
    init(productName: String, image: String, artistName: String, artistImage: String, release_date: String, type: String, price: Double, stock: Int) {
        self.productName = productName
        self.image = image
        self.artistName = artistName
        self.artistImage = artistImage
        self.release_date = release_date
        self.type = type
        self.price = price
        self.stock = stock
    }
}
