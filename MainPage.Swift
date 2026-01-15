import SwiftUI

// MARK: - Main View
struct IPhone16ProMax2: View {

    // ✅ 抽出重复背景，降低泛型复杂度（解决 type-check 超时的关键之一）
    private let cardBG = LinearGradient(
        gradient: Gradient(colors: [Color(hex: "#FFFFFF12"), Color(hex: "#4B4B4B12")]),
        startPoint: .top,
        endPoint: .bottom
    )

    private let heroBG = LinearGradient(
        gradient: Gradient(colors: [Color(hex: "#FFFFFF66"), Color(hex: "#00000012")]),
        startPoint: .top,
        endPoint: .bottom
    )

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    HeaderBarView()

                    InviteBannerView(heroBG: heroBG)

                    SceneSectionView(cardBG: cardBG)

                    NowPlayingSectionView(cardBG: cardBG)
                }
                .padding(.bottom, 24)
            }
        }
    }
}

// MARK: - Header
private struct HeaderBarView: View {
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 0) {
                // logo chip
                Text("logo")
                    .foregroundColor(Color(hex: "#D9D9D9"))
                    .font(.system(size: 8))
                    .padding(.vertical, 10)
                    .padding(.horizontal, 7)
                    .background(
                        URLImageView(url: "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/PAN0XomBrb/k76s37wx_expires_30_days.png")
                    )
                    .padding(.trailing, 20)

                Text("Brand Name")
                    .foregroundColor(Color(hex: "#D9D9D9"))
                    .font(.system(size: 19))

                Spacer()

                URLImageView(url: "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/PAN0XomBrb/jlxhyzia_expires_30_days.png")
                    .frame(width: 27, height: 27)
                    .padding(.trailing, 24)

                Text("AI助手")
                    .foregroundColor(Color(hex: "#D9D9D9"))
                    .font(.system(size: 8))
                    .padding(.vertical, 10)
                    .padding(.horizontal, 4)
                    .background(
                        URLImageView(url: "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/PAN0XomBrb/5bp2o9zl_expires_30_days.png")
                    )
            }
            .frame(height: 27)
            .frame(maxWidth: .infinity)
            .background(Color.black)
        }
        .padding(.top, 59)
        .padding(.horizontal, 24)
        .padding(.bottom, 15)
        .background(Color.black)
    }
}

// MARK: - Invite Banner
private struct InviteBannerView: View {
    let heroBG: LinearGradient

    var body: some View {
        VStack(alignment: .leading) {
            Text("分享并邀请")
                .foregroundColor(.white)
                .font(.system(size: 19))
                .fontWeight(.bold)
                .padding(.bottom, 14)
        }
        .padding(.top, 191)
        .padding(.leading, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(heroBG)
        .padding(.horizontal, 25)
        .padding(.bottom, 36)
        .overlay(
            Rectangle()
                .fill(Color.black)
                .frame(height: 27),
            alignment: .bottom
        )
    }
}

// MARK: - Scene Section
private struct SceneSectionView: View {
    let cardBG: LinearGradient

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("场景")
                    .foregroundColor(Color(hex: "#D9D9D9"))
                    .font(.system(size: 25))
                    .fontWeight(.bold)

                Spacer()

                Text("显示全部")
                    .foregroundColor(Color(hex: "#D9D9D9"))
                    .font(.system(size: 12))
            }
            .padding(.horizontal, 31)
            .padding(.bottom, 26)

            HStack(spacing: 35) {
                // Left column
                VStack(alignment: .leading, spacing: 34) {
                    SceneBigCard(
                        title: "专注",
                        titleAlignment: .leading,
                        titlePadding: EdgeInsets(top: 0, leading: 23, bottom: 0, trailing: 0),
                        imageURL: "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/PAN0XomBrb/07mwkwxg_expires_30_days.png",
                        imageSize: CGSize(width: 166, height: 185),
                        cardBG: cardBG
                    )

                    SceneSmallCard(
                        title: "创造",
                        titleAlignment: .leading,
                        titlePadding: EdgeInsets(top: 0, leading: 19, bottom: 8, trailing: 0),
                        imageURL: "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/PAN0XomBrb/04pfgv76_expires_30_days.png",
                        imageSize: CGSize(width: 146, height: 99),
                        imagePaddingLeading: 19,
                        cardBG: cardBG
                    )
                }

                // Right column
                VStack(alignment: .leading, spacing: 33) {
                    SceneBigCard(
                        title: "休息",
                        titleAlignment: .trailing,
                        titlePadding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 26),
                        imageURL: "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/PAN0XomBrb/eess6dzf_expires_30_days.png",
                        imageSize: CGSize(width: 171, height: 87),
                        cardBG: cardBG
                    )

                    SceneBigCard(
                        title: "冥想",
                        titleAlignment: .trailing,
                        titlePadding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 26),
                        imageURL: "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/PAN0XomBrb/jxu2ogpb_expires_30_days.png",
                        imageSize: CGSize(width: 139, height: 173),
                        imagePaddingLeading: 23,
                        cardBG: cardBG,
                        titleBelowImage: true
                    )
                }
            }
            .padding(.horizontal, 34)
            .padding(.bottom, 16)
        }
    }
}

