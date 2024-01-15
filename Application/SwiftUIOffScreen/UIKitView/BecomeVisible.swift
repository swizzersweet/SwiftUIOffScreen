import SwiftUI

public extension View {
    func screenVisisbilityChanged(perform action: @escaping (Bool) -> Void) -> some View {
        modifier(OnScreenVisibility(action: action))
    }
}

private struct OnScreenVisibility: ViewModifier {
    @State var action: ((Bool) -> Void)

    func body(content: Content) -> some View {
        content.overlay {
            GeometryReader { proxy in
                Color.clear
                    .preference(
                        key: VisibleKey.self,
                        value: UIScreen.main.bounds.intersects(proxy.frame(in: .global))
                    )
                    .onPreferenceChange(VisibleKey.self) { isVisible in
                        self.action(isVisible)
                    }
            }
        }
    }

    struct VisibleKey: PreferenceKey {
        static var defaultValue: Bool = false
        static func reduce(value: inout Bool, nextValue: () -> Bool) { }
    }
}
