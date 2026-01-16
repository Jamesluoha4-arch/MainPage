import SwiftUI

struct ContentView: View {
    @State private var bannerAnimate = false
    @State private var soundSectionOpacity: Double = 0
    
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
                    // 第一部分：顶部导航与场景
                    headerAndScenesSection

                    // 第二部分：“声音”区块
                    VStack(alignment: .leading, spacing: 0) {
                        Text("声音")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        Spacer().frame(height: 35)
                        
                        GeometryReader { proxy in
                            let minY = proxy.frame(in: .global).minY
                            
                            ZStack(alignment: .topTrailing) {
                                Image("face_lines")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 320)
                                    .opacity(0.6)
                                    .offset(x: 60, y: 100)
                                
                                Image("image_shooting_star")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 140)
                                    .offset(x: -15, y: -20)
                                
                                VStack(alignment: .leading, spacing: 20) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("晚上好").font(.system(size: 18)).foregroundColor(.white.opacity(0.8))
                                        Text("用户昵称")
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(.white)
                                            .padding(.vertical, 8).padding(.horizontal, 20)
                                            .glassStyle(opacity: 0.3, cornerRadius: 12)
                                        Text("现在是\(currentDateText)夜间，一起开启好梦").font(.system(size: 14)).foregroundColor(.gray)
                                    }
                                    
                                    HStack(spacing: 12) {
                                        SoundBubble(title: "白噪音").offset(y: 20)
                                        SoundBubble(title: "自然之声").offset(y: 120).offset(x: 40)
                                        SoundBubble(title: "节奏").offset(y: 220).offset(x: -200)
                                    }
                                    .padding(.top, 25)
                                }
                                .padding(.horizontal)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .opacity(soundSectionOpacity)
                            .onChange(of: minY) { newValue in
                                if newValue < UIScreen.main.bounds.height * 0.85 {
                                    withAnimation(.easeIn(duration: 0.8)) {
                                        soundSectionOpacity = 1.0
                                    }
                                }
                            }
                        }
                        .frame(height: 400)
                    }
                    .padding(.top, 20)
                }
                .padding(.bottom, 120)
            }
        }
    }
    
    private var headerAndScenesSection: some View {
        VStack(spacing: 28) {
            HStack {
                Circle().stroke(Color.white.opacity(0.4), lineWidth: 1).frame(width: 34, height: 34).overlay(Text("logo").font(.system(size: 8)).foregroundColor(.white))
                Text("Brand Name").font(.system(size: 20, weight: .bold)).foregroundColor(.white)
                Spacer()
                Image(systemName: "gift").foregroundColor(.white)
                Image(systemName: "sparkles").padding(8).background(Circle().stroke(Color.white.opacity(0.4))).foregroundColor(.white)
            }.padding(.horizontal)

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
    }
}

// 子组件
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
        Text(title).font(.system(size: 15, weight: .medium)).foregroundColor(.white)
            .frame(width: 100, height: 75)
            .glassStyle(opacity: 0.74, cornerRadius: 40, showBorder: true, addFloatingEffect: true)
    }
}