private struct SceneBigCard: View {
    let title: String
    let titleAlignment: HorizontalAlignment
    let titlePadding: EdgeInsets
    let imageURL: String
    let imageSize: CGSize
    let imagePaddingLeading: CGFloat
    let cardBG: LinearGradient
    let titleBelowImage: Bool

    init(
        title: String,
        titleAlignment: HorizontalAlignment,
        titlePadding: EdgeInsets,
        imageURL: String,
        imageSize: CGSize,
        imagePaddingLeading: CGFloat = 0,
        cardBG: LinearGradient,
        titleBelowImage: Bool = false
    ) {
        self.title = title
        self.titleAlignment = titleAlignment
        self.titlePadding = titlePadding
        self.imageURL = imageURL
        self.imageSize = imageSize
        self.imagePaddingLeading = imagePaddingLeading
        self.cardBG = cardBG
        self.titleBelowImage = titleBelowImage
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if !titleBelowImage {
                titleRow
            }

            URLImageView(url: imageURL)
                .frame(width: imageSize.width, height: imageSize.height)
                .clipShape(RoundedRectangle(cornerRadius: 31, style: .continuous))
                .padding(.leading, imagePaddingLeading)

            if titleBelowImage {
                titleRow
                    .padding(.top, 6)
            }
        }
        .padding(.top, 15)
        .padding(.bottom, 2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBG)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var titleRow: some View {
        HStack {
            if titleAlignment == .trailing { Spacer() }
            Text(title)
                .foregroundColor(Color(hex: "#D9D9D9"))
                .font(.system(size: 15))
                .fontWeight(.bold)
                .padding(titlePadding)
            if titleAlignment == .leading { Spacer() }
        }
    }
}

private struct SceneSmallCard: View {
    let title: String
    let titleAlignment: HorizontalAlignment
    let titlePadding: EdgeInsets
    let imageURL: String
    let imageSize: CGSize
    let imagePaddingLeading: CGFloat
    let cardBG: LinearGradient

    init(
        title: String,
        titleAlignment: HorizontalAlignment,
        titlePadding: EdgeInsets,
        imageURL: String,
        imageSize: CGSize,
        imagePaddingLeading: CGFloat,
        cardBG: LinearGradient
    ) {
        self.title = title
        self.titleAlignment = titleAlignment
        self.titlePadding = titlePadding
        self.imageURL = imageURL
        self.imageSize = imageSize
        self.imagePaddingLeading = imagePaddingLeading
        self.cardBG = cardBG
    }

    var body: some View {
        VStack(alignment: .leading) {
            URLImageView(url: imageURL)
                .frame(width: imageSize.width, height: imageSize.height)
                .clipShape(RoundedRectangle(cornerRadius: 31, style: .continuous))
        }
        .padding(.vertical, 9)
        .padding(.leading, imagePaddingLeading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBG)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            Text(title)
                .foregroundColor(Color(hex: "#D9D9D9"))
                .font(.system(size: 15))
                .fontWeight(.bold)
                .padding(titlePadding),
            alignment: .bottomLeading
        )
    }
}

// MARK: - Now Playing Section
private struct NowPlayingSectionView: View {
    let cardBG: LinearGradient

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 0) {
                NowPlayingRow(cardBG: cardBG)

                Text("晚上好")
                    .foregroundColor(.white)
                    .font(.system(size: 15))
                    .padding(.bottom, 74)
                    .padding(.leading, 8)

                // 下面这块原来非常复杂，我保持结构接近，但用一个独立 View 包起来减压
                HeroCardsBlock(cardBG: cardBG)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(HeroOverlayView(), alignment: .topLeading)
        .padding(.leading, 27)
    }
}

private struct NowPlayingRow: View {
    let cardBG: LinearGradient

