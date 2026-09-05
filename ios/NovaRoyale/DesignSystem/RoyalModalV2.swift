import SwiftUI

/// Profile / emblems style modal board with crown header + quilt body.
struct RoyalModalV2<Content: View>: View {
    var title: String
    var onClose: (() -> Void)?
    @ViewBuilder var content: () -> Content

    var body: some View {
        ZStack(alignment: .top) {
            RoyalPanelV2(kind: .blue, cornerRadius: RoyalDS.Radius.xl, padding: 0, rimWidth: 4) {
                VStack(spacing: 0) {
                    header
                    content()
                        .padding(.horizontal, RoyalDS.Space.md)
                        .padding(.bottom, RoyalDS.Space.lg)
                }
            }

            // Crown breaking the top edge
            crown
                .offset(y: -22)
        }
        .padding(.top, 22)
    }

    private var header: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 0)
                .fill(
                    LinearGradient(
                        colors: [RoyalDS.Color.panelBlue, RoyalDS.Color.panelBlueDeep],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 56)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(RoyalDS.Color.goldRim)
                        .frame(height: 3)
                        .shadow(color: RoyalDS.Color.gold.opacity(0.6), radius: 4)
                }

            RoyalText(text: title, size: 24, color: RoyalDS.Color.gold, strokeWidth: 1.8)

            if let onClose {
                HStack {
                    Spacer()
                    closeButton(onClose)
                        .padding(.trailing, 12)
                }
            }
        }
    }

    private func closeButton(_ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color(red: 0.55, green: 0.05, blue: 0.1))
                    .frame(width: 34, height: 34)
                    .offset(y: 3)
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [RoyalDS.Color.defeat, Color(red: 0.7, green: 0.1, blue: 0.15)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 34, height: 34)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.35), lineWidth: 1)
                    )
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .black))
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(RoyalPressStyle())
        .accessibilityLabel("Close")
    }

    private var crown: some View {
        ZStack {
            Circle()
                .fill(RoyalDS.Color.panelBlueDeep)
                .frame(width: 44, height: 44)
                .overlay(Circle().stroke(RoyalDS.Color.goldRim, lineWidth: 3))
                .shadow(color: RoyalDS.Color.gold.opacity(0.5), radius: 8)

            Image(systemName: "crown.fill")
                .font(.system(size: 20, weight: .black))
                .foregroundStyle(RoyalLighting.goldFace)
                .shadow(color: .black.opacity(0.4), radius: 2, y: 1)
        }
        .accessibilityHidden(true)
    }
}

/// Decorative gold divider with center crown stud.
struct RoyalDividerV2: View {
    var body: some View {
        HStack(spacing: 8) {
            line
            Image(systemName: "crown.fill")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(RoyalDS.Color.gold)
            line
        }
        .padding(.vertical, 6)
    }

    private var line: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [.clear, RoyalDS.Color.gold.opacity(0.85), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 2)
    }
}
