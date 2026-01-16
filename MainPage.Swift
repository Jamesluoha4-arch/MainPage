import SwiftUI

// MARK: - 1. 基础工具：颜色与动画曲线
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue:  Double(b) / 255, opacity: Double(a) / 255)
    }
}

extension Animation {
    static var dragSpring: Animation {
        .spring(response: 0.5, dampingFraction: 0.82, blendDuration: 0)
    }
}

// MARK: - 2. 核心容器 (App 入口)
struct MainView: View {
    @State private var showPlayback = false     // 是否完全进入播放页
    @State private var dragOffset: CGFloat = 0  // 实时拖拽位移
    
    // 屏幕高度
    private let screenHeight = UIScreen.main.bounds.height
    
    var body: some View {
        ZStack {
            // --- 第一层：主信息流界面 (ContentView) ---
            ContentView()
                .scaleEffect(showPlayback ? 0.94 : 1.0 - (dragOffset / screenHeight * 0.06))
                .blur(radius: showPlayback ? 10 : (dragOffset / screenHeight * 5))
                .opacity(showPlayback ? 0.5 : 1.0)
                .animation(.dragSpring, value: dragOffset)
                .animation(.dragSpring, value: showPlayback)
            
            // --- 第二层：播放控制界面 (PlaybackView) ---
            PlaybackView(isPresented: $showPlayback)
                // 初始位置在屏幕上方，完全隐藏
                .offset(y: showPlayback ? 0 : -screenHeight)
                // 叠加实时拖拽位移
                .offset(y: dragOffset)
                .animation(.dragSpring, value: showPlayback)
                .animation(.dragSpring, value: dragOffset)
        }
        .background(Color.black.ignoresSafeArea())
        .gesture(
            DragGesture()
                .onChanged { value in
                    // 仅允许从上往下拽出
                    if !showPlayback && value.translation.height > 0 {
                        dragOffset = value.translation.height
                    }
                }
                .onEnded { value in
                    if value.translation.height > 150 {
                        withAnimation(.dragSpring) {
                            showPlayback = true
                            dragOffset = 0
                        }
                    } else {
                        withAnimation(.dragSpring) {
                            dragOffset = 0
                        }
                    }
                }
        )
    }
}

// MARK: - 3. 第一个界面 (ContentView)
struct ContentView: View {
    @State private var bannerAnimate = false
    @State private var soundSectionOpacity: Double = 0
    
    var currentDateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日"
        return formatter.string(from: Date())
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 40) {
                // 顶部 Banner 区
                headerAndScenesSection
                
                // 声音区块
                VStack(alignment: .leading, spacing: 0) {
                    Text("声音")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    Spacer().frame(height: 35)
                    
                    GeometryReader { proxy in
                        let minY = proxy.frame(in: .global).minY
                        ZStack(alignment: .topTrailing) {
                            // 背景装饰
                            Image("face_lines")
                                .resizable().aspectRatio(contentMode: .fit)
                                .frame(width: 320).opacity(0.6)
                                .offset(x: 60, y: 100)
                            
                            // 文字与气泡
                            VStack(alignment: .leading, spacing: 20) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("晚上好").foregroundColor(.white.opacity(0.8))
                                    Text("用户昵称")
                                        .font(.system(size: 18, weight: .bold))
                                        .padding(.vertical, 8).padding(.horizontal, 20)
                                        .glassStyle(opacity: 0.3, cornerRadius: 12)
                                    Text("现在是\(currentDateText)夜间，一起开启好梦").font(.system(size: 14)).foregroundColor(.gray)
                                }
                                
                                HStack(spacing: 12) {
                                    SoundBubble(title: "白噪音").offset(y: 20)
                                    SoundBubble(title: "自然之声").offset(y: 120).offset(x: 40)
                                    SoundBubble(title: "节奏").offset(y: 220).offset(x: -200)
                                }
                                .padding(.top, 25)
                            }
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .opacity(soundSectionOpacity)
                        .onChange(of: minY) { newValue in
                            if newValue < UIScreen.main.bounds.height * 0.85 {
                                withAnimation(.easeIn(duration: 0.8)) { soundSectionOpacity = 1.0 }
                            }
                        }
                    }
                    .frame(height: 400)
                }
            }
            .padding(.bottom, 120)
        }
    }
    
    private var headerAndScenesSection: some View {
        VStack(spacing: 28) {
            HStack {
                Circle().stroke(Color.white.opacity(0.4), lineWidth: 1).frame(width: 34, height: 34)
                    .overlay(Text("logo").font(.system(size: 8)).foregroundColor(.white))
                Text("Brand Name").font(.system(size: 20, weight: .bold)).foregroundColor(.white)
                Spacer()
                Image(systemName: "sparkles").padding(8).background(Circle().stroke(Color.white.opacity(0.4))).foregroundColor(.white)
            }.padding(.horizontal)

            ZStack(alignment: .bottomLeading) {
                Image("image_share")
                    .resizable().aspectRatio(contentMode: .fill)
                    .scaleEffect(bannerAnimate ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 8.0).repeatForever(autoreverses: true), value: bannerAnimate)
                Text("向下滑动开启").font(.system(size: 22, weight: .heavy)).foregroundColor(.white).padding(24)
            }
            .frame(height: 200).frame(maxWidth: .infinity).clipShape(RoundedRectangle(cornerRadius: 28)).glassStyle(opacity: 0.74).padding(.horizontal)
            .onAppear { bannerAnimate = true }

            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    Text("场景").font(.system(size: 24, weight: .bold)).foregroundColor(.white)
                    Spacer()
                    Text("显示全部").foregroundColor(.gray)
                }.padding(.horizontal)
                
                HStack(alignment: .top, spacing: 14) {
                    VStack(spacing: 14) {
                        SceneCard(title: "专注", imageName: "focus", height: 210)
                        SceneCard(title: "创造", imageName: "create", height: 120)
                    }
                    VStack(spacing: 14) {
                        SceneCard(title: "休息", imageName: "rest", height: 100)
                        SceneCard(title: "冥想", imageName: "meditate", height: 190)
                    }
                }.padding(.horizontal)
            }
        }
    }
}

