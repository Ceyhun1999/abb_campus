import SwiftUI

/// "‹ Oktyabr 2026 ›" for screens that show one month at a time.
struct MonthSwitcher: View {

    let month: MonthCursor
    let onBack: () -> Void
    let onForward: () -> Void

    var body: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .frame(width: 44, height: 44)
            }
            .disabled(!month.canGoBack)
            .accessibilityLabel("Əvvəlki ay")
            .accessibilityIdentifier("previous_month_button")

            Spacer()

            Text(month.title)
                .font(.manropeSemiBold(17))
                .foregroundStyle(.textPrimary)
                .accessibilityIdentifier("month_title")

            Spacer()

            Button(action: onForward) {
                Image(systemName: "chevron.right")
                    .frame(width: 44, height: 44)
            }
            .disabled(!month.canGoForward)
            .accessibilityLabel("Növbəti ay")
            .accessibilityIdentifier("next_month_button")
        }
        .font(.system(size: 16, weight: .semibold))
        .padding(.horizontal, 6)
        .cardStyle(cornerRadius: 16)
    }
}
