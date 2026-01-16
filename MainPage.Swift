import SwiftUI

// MARK: - 1. 颜色与工具扩展
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

// MARK: - 2. 内部漂浮虚化圆组件
struct FloatingBlurCircle: View {
    @State private var move = false
    
    var body: some View {
        GeometryReader { proxy in
            Circle()
                .fill(Color.white.opacity(0.4))
                .frame(width: 40, height: 40)
                .blur(radius: 15) // 强虚化
                .offset(x: move ? proxy.size.width - 40 : 0, 
                        y: move ? proxy.size.height - 40 : 0)
                .onAppear {
                    withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                        move.toggle()
                    }
                }
        }
    }
}

// MARK: - 3. 增强版玻璃质感修饰符
struct GlassModifier: ViewModifier {
    var cornerRadius: CGFloat
    var opacity: Double
    var showBorder: Bool
    var isButton: Bool = false
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    Color(hex: "0F0F0F").opacity(opacity)
                    
                    if isButton {
                        FloatingBlurCircle() // 按钮内部的漂浮圆
                            .mask(RoundedRectangle(cornerRadius: cornerRadius))
                    }
                    
                    LinearGradient(stops: [
                        .init(color: .white.opacity(0.12), location: 0),
                        .init(color: .clear, location: 0.5)
                    ], startPoint: .topLeading, endPoint: .bottomTrailing)
                }
            )
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(showBorder ? 0.35 : 0.15), lineWidth: showBorder ? 1.5 : 0.5)
            )
    }
}

extension View {
    func glassStyle(opacity: Double = 0.74, cornerRadius: CGFloat = 28, showBorder: Bool = false, isButton: Bool = false) -> some View {
        self.modifier(GlassModifier(cornerRadius: cornerRadius, opacity: opacity, showBorder: showBorder, isButton: isButton))
    }
}

// MARK: - 4. 声音气泡组件
struct SoundBubble: View {
    var title: String
    var body: some View {
        Text(title)
            .font(.system(size: 15, weight: .medium))
            .foregroundColor(.white)
            .frame(width: 100, height: 75)
            .glassStyle(opacity: 0.74, cornerRadius: 40, showBorder: true, isButton: true)
            .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 10)
    }
}

// MARK: - 5. 主界面
struct ContentView: View {
    @State private var bannerAnimate = false
    
    // 用于控制声音部分的透明度
    @State private var soundSectionOpacity: Double = 0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 40) {
                    
                    // 第一部分：导航与场景 (原有部分)
                    topSection
                    
                    // --- 第二部分：“声音”区块 ---
                    VStack(alignment: .leading, spacing: 0) {
                        Text("声音")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        Spacer().frame(height: 35)
                        
                        // 监听滚动位置的容器
                        GeometryReader { proxy in
                            let minY = proxy.frame(in: .global).minY
                            let screenHeight = UIScreen.main.bounds.height
                            
                            ZStack(alignment: .topTrailing) {
                                // 背景线条
                                Image("face_lines")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 320)
                                    .opacity(0.6)
                                    .offset(x: 60, y: 100)
                                
                                // 流星
                                Image("image_shooting_star")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 140)
                                    .offset(x: -15, y: -20)
                                
                                // 内容层
                                VStack(alignment: .leading, spacing: 20) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("晚上好").foregroundColor(.white.opacity(0.8))
                                        Text("用户昵称")
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(.white)
                                            .padding(.vertical, 8).padding(.horizontal, 20)
                                            .glassStyle(opacity: 0.3, cornerRadius: 12)
                                        Text("现在是夜间，一起开启好梦").font(.system(size: 14)).foregroundColor(.gray)
                                    }
                                    
                                    // 按钮 45度角排列
                                    ZStack {
                                        SoundBubble(title: "白噪音")
                                            .offset(x: -80, y: -40)
                                        SoundBubble(title: "自然之声")
                                            .offset(x: 0, y: 40)
                                        SoundBubble(title: "节奏")
                                            .offset(x: 80, y: 120)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.top, 40)
                                }
                                .padding(.horizontal)
                            }
                            .opacity(soundSectionOpacity) // 绑定透明度
                            .onAppear {
                                updateOpacity(y: minY, screenHeight: screenHeight)
                            }
                            .onChange(of: minY) { newValue in
                                withAnimation(.easeOut(duration: 0.8)) {
                                    updateOpacity(y: newValue, screenHeight: screenHeight)
                                }
                            }
                        }
                        .frame(height: 500) // 为内容预留足够高度
                    }
                }
                .padding(.bottom, 100)
            }
        }
    }
    
    // 透明度计算逻辑：当元素进入屏幕下半部分时开始显现
    private func updateOpacity(y: CGFloat, screenHeight: CGFloat) {
        let threshold = screenHeight * 0.85
        if y < threshold {
            soundSectionOpacity = 1.0
        } else {
            soundSectionOpacity = 0.0
        }
    }
    
    // 抽离的顶部组件
    private var topSection: some View {
        VStack(spacing: 28) {
            HStack {
                Circle().stroke(Color.white.opacity(0.4)).frame(width: 34).overlay(Text("logo").font(.system(size: 8)).foregroundColor(.white))
                Text("Brand Name").font(.system(size: 20, weight: .bold)).foregroundColor(.white)
                Spacer()
                Image(systemName: "gift").foregroundColor(.white)
                Image(systemName: "sparkles").padding(8).background(Circle().stroke(Color.white.opacity(0.4))).foregroundColor(.white)
            }.padding(.horizontal)
            
            // 之前的分享卡片和场景卡片逻辑保持在这里...
            Rectangle().fill(Color.white.opacity(0.05)).frame(height: 200).cornerRadius(28).padding(.horizontal)
                .overlay(Text("场景展示区").foregroundColor(.gray))
        }
    }
}