// MARK: - 4. 第二个界面 (PlaybackView)
struct PlaybackView: View {
    @Binding var isPresented: Bool
    @State private var selectedTab: SoundTab = .whiteNoise
    @State private var innerOffset: CGFloat = 0 // 内部下拉手势位移
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 指示条
                Capsule().fill(Color.white.opacity(0.2)).frame(width: 40, height: 5).padding(.top, 10)
                
                // 顶部标题区
                VStack(spacing: 8) {
                    Text(selectedTab.rawValue).font(.system(size: 28, weight: .bold)).foregroundColor(.white)
                    Text("夜间好梦").font(.system(size: 14)).foregroundColor(.gray)
                }
                .padding(.top, 30)
                .overlay(alignment: .trailing) {
                    Image(systemName: "info.circle.fill").font(.system(size: 22)).foregroundColor(.white.opacity(0.2)).padding(.trailing, 25)
                }
                
                // --- 重点：中间预留黑色动效区域 ---
                Spacer()
                
                // 底部交互区
                VStack(spacing: 35) {
                    // 三个状态切换按钮
                    HStack(spacing: 15) {
                        ForEach(SoundTab.allCases, id: \.self) { tab in
                            InteractiveSoundButton(title: tab.rawValue, isSelected: selectedTab == tab) {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    selectedTab = tab
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // 播放控制
                    HStack(spacing: 40) {
                        controlIcon(icon: "pause.fill", isMain: true)
                        controlIcon(icon: "arrow.clockwise")
                        controlIcon(icon: "timer")
                        controlIcon(icon: "airplayaudio")
                    }
                    
                    // 发现按钮
                    Button(action: {}) {
                        Text("发现").font(.system(size: 16, weight: .medium)).foregroundColor(.white)
                            .frame(maxWidth: .infinity).frame(height: 70)
                            .glassStyle(opacity: 0.4, cornerRadius: 35)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .offset(y: innerOffset)
        }
        .clipShape(RoundedRectangle(cornerRadius: isPresented ? (innerOffset > 0 ? 40 : 0) : 40))
        .gesture(
            DragGesture()
                .onChanged { value in
                    if value.translation.height > 0 { innerOffset = value.translation.height }
                }
                .onEnded { value in
                    if value.translation.height > 150 {
                        withAnimation(.dragSpring) {
                            isPresented = false
                            innerOffset = 0
                        }
                    } else {
                        withAnimation(.dragSpring) { innerOffset = 0 }
                    }
                }
        )
    }
    
    private func controlIcon(icon: String, isMain: Bool = false) -> some View {
        Image(systemName: icon)
            .font(.system(size: isMain ? 24 : 18))
            .foregroundColor(.white)
            .frame(width: 55, height: 55)
            .background(Circle().fill(Color.white.opacity(0.12)))
    }
}

// MARK: - 5. 交互组件与样式修饰符
enum SoundTab: String, CaseIterable {
    case whiteNoise = "白噪音", nature = "自然之声", rhythm = "节奏"
}

struct InteractiveSoundButton: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: isSelected ? .bold : .medium))
                .foregroundColor(isSelected ? .white : .white.opacity(0.5))
                .frame(maxWidth: .infinity).frame(height: 65)
                .glassStyle(
                    opacity: isSelected ? 0.74 : 0.15, 
                    cornerRadius: 20, 
                    showBorder: isSelected,
                    addFloatingEffect: isSelected
                )
                .scaleEffect(isSelected ? 1.02 : 1.0)
        }
    }
}

struct GlassModifier: ViewModifier {
    var cornerRadius: CGFloat
    var opacity: Double
    var showBorder: Bool
    var addFloatingEffect: Bool
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    Color(hex: "0F0F0F").opacity(opacity)
                    if addFloatingEffect {
                        Circle().fill(Color.white.opacity(0.1)).blur(radius: 20).offset(x: -20, y: -20)
                    }
                    LinearGradient(colors: [.white.opacity(0.1), .clear], startPoint: .topLeading, endPoint: .bottomTrailing)
                }
            )
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(showBorder ? 0.4 : 0.1), lineWidth: showBorder ? 1.5 : 0.5)
            )
    }
}

extension View {
    func glassStyle(opacity: Double = 0.74, cornerRadius: CGFloat = 28, showBorder: Bool = false, addFloatingEffect: Bool = false) -> some View {
        self.modifier(GlassModifier(cornerRadius: cornerRadius, opacity: opacity, showBorder: showBorder, addFloatingEffect: addFloatingEffect))
    }
}

// MARK: - 辅助子组件 (SceneCard, SoundBubble)
struct SceneCard: View {
    var title: String
    var imageName: String
    var height: CGFloat
    var body: some View {
        ZStack(alignment: .topLeading) {
            Image(imageName).resizable().scaledToFit().padding(12)
            Text(title).font(.system(size: 17, weight: .bold)).foregroundColor(.white).padding(16)
        }
        .frame(maxWidth: .infinity).frame(height: height)
        .glassStyle(opacity: 0.8)
    }
}

struct SoundBubble: View {
    var title: String
    var body: some View {
        Text(title).font(.system(size: 14, weight: .medium)).foregroundColor(.white)
            .frame(width: 90, height: 70)
            .glassStyle(opacity: 0.7, cornerRadius: 35, showBorder: true)
    }
}
