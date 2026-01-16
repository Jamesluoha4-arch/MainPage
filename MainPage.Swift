import SwiftUI

// --- 1. 颜色扩展 ---
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

// --- 2. 虚化流星组件 ---
struct StarMeteorView: View {
    @State private var animate = false
    var delay: Double = 0
    
    var body: some View {
        GeometryReader { proxy in
            Circle()
                .fill(Color.white.opacity(0.6))
                .frame(width: 4, height: 4)
                .blur(radius: 2) // 虚化效果
                // 拖尾效果
                .overlay(
                    Capsule()
                        .fill(LinearGradient(colors: [.white.opacity(0.4), .clear], startPoint: .leading, endPoint: .trailing))
                        .frame(width: 40, height: 2)
                        .rotationEffect(.degrees(45), anchor: .leading),
                    alignment: .leading
                )
                .offset(x: animate ? proxy.size.width + 50 : -50, 
                        y: animate ? proxy.size.height + 50 : -50)
                .onAppear {
                    withAnimation(Animation.linear(duration: 2.0).repeatForever(autoreverses: false).delay(delay)) {
                        animate = true
                    }
                }
        }
        .clipped() // 确保星星只在卡片范围内显示
    }
}

// --- 3. 玻璃质感修饰符 ---
struct GlassCardModifier: ViewModifier {
    var backgroundColor: Color
    var opacity: Double
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    backgroundColor.opacity(opacity)
                    LinearGradient(gradient: Gradient(stops: [.init(color: .white.opacity(0.12), location: 0), .init(color: .clear, location: 0.5)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                }
            )
            .cornerRadius(28)
            .overlay(RoundedRectangle(cornerRadius: 28).stroke(Color.white.opacity(0.15), lineWidth: 0.5))
    }
}

extension View {
    func glassStyle(backgroundColor: Color = Color(hex: "0F0F0F"), opacity: Double = 0.74) -> some View {
        self.modifier(GlassCardModifier(backgroundColor: backgroundColor, opacity: opacity))
    }
}

// --- 4. 场景卡片 (带星星动效支持) ---
struct SceneCard: View {
    var title: String
    var imageName: String
    var height: CGFloat
    var titleAlignment: Alignment = .topLeading
    var opacity: Double
    var showMeteor: Bool = false
    var meteorDelay: Double = 0
    
    var body: some View {
        ZStack(alignment: titleAlignment) {
            // 星星动效层
            if showMeteor {
                StarMeteorView(delay: meteorDelay)
            }
            
            Image(imageName)
                .resizable()
                .scaledToFit()
                .padding(12)
            
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .padding(16)
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .glassStyle(opacity: opacity)
    }
}

// --- 5. 主页面 ---
struct ContentView: View {
    @State private var bannerAnimate = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 28) {
                    // Header
                    HStack {
                        Circle().stroke(Color.white.opacity(0.4), lineWidth: 1).frame(width: 34, height: 34).overlay(Text("logo").font(.system(size: 8)).foregroundColor(.white))
                        Text("Brand Name").font(.system(size: 20, weight: .bold)).foregroundColor(.white)
                        Spacer()
                        Image(systemName: "gift").foregroundColor(.white)
                        Image(systemName: "sparkles").padding(8).background(Circle().stroke(Color.white.opacity(0.4))).foregroundColor(.white)
                    }
                    .padding(.horizontal)

                    // 分享卡片：图片慢速旋转缩放
                    ZStack(alignment: .bottomLeading) {
                        Image("image_share")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .scaleEffect(bannerAnimate ? 1.5 : 1.0) // 缩放 1.5 倍
                            .rotationEffect(.degrees(bannerAnimate ? 15 : 0)) // 顺时针旋转
                            .animation(Animation.easeInOut(duration: 8.0).repeatForever(autoreverses: true), value: bannerAnimate)
                        
                        Text("分享并邀请")
                            .font(.system(size: 22, weight: .heavy))
                            .foregroundColor(.white)
                            .padding(.leading, 24)
                            .padding(.bottom, 24)
                    }
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 28)) // 裁剪溢出的图片
                    .glassStyle(opacity: 0.74)
                    .padding(.horizontal)
                    .onAppear { bannerAnimate = true }

                    // 场景区域
                    VStack(alignment: .leading, spacing: 18) {
                        HStack {
                            Text("场景").font(.system(size: 24, weight: .bold)).foregroundColor(.white)
                            Spacer()
                            Text("显示全部").foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                        
                        HStack(alignment: .top, spacing: 14) {
                            VStack(spacing: 14) {
                                // 专注：第一颗星星滑过
                                SceneCard(title: "专注", imageName: "focus", height: 210, opacity: 1.0, showMeteor: true, meteorDelay: 0)
                                SceneCard(title: "创造", imageName: "create", height: 120, titleAlignment: .bottomLeading, opacity: 1.0)
                            }
                            VStack(spacing: 14) {
                                SceneCard(title: "休息", imageName: "rest", height: 140, titleAlignment: .topTrailing, opacity: 1.0)
                                // 冥想：紧接着第二颗星星滑过 (延时 1 秒)
                                SceneCard(title: "冥想", imageName: "meditate", height: 190, titleAlignment: .bottomTrailing, opacity: 1.0, showMeteor: true, meteorDelay: 1.0)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top, 15)
                .padding(.bottom, 40)
            }
        }
    }
}
