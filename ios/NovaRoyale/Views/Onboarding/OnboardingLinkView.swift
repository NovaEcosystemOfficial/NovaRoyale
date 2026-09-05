import SwiftUI

struct OnboardingLinkView: View {
    @Environment(SessionController.self) private var session
    @Environment(AppLanguage.self) private var language
    @State private var tagInput = ""
    @State private var isSubmitting = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            RoyalBackgroundV2()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    VStack(alignment: .leading, spacing: 8) {
                        RoyalText(text: L10n.t("app.name", language), size: 34, color: RoyalDS.Color.gold, strokeWidth: 2)
                        Text(L10n.t("onboarding.subtitle", language))
                            .font(RoyalFont.ui(14, weight: .semibold))
                            .foregroundStyle(RoyalDS.Color.cyan)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    RoyalPanelV2(kind: .gold, cornerRadius: RoyalDS.Radius.xl, padding: 18) {
                        VStack(alignment: .leading, spacing: 14) {
                            RoyalText(text: L10n.t("onboarding.title", language), size: 22, color: RoyalDS.Color.gold)
                            Text(L10n.t("onboarding.body", language))
                                .font(RoyalFont.ui(13, weight: .semibold))
                                .foregroundStyle(RoyalDS.Color.textMuted)

                            HStack(spacing: 8) {
                                Text("#")
                                    .font(RoyalFont.display(28))
                                    .foregroundStyle(RoyalDS.Color.gold)
                                TextField(L10n.t("onboarding.placeholder", language), text: $tagInput)
                                    .textInputAutocapitalization(.characters)
                                    .autocorrectionDisabled()
                                    .font(RoyalFont.ui(18, weight: .bold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 12)
                                    .background {
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .fill(Color.black.opacity(0.35))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                            )
                                    }
                            }

                            if let errorMessage {
                                Text(errorMessage)
                                    .font(RoyalFont.ui(12, weight: .bold))
                                    .foregroundStyle(RoyalDS.Color.defeat)
                            }

                            RoyalButtonV2(
                                title: isSubmitting
                                    ? L10n.t("common.loading", language)
                                    : L10n.t("onboarding.cta", language),
                                symbol: "link",
                                kind: .battle,
                                height: 56
                            ) {
                                Task { await submit() }
                            }
                            .disabled(isSubmitting || normalizedTag.count < 3)
                            .opacity(isSubmitting || normalizedTag.count < 3 ? 0.6 : 1)
                        }
                    }

                    Text(L10n.t("onboarding.hint", language))
                        .font(RoyalFont.ui(12, weight: .semibold))
                        .foregroundStyle(RoyalDS.Color.textMuted)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 16)
                .padding(.top, 28)
                .padding(.bottom, 40)
            }
        }
    }

    private var normalizedTag: String {
        let trimmed = tagInput.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if trimmed.hasPrefix("#") { return trimmed }
        return "#\(trimmed)"
    }

    private func submit() async {
        errorMessage = nil
        isSubmitting = true
        defer { isSubmitting = false }
        do {
            try await session.linkPlayer(tag: normalizedTag)
        } catch {
            let raw = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            if raw.localizedCaseInsensitiveContains("invalidip")
                || raw.localizedCaseInsensitiveContains("IP not allowed")
                || raw.localizedCaseInsensitiveContains("API key IP") {
                errorMessage = L10n.t("onboarding.api_ip", language)
            } else {
                errorMessage = raw
            }
        }
    }
}