    var body: some View {
        HStack(spacing: 0) {
            URLImageView(url: "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/PAN0XomBrb/jqifzifd_expires_30_days.png")
                .frame(width: 69, height: 69)
                .clipShape(RoundedRectangle(cornerRadius: 31, style: .continuous))
                .overlay(
                    Text("声音")
                        .foregroundColor(Color(hex: "#D9D9D9"))
                        .font(.system(size: 25))
                        .fontWeight(.bold)
                        .padding(.bottom, 4)
                        .padding(.leading, -15),
                    alignment: .bottomLeading
                )
                .padding(.leading, 19)
                .padding(.trailing, 6)

            VStack(alignment: .leading, spacing: 7) {
                Text("正在播放")
                    .foregroundColor(Color(hex: "#B6B6B6"))
                    .font(.system(size: 10))
                Text("白噪音")
                    .foregroundColor(.white)
                    .font(.system(size: 14))
            }

            Spacer()
        }
        .padding(.vertical, 3)
        .frame(maxWidth: .infinity)
        .background(cardBG)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.bottom, 27)
        .padding(.trailing, 28)
    }
}

private struct HeroCardsBlock: View {
    let cardBG: LinearGradient

    var body: some View {
        VStack(alignment: .trailing) {
            // 这一段你原来用大量 padding/overlay 叠出来的效果，我保持组件化，
            // 你后续要微调布局会更轻松
            ZStack(alignment: .topLeading) {

                // 背景大图（原来的 background）
                URLImageView(url: "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/PAN0XomBrb/t0krw9de_expires_30_days.png")
                    .frame(maxWidth: .infinity)
                    .frame(height: 360)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                // 顶部条形图层
                URLImageView(url: "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/PAN0XomBrb/kxfmlxf2_expires_30_days.png")
                    .frame(width: 96, height: 28)
                    .padding(.top, 3)
                    .padding(.leading, 64)

                // 白噪音卡片（左上叠层）
                Text("白噪音")
                    .foregroundColor(Color(hex: "#D9D9D9"))
                    .font(.system(size: 15))
                    .fontWeight(.bold)
                    .padding(.vertical, 22)
                    .padding(.horizontal, 25)
                    .background(cardBG)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(.top, 196)
                    .padding(.leading, 0)

                // 节奏卡片（左下叠层）
                Text("节奏")
                    .foregroundColor(Color(hex: "#D9D9D9"))
                    .font(.system(size: 15))
                    .fontWeight(.bold)
                    .padding(.vertical, 22)
                    .padding(.horizontal, 28)
                    .background(cardBG)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(.top, 280)
                    .padding(.leading, 0)

                // 自然之声卡片（右侧）
                Text("自然之声")
                    .foregroundColor(Color(hex: "#D9D9D9"))
                    .font(.system(size: 15))
                    .fontWeight(.bold)
                    .padding(.vertical, 22)
                    .padding(.horizontal, 19)
                    .background(cardBG)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(.top, 127)
                    .padding(.leading, 38)
            }
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

// MARK: - Overlays (User name + text + top-right image)
private struct HeroOverlayView: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            Text("用户昵称")
                .foregroundColor(.white)
                .font(.system(size: 20))
                .fontWeight(.bold)
                .padding(.vertical, 15)
                .padding(.horizontal, 29)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "#FFFFFF12"), Color(hex: "#4B4B4B12")]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.top, 132)
                .padding(.leading, 7)

            Text("现在是2026年1月14日夜间，一起开启好梦")
                .foregroundColor(.white)
                .font(.system(size: 15))
                .padding(.top, 211)
                .padding(.leading, 11)

            HStack {
                Spacer()
                URLImageView(url: "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/PAN0XomBrb/2r046d0l_expires_30_days.png")
                    .frame(width: 238, height: 236)
                    .padding(.top, 10)
                    .padding(.trailing, 46)
            }
        }
    }
}

// MARK: - URL Image View (解决“链接图像加载不到”的主力组件)
struct URLImageView: View {
    let url: String

    var body: some View {
        // ✅ URL 解析失败直接 fallback（避免空白/崩溃）
        if let u = URL(string: url) {
            AsyncImage(url: u, transaction: Transaction(animation: .default)) { phase in
                switch phase {
                case .empty:
                    placeholder
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    failed
                @unknown default:
                    failed
                }
            }
            .clipped()
        } else {
            failed
        }
    }

    private var placeholder: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(Color.white.opacity(0.08))
            .overlay(
                ProgressView().scaleEffect(0.8),
                alignment: .center
            )
    }

    private var failed: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(Color.white.opacity(0.06))
            .overlay(
                Image(systemName: "photo")
                    .foregroundColor(.white.opacity(0.35)),
                alignment: .center
            )
    }
}

// MARK: - Color(hex:)
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let a, r, g, b: UInt64
        switch hex.count {
        case 6: // RRGGBB
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8: // AARRGGBB
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 255, 255, 255)
        }

        self.init(.sRGB,
                  red: Double(r) / 255.0,
                  green: Double(g) / 255.0,
                  blue: Double(b) / 255.0,
                  opacity: Double(a) / 255.0)
    }
}
