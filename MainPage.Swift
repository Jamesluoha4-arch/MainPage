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

// MARK: - 2. 动画组件：虚化流星 (用于场景卡片内)
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

// MARK: - 3. 玻璃质感修饰符
struct GlassModifier: ViewModifier {
    var cornerRadius: CGFloat
    var backgroundColor: Color = Color(hex: "0F0F0F")
    var opacity: Double
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    backgroundColor.opacity(opacity)
                    LinearGradient(stops: [
                        .init(color: .white.opacity(0.12), location: 0),
                        .init(color: .clear, location: 0.5)
                    ], startPoint: .topLeading, endPoint: .bottomTrailing)
                }
            )
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
            )
    }
}

extension View {
    func glassStyle(opacity: Double = 0.74, cornerRadius: CGFloat = 28) -> some View {
        self.modifier(GlassModifier(cornerRadius: cornerRadius, opacity: opacity))
    }
}

// MARK: - 4. 核心子组件
struct SceneCard: View {
    var title: String
    var imageName: String
    var height: CGFloat
    var titleAlignment: Alignment = .topLeading
    var showMeteor: Bool = false
    var meteorDelay: Double = 0
    
    var body: some View {
        ZStack(alignment: titleAlignment) {
            if showMeteor { StarMeteorView(delay: meteorDelay) }
            Image(imageName).resizable().scaledToFit().padding(12)
            Text(title).font(.system(size: 18, weight: .bold)).foregroundColor(.white).padding(16)
        }
        .frame(maxWidth: .infinity).frame(height: height)
        .glassStyle(opacity: 1.0)
    }
}

struct SoundBubble: View {
    var title: String
    var body: some View {
        Text(title)
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.white)
            .frame(width: 100, height: 75)
            .glassStyle(opacity: 0.74, cornerRadius: 40) // 图六: 0F0F0F 74%
            .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 10)
    }
}

// MARK: - 5. 主界面
struct ContentView: View {
    @State private var bannerAnimate = false
    
    var currentDateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日"
        return formatter.string(from: Date())
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 40) {
                    
                    // --- 第一部分：顶部导航与场景 ---
                    VStack(spacing: 28) {
                        // Header
                        HStack {
                            Circle().stroke(Color.white.opacity(0.4), lineWidth: 1).frame(width: 34, height: 34).overlay(Text("logo").font(.system(size: 8)).foregroundColor(.white))
                            Text("Brand Name").font(.system(size: 20, weight: .bold)).foregroundColor(.white)
                            Spacer()
                            Image(systemName: "gift").foregroundColor(.white)
                            Image(systemName: "sparkles").padding(8).background(Circle().stroke(Color.white.opacity(0.4))).foregroundColor(.white)
                        }.padding(.horizontal)

                        // 分享卡片
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

                        // 场景区
                        VStack(alignment: .leading, spacing: 18) {
                            HStack {
                                Text("场景").font(.system(size: 24, weight: .bold)).foregroundColor(.white)
                                Spacer()
                                Text("显示全部").foregroundColor(.gray)
                            }.padding(.horizontal)
                            
                            HStack(alignment: .top, spacing: 14) {
                                VStack(spacing: 14) {
                                    SceneCard(title: "专注", imageName: "focus", height: 210, showMeteor: true)
                                    SceneCard(title: "创造", imageName: "create", height: 120, titleAlignment: .bottomLeading)
                                }
                                VStack(spacing: 14) {
                                    SceneCard(title: "休息", imageName: "rest", height: 100, titleAlignment: .topTrailing)
                                    SceneCard(title: "冥想", imageName: "meditate", height: 190, titleAlignment: .bottomTrailing, showMeteor: true, meteorDelay: 1.0)
                                }
                            }.padding(.horizontal)
                        }
                    }
                    
                    // --- 第二部分：“声音”区块 (严格排版) ---
                    VStack(alignment: .leading, spacing: 0) {
                        Text("声音")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        ZStack(alignment: .topTrailing) {
                            // 1. 底层：人脸线条背景 (位置微调还原图五)
                            Image("face_lines")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 320)
                                .opacity(0.7)
                                .offset(x: 50, y: 80)
                            
                            // 2. 中层：流星图片 (替换之前的图标)
                            Image("image_shooting_star")
                                .resizable()
                                .frame(width: 160, height: 70)
                                .offset(x: -10, y: -25)
                            
                            // 3. 上层：文字与声音按钮
                            VStack(alignment: .leading, spacing: 15) {
                                Text("晚上好")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white.opacity(0.8))
                                
                                Text("用户昵称")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 22)
                                    .glassStyle(opacity: 0.4, cornerRadius: 16)
                                
                                Text("现在是\(currentDateText)夜间，一起开启好梦")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                
                                // 声音气泡组
                                HStack(spacing: 15) {
                                    SoundBubble(title: "白噪音")
                                    SoundBubble(title: "自然之声").offset(y: 45)
                                    SoundBubble(title: "节奏")
                                }
                                .padding(.top, 35)
                            }
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(.top, 20)
                }
                .padding(.bottom, 120) // 留出下滑后的空间
            }
        }
    }
}
