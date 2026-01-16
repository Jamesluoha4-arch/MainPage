import SwiftUI

// --- [此处省略之前的 Color 扩展、StarMeteorView、GlassCardModifier 和 SceneCard，保持不变] ---

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
                    
                    // --- 顶部原有区块 (分享+场景) ---
                    topSection
                    
                    // --- “声音”区块 (严格还原排版) ---
                    VStack(alignment: .leading, spacing: 0) {
                        Text("声音")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        ZStack(alignment: .topTrailing) {
                            
                            // 1. 底层人脸线条背景 (严格贴靠右侧排版)
                            Image("face_lines") // 请确保 Assets 中有此命名
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 300) // 根据屏幕比例调整
                                .opacity(0.8)
                                .offset(x: 40, y: 100) // 调整至图五所示的偏右下位置
                            
                            // 2. 流星图片 (替换之前的系统图标)
                            Image("image_shooting_star") // 请确保 Assets 中有此命名
                                .resizable()
                                .frame(width: 150, height: 60)
                                .offset(x: -10, y: -20)
                            
                            // 3. 文字内容层
                            VStack(alignment: .leading, spacing: 12) {
                                Text("晚上好")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white.opacity(0.8))
                                
                                Text("用户昵称")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 22)
                                    .glassStyle(opacity: 0.4)
                                
                                Text("现在是\(currentDateText)夜间，一起开启好梦")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                    .padding(.top, 5)
                                
                                // 4. 声音选择气泡组 (位于文字下方，且在人脸线条之上)
                                HStack(spacing: 15) {
                                    SoundBubble(title: "白噪音")
                                    
                                    SoundBubble(title: "自然之声")
                                        .offset(y: 45) // 还原错位排布
                                    
                                    SoundBubble(title: "节奏")
                                }
                                .padding(.top, 40)
                            }
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(.top, 20)
                }
                .padding(.bottom, 100)
            }
        }
    }
    
    // 将顶部复杂的 View 抽离，保持 body 整洁
    var topSection: some View {
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

            // 场景
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
    }
}

// 保持 SoundBubble 定义
struct SoundBubble: View {
    var title: String
    var body: some View {
        Text(title)
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.white)
            .frame(width: 100, height: 75)
            .background(
                ZStack {
                    Color(hex: "0F0F0F").opacity(0.74)
                    LinearGradient(stops: [.init(color: .white.opacity(0.2), location: 0), .init(color: .clear, location: 0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)
                }
            )
            .cornerRadius(40)
            .overlay(RoundedRectangle(cornerRadius: 40).stroke(Color.white.opacity(0.15), lineWidth: 0.5))
            .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 10)
    }
}
