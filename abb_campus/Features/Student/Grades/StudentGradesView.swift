import SwiftUI

/// The scores a teacher has entered for the student, month by month. Nothing is calculated.
struct StudentGradesView: View {

    @State private var viewModel: StudentGradesViewModel

    init(viewModel: StudentGradesViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        AsyncContentView(
            state: viewModel.state,
            isEmpty: \.isEmpty,
            emptyTitle: "Qiymət yoxdur",
            emptyMessage: "Müəllim hələ bal əlavə etməyib.",
            emptyIcon: "chart.bar",
            retry: viewModel.load
        ) { assessments in
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(viewModel.monthSections(assessments)) { section in
                        monthCard(section)
                    }
                }
                .padding(.horizontal, AppLayout.horizontalPadding)
                .padding(.vertical, 16)
            }
            .refreshable {
                await viewModel.load()
            }
        }
        .background(.appBackground)
        .navigationTitle("Qiymətlər")
        .task {
            await viewModel.load()
        }
    }

    // MARK: - Month

    private func monthCard(_ section: StudentGradesViewModel.MonthSection) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(section.title)
                .font(.manropeBold(18))
                .foregroundStyle(.textPrimary)
                .accessibilityIdentifier("monthly_scores_\(section.month)")

            VStack(spacing: 0) {
                ForEach(section.items) { item in
                    HStack(spacing: 12) {
                        Image(systemName: item.kind == .exam ? "graduationcap.fill" : "checklist")
                            .foregroundStyle(item.kind == .exam ? .orange : .blue)
                            .frame(width: 24)

                        Text(item.title)
                            .font(.manropeSemiBold(15))
                            .foregroundStyle(.textPrimary)

                        Spacer()

                        Text("\(ScoreFormatting.text(item.score)) / \(item.maxScore)")
                            .font(.manropeBold(15))
                            .foregroundStyle(.textPrimary)
                            .accessibilityIdentifier("score_\(item.id)")
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)

                    if item.id != section.items.last?.id {
                        InfoDivider()
                    }
                }
            }
            .cardStyle()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
