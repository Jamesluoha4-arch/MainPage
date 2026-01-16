import SwiftUI

// MARK: - 1. 颜色工具扩展
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

// MARK: - 2. 动态流光组件 (Shimmer)
struct ShimmerEffect: View {
    @State private var phase: CGFloat = -1.0
    
    var body: some View {
        GeometryReader { geometry in
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: .clear, location: 0),
                    .init(color: .white.opacity(0.4), location: 0.5),
                    .init(color: .clear, location: 1)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .scaleEffect(2) 
            .rotationEffect(.degrees(30))
            .offset(x: phase * geometry.size.width)
            .onAppear {
                // 流光循环动画
                withAnimation(Animation.linear(duration: 3).repeatForever(autoreverses: false)) {
                    phase = 1.5
                }
            }
        }
    }
}

// MARK: - 3. 增强玻璃质感修饰符
struct GlassModifier: ViewModifier {
    var cornerRadius: CGFloat
    var opacity: Double
    var isButton: Bool
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    Color(hex: "0F0F0F").opacity(opacity)
                    
                    // 仅按钮显示内部流光
                    if isButton {
                        ShimmerEffect()
                            .mask(RoundedRectangle(cornerRadius: cornerRadius))
                    }
                    
                    // 玻璃反光渐变
                    LinearGradient(stops: [
                        .init(color: .white.opacity(0.15), location: 0),
                        .init(color: .clear, location: 0.6)
                    ], startPoint: .topLeading, endPoint: .bottomTrailing)
                }
            )
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    // 强化版白色描边：按钮 1.5pt，普通卡片 0.5pt
                    .stroke(Color.white.opacity(isButton ? 0.4 : 0.15), lineWidth: isButton ? 1.5 : 0.5)
            )
    }
}

extension View {
    func glassStyle(opacity: Double = 0.74, cornerRadius: CGFloat = 28, isButton: Bool = false) -> some View {
        self.modifier(GlassModifier(cornerRadius: cornerRadius, opacity: opacity, isButton: isButton))
    }
}

// MARK: - 4. 子组件：场景卡片 & 声音气泡
struct SceneCard: View {
    var title: String
    var imageName: String
    var height: CGFloat
    var titleAlignment: Alignment = .topLeading
    
    var body: some View {
        ZStack(alignment: titleAlignment) {
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
            .font(.system(size: 15, weight: .medium))
            .foregroundColor(.white)
            .frame(width: 95, height: 70)
            .glassStyle(opacity: 0.8, cornerRadius: 35, isButton: true)
            .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 10)
    }
}

// MARK: - 5. 主页面
struct ContentView: View {
    @State private var bannerAnimate = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 40) {
                    
                    // --- 第一部分：顶部导航与场景 ---
                    VStack(spacing: 28) {
                        HStack {
                            Circle().stroke(Color.white.opacity(0.4)).frame(width: 34).overlay(Text("logo").font(.system(size: 8)).foregroundColor(.white))
                            Text("Brand Name").font(.system(size: 20, weight: .bold)).foregroundColor(.white)
                            Spacer()
                            Image(systemName: "gift").foregroundColor(.white)
                            Image(systemName: "sparkles").padding(8).background(Circle().stroke(Color.white.opacity(0.4))).foregroundColor(.white)
                        }.padding(.horizontal)

                        ZStack(alignment: .bottomLeading) {
                            Image("image_share").resizable().aspectRatio(contentMode: .fill)
                                .scaleEffect(bannerAnimate ? 1.5 : 1.0)
                                .rotationEffect(.degrees(bannerAnimate ? 15 : 0))
                                .animation(Animation.easeInOut(duration: 8.0).repeatForever(autoreverses: true), value: bannerAnimate)
                            Text("分享并邀请").font(.system(size: 22, weight: .heavy)).foregroundColor(.white).padding(24)
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
                    
                    // --- 第二部分：“声音”区块 (斜向排列 + 流光) ---
                    VStack(alignment: .leading, spacing: 0) {
                        Text("声音")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        // 标题下方的留白
                        Spacer().frame(height: 35)
                        
                        ZStack(alignment: .topTrailing) {
                            // 1. 底层：人脸线条背景 (位置偏移调整)
                            Image("face_lines")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 320)
                                .opacity(0.5)
                                .offset(x: 60, y: 120)
                            
                            // 2. 中层：流星图片 (使用 scaledToFit 解决压扁问题)
                            Image("image_shooting_star")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 135)
                                .offset(x: -20, y: -20)
                            
                            // 3. 上层：文字与斜向排布按钮
                            VStack(alignment: .leading, spacing: 25) {
                                // 问候语组
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("晚上好").font(.system(size: 18)).foregroundColor(.white.opacity(0.8))
                                    Text("用户昵称")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(.vertical, 8).padding(.horizontal, 22)
                                        .glassStyle(opacity: 0.3, cornerRadius: 15)
                                    Text("现在是夜间，一起开启好梦").font(.system(size: 14)).foregroundColor(.gray)
                                }
                                
                                // 45度斜向排布逻辑
                                ZStack(alignment: .topLeading) {
                                    SoundBubble(title: "白噪音")
                                        .offset(x: 0, y: 0)
                                    
                                    SoundBubble(title: "自然之声")
                                        .offset(x: 75, y: 75) // 递增偏移实现斜向
                                    
                                    SoundBubble(title: "节奏")
                                        .offset(x: 150, y: 150)
                                }
                                .padding(.top, 20)
                                .padding(.bottom, 160) // 确保斜向排布不被裁切
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.top, 15)
                .padding(.bottom, 60)
            }
        }
    }
}
