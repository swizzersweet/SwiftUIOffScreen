import SwiftUI

struct ContentView: View {
    var body: some View {
        DetectScrollPosition()
    }
}

struct OffScreenRepresentableView: UIViewRepresentable {
    var text: String
    
    func makeUIView(context: Self.Context) -> GradientViewUIKit {
        GradientViewUIKit()
    }
    
    func updateUIView(_ uiView: GradientViewUIKit, context: Context) {
        uiView.configure(text: self.text)
    }
}

// Originally from https://saeedrz.medium.com/detect-scroll-position-in-swiftui-3d6e0d81fc6b
struct DetectScrollPosition: View {
    @State private var scrollPosition: CGPoint = .zero
    private let model = Model()
    
    private class Model: ObservableObject {
        @Published var items: [Item]
        private let uiKitViews: [GradientViewUIKit]
        
        enum Item: Hashable {
            case swiftUIView(String)
            case uiKitView(String)
        }
        
        init() {
            let items: [Item] = (0..<50).map { num in
                if num % 2 == 0 {
                    return .swiftUIView("SwiftUI view num: \(num)")
                } else {
                    return .uiKitView("UIKit View: \(num)")
                }
            }
            
            let uiKitItems = items.compactMap { item -> GradientViewUIKit? in
                switch item {
                case .swiftUIView:
                    return nil
                case .uiKitView:
                    return GradientViewUIKit(frame: .zero)
                }
            }
            (self.items, self.uiKitViews) = (items, uiKitItems)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollViewReader { proxy in
                    Button("Scroll to  bottom") {
                        print("scroll to bottom")
                        proxy.scrollTo(model.items.last)
                    }
                    
                    List {
                        ForEach(model.items, id: \.self) { row in
                            OffScreenRepresentableView(text: "\(row)")
                                .screenVisisbilityChanged { isVisisble in
                                    print("isVisible:\(isVisisble): \(row)")
                                        // tell model, client, etc...
                                }
                                .id(row)
                        }
                        .background(GeometryReader { geometry in
                            Color.clear
                                .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .named("scroll")).origin)
                        })
                        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                            self.scrollPosition = value
                        }
                    }
                    .coordinateSpace(name: "scroll")
                    .navigationTitle("Scroll offset: \(scrollPosition.y)")
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero
    
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
    }
}

extension UIApplication {
    var firstKeyWindow: UIWindow? {
        // 1
        let windowScenes = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
        // 2
        let activeScene = windowScenes
            .filter { $0.activationState == .foregroundActive }
        // 3
        let firstActiveScene = activeScene.first
        // 4
        let keyWindow = firstActiveScene?.keyWindow
        
        return keyWindow
    }
}

#Preview {
    ContentView()
}
