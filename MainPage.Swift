import SwiftUI

// MARK: - 1. 基础工具扩展
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

// MARK: - 2. 按钮内强虚化漂浮圆组件
struct FloatingBlurCircle: View {
    @State private var move = false
    
    var body: some View {
        GeometryReader { proxy in
            Circle()
                .fill(Color.white.opacity(0.35))
                .frame(width: 45, height: 45)
                .blur(radius: 20) // 强虚化质感
                .offset(x: move ? proxy.size.width - 45 : 0,
                        y: move ? proxy.size.height - 45 : 0)
                .onAppear {
                    // 缓慢漂浮动画
                    withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
                        move.toggle()
                    }
                }
        }
    }
}

// MARK: - 3. 玻璃质感修饰符 (带漂浮圆开关)
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
                        FloatingBlurCircle()
                            .mask(RoundedRectangle(cornerRadius: cornerRadius))
                    }
                    
                    // 顶部光泽感
                    LinearGradient(stops: [
                        .init(color: .white.opacity(0.15), location: 0),
                        .init(color: .clear, location: 0.5)
                    ], startPoint: .topLeading, endPoint: .bottomTrailing)
                }
            )
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(showBorder ? 0.4 : 0.15), lineWidth: showBorder ? 1.5 : 0.5)
            )
    }
}

extension View {
    func glassStyle(opacity: Double = 0.74, cornerRadius: CGFloat = 28, showBorder: Bool = false, addFloatingEffect: Bool = false) -> some View {
        self.modifier(GlassModifier(cornerRadius: cornerRadius, opacity: opacity, showBorder: showBorder, addFloatingEffect: addFloatingEffect))
    }
}

// MARK: - 4. 核心组件
struct SoundBubble: View {
    var title: String
    var body: some View {
        Text(title)
            .font(.system(size: 15, weight: .medium))
            .foregroundColor(.white)
            .frame(width: 105, height: 75)
            .glassStyle(opacity: 0.74, cornerRadius: 38, showBorder: true, addFloatingEffect: true)
            .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 10)
    }
}

struct SceneCard: View {
    var title: String
    var imageName: String
    var height: CGFloat
    var body: some View {
        ZStack(alignment: .topLeading) {
            Image(imageName).resizable().scaledToFit().padding(12)
            Text(title).font(.system(size: 18, weight: .bold)).foregroundColor(.white).padding(16)
        }
        .frame(maxWidth: .infinity).frame(height: height)
        .glassStyle(opacity: 1.0)
    }
}

// MARK: - 5. 主界面
struct ContentView: View {
    @State private var bannerAnimate = false
    @State private var soundOpacity: Double = 0.0 // 控制透明度
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 50) {
                    
                    // --- 第一部分：顶部 ---
                    headerAndScenes
                    
                    // --- 第二部分：声音区块 (带滚动渐显效果) ---
                    VStack(alignment: .leading, spacing: 0) {
                        Text("声音")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        Spacer().frame(height: 35)
                        
                        // 滚动监听容器
                        GeometryReader { proxy in
                            let minY = proxy.frame(in: .global).minY
                            let screenHeight = UIScreen.main.bounds.height
                            
                            ZStack(alignment: .topTrailing) {
                                // 背景
                                Image("face_lines")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 320)
                                    .opacity(0.5)
                                    .offset(x: 60, y: 120)
                                
                                Image("image_shooting_star")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 140)
                                    .offset(x: -20, y: -25)
                                
                                // 文字内容
                                VStack(alignment: .leading, spacing: 30) {
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("晚上好").font(.system(size: 18)).foregroundColor(.white.opacity(0.8))
                                        Text("用户昵称")
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(.white)
                                            .padding(.vertical, 8).padding(.horizontal, 22)
                                            .glassStyle(opacity: 0.3, cornerRadius: 15)
                                        Text("现在是夜间，一起开启好梦").font(.system(size: 14)).foregroundColor(.gray)
                                    }
                                    
                                    // 三个按钮按 45 度斜向排列
                                    ZStack(alignment: .topLeading) {
                                        SoundBubble(title: "白噪音")
                                            .offset(x: 0, y: 0)
                                        
                                        SoundBubble(title: "自然之声")
                                            .offset(x: 80, y: 80)
                                        
                                        SoundBubble(title: "节奏")
                                            .offset(x: 160, y: 160)
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .opacity(soundOpacity) // 绑定透明度状态
                            .onChange(of: minY) { newValue in
                                // 计算逻辑：当组件顶部出现在屏幕底部 20% 以上时触发
                                let triggerPoint = screenHeight * 0.8
                                if newValue < triggerPoint {
                                    withAnimation(.easeIn(duration: 1.0)) {
                                        soundOpacity = 1.0
                                    }
                                }
                            }
                        }
                        .frame(height: 550)
                    }
                }
                .padding(.bottom, 150)
            }
        }
    }
    
    // 抽离的顶部组件逻辑
    var headerAndScenes: some View {
        VStack(spacing: 28) {
            HStack {
                Circle().stroke(Color.white.opacity(0.4)).frame(width: 34).overlay(Text("logo").font(.system(size: 8)).foregroundColor(.white))
                Text("Brand Name").font(.system(size: 20, weight: .bold)).foregroundColor(.white)
                Spacer()
                Image(systemName: "sparkles").padding(8).background(Circle().stroke(Color.white.opacity(0.4))).foregroundColor(.white)
            }.padding(.horizontal)

            // 场景卡片示例
            VStack(alignment: .leading, spacing: 18) {
                Text("场景").font(.system(size: 24, weight: .bold)).foregroundColor(.white).padding(.horizontal)
                HStack(spacing: 14) {
                    SceneCard(title: "专注", imageName: "focus", height: 200)
                    SceneCard(title: "休息", imageName: "rest", height: 200)
                }.padding(.horizontal)
            }
        }
    }
}
