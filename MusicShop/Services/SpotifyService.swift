import SwiftUI

// getArtistID() 所呼叫的回傳資料類型
struct ArtistSearchResponse: Codable {
    let artists: Artists
    
    struct Artists: Codable {
        let items: [Artist]
    }
    
    struct Artist: Codable {
        let id: String
        let name: String
        let images: [ArtistImage]
        
        // 取得圖片陣列中第一個 640 x 640 的圖片
        func firstImageUrl() -> String? {
            return images.first?.url
        }
    }
    
    struct ArtistImage: Codable {
        let url: String
    }
}

// getArtistAlbum() 所呼叫的回傳資料類型
// API 將專輯 / 單曲回傳資料放在 items 中
struct ProductResponse: Codable {
    let items: [Album]
}

// API items 內的結構，只保留回傳資料中需要的名稱、圖片部分
struct Album: Codable {
    let name: String // Product Name
    let images: [ProductImage]
    let artists: [Artist]
    let release_date: String
    let type: String
    
    // 取得圖片陣列中第一個 640 x 640 的圖片
    func firstImageUrl() -> String? {
        return images.first?.url
    }
    
    // API images 內的結構，只保留圖片網址
    struct ProductImage: Codable {
        let url: String
    }
    
    struct Artist: Codable {
        let name: String
    }
}


class SpotifyService: ObservableObject {
    @Published var productList: [Product] = []
    
    private let clientID = Config.clientID
    private let clientSecret = Config.clientSecret
    
    // 因為歌手圖片由 getArtistID() 取得，為了在取得音樂資料時也同時取得歌手圖片，需額外儲存
    var artistImage: String = ""
    
    // 取得 Access Token
    // 這裡使用 completion handler 作為練習，後續呼叫皆使用 async/await
    // @escaping 表示這個閉包不會馬上執行，而是在網路請求完成後才執行
    func getAccessToken(completion: @escaping (String?) -> Void) {
        // 設定憑證和編碼
        let credentials = "\(clientID):\(clientSecret)"
        guard let encodedCredentials = credentials.data(using: .utf8)?.base64EncodedString() else {
            print("無法編碼憑證")
            completion(nil)
            return
        }
        
        // HTTP 請求，與 JavaScript 在 fetch() 中的設定類似
        // 但與 JavaScript 作法不同，不分開設定，而是封装一起
        // Swift 創建一個 URLRequest 物件來封裝請求的所有細節
        // 首先創建 URL 物件，然後創建 URLRequest 物件，將 URL 傳遞給 URLRequest
        // 並設置請求方法、標頭和主體
        
        // 創建 URL 物件
        let authURL = URL(string: "https://accounts.spotify.com/api/token")!
        // 創建 URLRequest 物件
        var authRequest = URLRequest(url: authURL)
        
        // 指定請求方法為 POST
        // JavaScript -> method: 'POST'
        authRequest.httpMethod = "POST"
        
        // Header
        // JavaScript -> headers: { 'Authorization': `Basic ${encodedCredentials}`, 'Content-Type': 'application/x-www-form-urlencoded' }
        authRequest.setValue("Basic \(encodedCredentials)", forHTTPHeaderField: "Authorization")
        authRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        // Body
        // JavaScript -> body: 'grant_type=client_credentials'
        authRequest.httpBody = "grant_type=client_credentials".data(using: .utf8)
        
        // JavaScript -> fetch(authURL, authRequest).then(response => response.json()).then(data => console.log(data)).catch(error => console.error(error))
        // URLSession 為單例模式，因此使用 shared
        let session = URLSession.shared
        // dataTask，發起 HTTP 請求
        let authTask = session.dataTask(with: authRequest) { data, response, error in
            // JavaScript -> .catch(error => console.error(error))
            if let error = error {
                print("認證錯誤：\(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("沒有資料")
                completion(nil)
                return
            }
            
            do {
                // JSONSerialization.jsonObject(with: options:) 將 JSON 資料轉換成 Swift 物件
                // as? [String: Any] 將轉換後的物件轉換成字典
                // try：如果遇到無效的 JSON 資料，會拋出一個錯誤，而後面的 as'?' 是因為轉換可能會失敗
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   // 從解析後的 JSON 字典中取出 access_token
                   let accessToken = json["access_token"] as? String {
                    // 將 access_token 傳遞給 completion 閉包
                    // completion(accessToken) 將資料傳遞給調用方，傳遞 accessToken 給呼叫 getAccessToken 的地方
                    completion(accessToken)
                } else {
                    completion(nil)
                }
            } catch {
                print("JSON 解析錯誤：\(error.localizedDescription)")
                completion(nil)
            }
        }
        
        // URLSessionDataTask 任務在創建後是暫停的
        // 要啟動任務，要調用 resume() 方法
        authTask.resume()
    }
    
    // 通用的網路請求函數
    // 將重複的程式碼封裝成一個函數，減少重複
    func sendGetRequest<T: Decodable>(url: URL, accessToken: String) async throws -> T {
        var request = URLRequest(url: url)
        // JavaScript -> method: 'GET'
        request.httpMethod = "GET"
        // JavaScript -> headers: { 'Authorization': Bearer ${accessToken} }
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        // 在 throws 函數內使用 try，錯誤會被傳遞給呼叫方處理，因此不需要 do-catch
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // 檢查伺服器回應錯誤
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        // 使用 JSONDecoder() 前要先自定義資料的結構
        // T.self 為告訴編譯器要解碼的資料類型
        let decodedResponse = try JSONDecoder().decode(T.self, from: data)
        return decodedResponse
    }
    
    // 使用 Access Token 先取得歌手 ID，後再透過歌手 ID 取得歌手名稱
    func getArtistID(artistNameInput: String, accessToken: String) async throws -> (id: String?, name: String?) {
        let baseURL = "https://api.spotify.com/v1/search?q=\(artistNameInput)&type=artist&limit=1";
        
        guard let url = URL(string: baseURL) else {
            print("URL 錯誤")
            throw URLError(.badURL)
        }
        
        let result: ArtistSearchResponse = try await sendGetRequest(url: url, accessToken: accessToken)
        artistImage = result.artists.items.first?.firstImageUrl() ?? ""
        return (id: result.artists.items.first?.id, name: result.artists.items.first?.name)
    }
    
    // 使用歌手 ID 取得歌手專輯
    // 回傳一個含有所有專輯的陣列，陣列內含專輯名稱和專輯封面的元組
    func getArtistProducts(artistID: String, accessToken: String, type: String) async throws -> [Product] {
        let baseURL = "https://api.spotify.com/v1/artists/\(artistID)/albums?include_groups=\(type)&limit=50"
        
        guard let url = URL(string: baseURL) else {
            print("URL 錯誤")
            throw URLError(.badURL)
        }
        
        // 使用自定義的 ProductResponse
        let result: ProductResponse = try await sendGetRequest(url: url, accessToken: accessToken)
        return result.items.map { product in
            return Product(
                productName: product.name,
                image: product.firstImageUrl() ?? "",
                artistName: product.artists.first?.name ?? "",
                artistImage: artistImage,
                release_date: product.release_date,
                type: product.type,
                price: 35.0,
                stock: 10
            )
        }
    }
}
