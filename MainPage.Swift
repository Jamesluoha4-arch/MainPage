import SwiftUI

// --- 1. 颜色扩展 (保持不变) ---
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

// --- 2. 虚化流星组件 (保持不变) ---
struct StarMeteorView: View {
    @State private var animate = false
    var delay: Double = 0
    var body: some View {
        GeometryReader { proxy in
            Circle()
                .fill(Color.white.opacity(0.6))
                .frame(width: 4, height: 4)
                .blur(radius: 2)
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
        .clipped()
    }
}

// --- 3. 声音气泡组件 (根据图三/图六参数定制) ---
struct SoundBubble: View {
    var title: String
    var body: some View {
        Text(title)
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.white)
            .frame(width: 100, height: 75) // 椭圆气泡形状
            .background(
                ZStack {
                    // 参考图六：0F0F0F 填充，74% 不透明度
                    Color(hex: "0F0F0F").opacity(0.74)
                    
                    // 渐变高光层
                    LinearGradient(stops: [
                        .init(color: .white.opacity(0.2), location: 0),
                        .init(color: .clear, location: 0.6)
                    ], startPoint: .topLeading, endPoint: .bottomTrailing)
                }
            )
            .cornerRadius(40) // 形成半圆边角
            .overlay(
                RoundedRectangle(cornerRadius: 40)
                    .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
            )
            .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 10)
    }
}

// --- 4. 玻璃质感修饰符 ---
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

// --- 5. 场景卡片 ---
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
            if showMeteor { StarMeteorView(delay: meteorDelay) }
            Image(imageName).resizable().scaledToFit().padding(12)
            Text(title).font(.system(size: 18, weight: .bold)).foregroundColor(.white).padding(16)
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .glassStyle(opacity: opacity)
    }
}

// --- 6. 主页面 (整合声音区块) ---
struct ContentView: View {
    @State private var bannerAnimate = false
    
    // 动态日期显示
    var currentDateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日"
        return formatter.string(from: Date())
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 40) { // 增加间距让布局更通透
                    
                    // --- 原有顶部区块 ---
                    VStack(spacing: 28) {
                        HStack {
                            Circle().stroke(Color.white.opacity(0.4), lineWidth: 1).frame(width: 34, height: 34).overlay(Text("logo").font(.system(size: 8)).foregroundColor(.white))
                            Text("Brand Name").font(.system(size: 20, weight: .bold)).foregroundColor(.white)
                            Spacer()
                            Image(systemName: "gift").foregroundColor(.white)
                            Image(systemName: "sparkles").padding(8).background(Circle().stroke(Color.white.opacity(0.4))).foregroundColor(.white)
                        }
                        .padding(.horizontal)

                        ZStack(alignment: .bottomLeading) {
                            Image("image_share")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .scaleEffect(bannerAnimate ? 1.5 : 1.0)
                                .rotationEffect(.degrees(bannerAnimate ? 15 : 0))
                                .animation(Animation.easeInOut(duration: 8.0).repeatForever(autoreverses: true), value: bannerAnimate)
                            Text("分享并邀请").font(.system(size: 22, weight: .heavy)).foregroundColor(.white).padding(.leading, 24).padding(.bottom, 30)
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
                                    SceneCard(title: "专注", imageName: "focus", height: 210, opacity: 1.0, showMeteor: true, meteorDelay: 0)
                                    SceneCard(title: "创造", imageName: "create", height: 120, titleAlignment: .bottomLeading, opacity: 1.0)
                                }
                                VStack(spacing: 14) {
                                    SceneCard(title: "休息", imageName: "rest", height: 100, titleAlignment: .topTrailing, opacity: 1.0)
                                    SceneCard(title: "冥想", imageName: "meditate", height: 190, titleAlignment: .bottomTrailing, opacity: 1.0, showMeteor: true, meteorDelay: 1.0)
                                }
                            }.padding(.horizontal)
                        }
                    }
                    
                    // --- 新增：“声音”区块 (参考图一/图五) ---
                    VStack(alignment: .leading, spacing: 25) {
                        Text("声音")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        ZStack(alignment: .topTrailing) {
                            // 背景流星装饰图 (请在 Assets 中放入该图，此处用系统图标示意)
                            Image(systemName: "sparkle") 
                                .font(.system(size: 100))
                                .foregroundColor(.white.opacity(0.1))
                                .offset(x: 20, y: -40)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Text("晚上好")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white.opacity(0.8))
                                
                                // 用户昵称框
                                Text("用户昵称")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 20)
                                    .glassStyle(opacity: 0.3) // 较浅的玻璃感
                                
                                Text("现在是\(currentDateText)夜间，一起开启好梦")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        // 声音选择气泡组
                        HStack(spacing: 15) {
                            SoundBubble(title: "白噪音")
                            
                            SoundBubble(title: "自然之声")
                                .offset(y: 45) // 还原设计稿的下沉排布
                            
                            SoundBubble(title: "节奏")
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                        
                        // 底部占位：用于显示图五右侧的波浪线条背景
                        Spacer(minLength: 120)
                    }
                }
                .padding(.top, 15)
                .padding(.bottom, 60)
            }
        }
    }
}
