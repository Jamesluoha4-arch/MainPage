import SwiftUI

struct GlassCardModifier: ViewModifier {
    var backgroundColor: Color = Color(hex: "0F0F0F")
    var opacity: Double = 0.74
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // 基础深色背景
                    backgroundColor.opacity(opacity)
                    
                    // 模拟 Figma 中的 Linear Gradient 叠加
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.white.opacity(0.1), location: 0),
                            .init(color: Color.clear, location: 0.62)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            )
            // 玻璃边框
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
            )
            .cornerRadius(24)
            // 外阴影
            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 10)
    }
}

// 方便调用的扩展
extension View {
    func glassStyle(opacity: Double = 0.74) -> some View {
        self.modifier(GlassCardModifier(opacity: opacity))
    }
}

struct SoundHealingHomeView: View {
    var body: some View {
        ZStack {
            // 背景色
            Color.black.ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 25) {
                    
                    // --- 1. Navigation Bar ---
                    HStack {
                        Circle()
                            .stroke(Color.gray, lineWidth: 1)
                            .frame(width: 36, height: 36)
                            .overlay(Text("logo").font(.system(size: 8)))
                        
                        Text("Brand Name")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Image(systemName: "gift.fill") // 礼包图标
                            .foregroundColor(.white)
                        
                        Image(systemName: "sparkles") // AI 助手图标
                            .padding(8)
                            .background(Circle().stroke(Color.gray, lineWidth: 1))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal)

                    // --- 2. Share Banner (图二效果) ---
                    ZStack(alignment: .bottomLeading) {
                        Image("space_illustration") // 请确保 Asset 中有此图
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                        
                        Text("分享并邀请")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .padding()
                    }
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .glassStyle(opacity: 0.74) // 参考图二：透明度较高
                    .padding(.horizontal)

                    // --- 3. Scenes Section (图三效果) ---
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Text("场景")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Spacer()
                            Text("显示全部")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                        
                        // 使用网格布局
                        HStack(alignment: .top, spacing: 12) {
                            // 左侧列
                            VStack(spacing: 12) {
                                SceneCard(title: "专注", imageName: "focus_img", height: 180)
                                SceneCard(title: "创造", imageName: "create_img", height: 100)
                            }
                            // 右侧列
                            VStack(spacing: 12) {
                                SceneCard(title: "休息", imageName: "rest_img", height: 120, titleAlignment: .topTrailing)
                                SceneCard(title: "冥想", imageName: "meditate_img", height: 160, titleAlignment: .bottomTrailing)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 30)
            }
        }
    }
}

// 场景卡片子组件
struct SceneCard: View {
    var title: String
    var imageName: String
    var height: CGFloat
    var titleAlignment: Alignment = .topLeading
    
    var body: some View {
        ZStack(alignment: titleAlignment) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .padding(20)
            
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.white)
                .padding(12)
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .glassStyle(opacity: 1.0) // 参考图三：Fill 为 100% OFOFOF
    }
}

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
