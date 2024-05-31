/*
    Copyright © 2023 AppCoda Limited.

    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
    Abstract: The model of the tab items
 */

import SwiftUI

protocol TabItem: CaseIterable, Identifiable {
    var id: Int { get }
    var name: String { get }
    var icon: String { get }
    var activeColor: Color { get }
}

@available(iOS 15, macOS 11.0, *)
enum Tab: Int, CaseIterable, Identifiable {
    case album
    case single
    case orders
    
    /// The unique ID for the tab item
    var id: Int {
        self.rawValue
    }
    
    /// The label of the tab item
    var name: String {
        switch self {
        case .album: return "專輯"
        case .single: return "單曲"
        case .orders: return "訂單"
        }
    }
    
    /// The icon of the tab item
    var icon: String {
        switch self {
        case .album: return "music.note.list"
        case .single: return "music.note"
        case .orders: return "shippingbox"
        }
    }
    
    /// The color of the active tab item
    var activeColor: Color {
        switch self {
        case .album: return Color.themeColor
        case .single: return Color.themeColor
        case .orders: return Color.themeColor
        }
    }
}
