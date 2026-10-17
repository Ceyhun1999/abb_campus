import SwiftUI

struct StudentGradesView: View {

    @State private var viewModel: StudentGradesViewModel

    init(viewModel: StudentGradesViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        AsyncContentView(
            state: viewModel.state,
            isEmpty: { _ in viewModel.isEmpty },
            emptyTitle: "Qiymət yoxdur",
            emptyMessage: "Kursunuzda hələ modul yoxdur.",
            emptyIcon: "chart.bar",
            retry: viewModel.load
        ) { overview in
            ScrollView {
                VStack(spacing: 16) {
                    summaryCard(overview)

                    ForEach(overview.modules) { module in
                        NavigationLink(value: module) {
                            ModuleScoreRow(module: module)
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("module_row_\(module.moduleId)")
                    }

                    monthlyScores
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

    // MARK: - Monthly Scores

    @ViewBuilder
    private var monthlyScores: some View {
        if let error = viewModel.assessmentsError {
            Text("Aylıq ballar yüklənmədi: \(error)")
                .font(.manropeRegular(13))
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity, alignment: .leading)
        }

        ForEach(viewModel.monthSections) { section in
            VStack(alignment: .leading, spacing: 10) {
                Text("Aylıq ballar · \(section.title)")
                    .font(.manropeBold(18))
                    .foregroundStyle(.textPrimary)

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
            .accessibilityIdentifier("monthly_scores_\(section.month)")
        }
    }

    // MARK: - Summary

    private func summaryCard(_ overview: GradesOverview) -> some View {
        HStack(spacing: 12) {
            SummaryCard(
                icon: "chart.bar.fill",
                title: "Orta bal",
                value: overview.averageScore.formatted(.number.precision(.fractionLength(0...1))),
                tint: .green
            )

            SummaryCard(
                icon: "sum",
                title: "Ümumi nəticə",
                value: "\(overview.overallScore.formatted(.number.precision(.fractionLength(0...1))))%"
            )
        }
    }
}

// MARK: - Module Row

private struct ModuleScoreRow: View {

    let module: ModuleScore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(module.moduleName)
                    .font(.manropeSemiBold(16))
                    .foregroundStyle(.textPrimary)

                Spacer()

                Text("\(module.totalScore.formatted()) / \(module.maxScore.formatted())")
                    .font(.manropeBold(16))
                    .foregroundStyle(.textPrimary)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary)
            }

            ProgressBar(color: .gradeGreen, progress: module.progress)
        }
        .padding(16)
        .cardStyle(cornerRadius: 18)
    }
}
