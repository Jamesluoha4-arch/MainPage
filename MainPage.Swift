import SwiftUI

// --- 颜色与样式保持不变 ---
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
                            .init(color: Color.white.opacity(0.12), location: 0),
                            .init(color: Color.clear, location: 0.5)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            )
            .cornerRadius(28) // 稍微圆润一点
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
            )
    }
}

extension View {
    func glassStyle(backgroundColor: Color = Color(hex: "0F0F0F"), opacity: Double = 0.74) -> some View {
        self.modifier(GlassCardModifier(backgroundColor: backgroundColor, opacity: opacity))
    }
}

// --- 改进后的场景卡片 ---
struct SceneCard: View {
    var title: String
    var imageName: String
    var height: CGFloat
    var titleAlignment: Alignment = .topLeading
    var opacity: Double
    
    var body: some View {
        ZStack(alignment: titleAlignment) {
            // 内置图片：通过调小 padding 来让图片看起来更大
            Image(imageName)
                .resizable()
                .scaledToFit()
                .padding(12) // 从之前的 20 减小到 12，图片会显得更大
            
            // 场景文字：放大到 18，增加粗细
            Text(title)
                .font(.system(size: 18, weight: .bold)) 
                .foregroundColor(.white)
                .padding(16) // 控制文字离边框的距离
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .glassStyle(opacity: opacity)
    }
}

// --- 主页面 ---
struct ContentView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 28) {
                    
                    // Header (保持原样)
                    HStack {
                        Circle()
                            .stroke(Color.white.opacity(0.4), lineWidth: 1)
                            .frame(width: 34, height: 34)
                            .overlay(Text("logo").font(.system(size: 8)).foregroundColor(.white))
                        
                        Text("Brand Name")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Image(systemName: "gift").foregroundColor(.white)
                        Image(systemName: "sparkles")
                            .padding(8)
                            .background(Circle().stroke(Color.white.opacity(0.4)))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal)

                    // 分享邀请卡片：解决文字过低问题
                    ZStack(alignment: .bottomLeading) {
                        Image("image_share")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                        
                        Text("分享并邀请")
                            .font(.system(size: 22, weight: .heavy))
                            .foregroundColor(.white)
                            .padding(.leading, 24)
                            .padding(.bottom, 24) // 增加底部边距，防止文字被挡住
                    }
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .glassStyle(opacity: 0.74)
                    .padding(.horizontal)

                    // 场景区域
                    VStack(alignment: .leading, spacing: 18) {
                        HStack {
                            Text("场景")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                            Text("显示全部").foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                        
                        HStack(alignment: .top, spacing: 14) {
                            // 左列
                            VStack(spacing: 14) {
                                SceneCard(title: "专注", imageName: "focus", height: 210, opacity: 1.0)
                                // 创造：改为左下角对齐 (.bottomLeading)
                                SceneCard(title: "创造", imageName: "create", height: 120, titleAlignment: .bottomLeading, opacity: 1.0)
                            }
                            // 右列
                            VStack(spacing: 14) {
                                SceneCard(title: "休息", imageName: "rest", height: 140, titleAlignment: .topTrailing, opacity: 1.0)
                                SceneCard(title: "冥想", imageName: "meditate", height: 190, titleAlignment: .bottomTrailing, opacity: 1.0)
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
