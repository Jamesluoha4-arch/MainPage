import SwiftUI

// --- 1. 颜色扩展 (放在文件顶部或底部) ---
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

// --- 2. 玻璃质感修饰符 ---
struct GlassCardModifier: ViewModifier {
    var backgroundColor: Color
    var opacity: Double
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    backgroundColor.opacity(opacity)
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.white.opacity(0.15), location: 0),
                            .init(color: Color.clear, location: 0.6)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            )
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
            )
    }
}

extension View {
    func glassStyle(backgroundColor: Color = Color(hex: "0F0F0F"), opacity: Double = 0.74) -> some View {
        self.modifier(GlassCardModifier(backgroundColor: backgroundColor, opacity: opacity))
    }
}

// --- 3. 场景子组件 ---
struct SceneCard: View {
    var title: String
    var imageName: String
    var height: CGFloat
    var titleAlignment: Alignment = .topLeading
    var opacity: Double // 控制图三要求的透明度
    
    var body: some View {
        ZStack(alignment: titleAlignment) {
            // 占位图：如果你还没放入图片，它会显示一个灰色方块，不会报错
            Image(imageName)
                .resizable()
                .scaledToFit()
                .padding(20)
            
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .padding(15)
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .glassStyle(opacity: opacity)
    }
}

// --- 4. 主界面 ---
struct ContentView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // Header
                    HStack {
                        Circle()
                            .stroke(Color.white.opacity(0.5), lineWidth: 0.8)
                            .frame(width: 32, height: 32)
                            .overlay(Text("logo").font(.system(size: 8)).foregroundColor(.white))
                        
                        Text("Brand Name")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Image(systemName: "gift")
                            .foregroundColor(.white)
                        
                        Image(systemName: "sparkles")
                            .font(.system(size: 14))
                            .padding(8)
                            .background(Circle().stroke(Color.white.opacity(0.5)))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal)

                    // 分享邀请卡片 (参考图二：透明度 74%)
                    ZStack(alignment: .bottomLeading) {
                        Image("image_share") // 需在 Assets 中添加
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                        
                        Text("分享并邀请")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding(20)
                    }
                    .frame(height: 180)
                    .frame(maxWidth: .infinity)
                    .glassStyle(opacity: 0.74)
                    .padding(.horizontal)

                    // 场景区域
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("场景")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                            Text("显示全部")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                        
                        // 瀑布流/网格布局
                        HStack(alignment: .top, spacing: 12) {
                            VStack(spacing: 12) {
                                SceneCard(title: "专注", imageName: "focus", height: 200, opacity: 1.0)
                                SceneCard(title: "创造", imageName: "create", height: 110, opacity: 1.0)
                            }
                            VStack(spacing: 12) {
                                SceneCard(title: "休息", imageName: "rest", height: 130, titleAlignment: .topTrailing, opacity: 1.0)
                                SceneCard(title: "冥想", imageName: "meditate", height: 180, titleAlignment: .bottomTrailing, opacity: 1.0)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top, 10)
                .padding(.bottom, 30)
            }
        }
    }
}

// 预览
#Preview {
    ContentView()
}
