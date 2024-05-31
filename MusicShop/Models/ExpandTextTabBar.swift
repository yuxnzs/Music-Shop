import SwiftUI

@available(iOS 15, macOS 11.0, *)
struct ExpandTextTabBar: View {
    @Namespace private var tabItemTransition
    
    var tabItems: [Tab] = Tab.allCases
    var verticalPadding: Double = 10.0
    
    @Binding var selectedTab: Tab
    
    var body: some View {
        HStack {
            ForEach(tabItems) { tabItem in
                Spacer()
                
                Button {
                    withAnimation(.easeInOut) {
                        selectedTab = tabItem
                    }
                } label: {
                    TabBarItem(tabItem: tabItem, isActive: tabItem == selectedTab, namespace: tabItemTransition)
                }
                .buttonStyle(.plain)
                .layoutPriority(tabItem == selectedTab ? 2.0 : 1.0)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: 50)
        .padding(.vertical, verticalPadding)
        .background(Color(.systemGray6))
        .cornerRadius(25)
    }
}

@available(iOS 15, macOS 11.0, *)
fileprivate struct TabBarItem: View {
    var tabItem: Tab
    var isActive: Bool = false
    let namespace: Namespace.ID
    
    var body: some View {
        
        HStack(alignment: .center, spacing: 3) {
            Image(systemName: tabItem.icon)
                .font(.system(size: isActive ? 24 : 22, weight: isActive ? .medium : .regular))
                .foregroundColor(isActive ? tabItem.activeColor : .gray)
                .animation(.interactiveSpring(), value: isActive)
                
            if isActive {
                Text(tabItem.name)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .minimumScaleFactor(0.3)
                    .foregroundColor(isActive ? tabItem.activeColor : .gray)
                    .transition(.scale)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background {
            RoundedRectangle(cornerRadius: 25.0)
                .fill(isActive ? tabItem.activeColor.opacity(0.2) : .clear)
        }
    }
}

@available(iOS 15, macOS 11.0, *)
struct ExpandTextTabBar_Previews: PreviewProvider {
    static var previews: some View {

        ExpandTextTabBarDemo()
            .previewDisplayName("ExpandTextTabBar")
        
        ExpandTextBarItemDemo()
            .previewDisplayName("ExpandTextBarItem")
    }
    
    struct ExpandTextTabBarDemo: View {
        @State private var selectedTab: Tab = .album
        
        var body: some View {
            ExpandTextTabBar(selectedTab: $selectedTab)
        }
    }
    
    struct ExpandTextBarItemDemo: View {
        
        @Namespace private var tabItemTransition
        
        var body: some View {
            TabBarItem(tabItem: .album, isActive: true, namespace: tabItemTransition)
        }
    }
}

