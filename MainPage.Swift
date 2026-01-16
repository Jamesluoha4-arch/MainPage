import SwiftUI

struct MainView: View {
    @State private var isPlayingPagePresented = false
    @State private var dragOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // 背景层：第一界面
            ContentView()
                .scaleEffect(isPlayingPagePresented ? 0.95 : 1.0 - (dragOffset / 2000))
                .blur(radius: isPlayingPagePresented ? 4 : (dragOffset / 200))
                .animation(.interactiveSpring(), value: dragOffset)
                .animation(.spring(), value: isPlayingPagePresented)
            
            // 覆盖层：第二界面 (从上方拽入)
            if isPlayingPagePresented || dragOffset > 0 {
                PlayPage(isPresented: $isPlayingPagePresented)
                    .offset(y: isPlayingPagePresented ? 0 : -UIScreen.main.bounds.height)
                    .offset(y: dragOffset)
                    .transition(.move(edge: .top))
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isPlayingPagePresented)
                    .animation(.interactiveSpring(), value: dragOffset)
            }
        }
        .background(Color.black.ignoresSafeArea())
        .gesture(
            DragGesture(minimumDistance: 10)
                .onChanged { value in
                    // 仅当向下划动且页面未弹出时开始拽拉
                    if !isPlayingPagePresented && value.translation.height > 0 {
                        dragOffset = value.translation.height
                    }
                }
                .onEnded { value in
                    if value.translation.height > 100 {
                        withAnimation(.spring()) {
                            isPlayingPagePresented = true
                        }
                    }
                    dragOffset = 0
                }
        )
    }
}
