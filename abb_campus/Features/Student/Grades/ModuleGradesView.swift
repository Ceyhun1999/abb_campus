import SwiftUI

struct ModuleGradesView: View {

    @State private var viewModel: ModuleGradesViewModel

    init(viewModel: ModuleGradesViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        AsyncContentView(
            state: viewModel.state,
            isEmpty: \.grades.isEmpty,
            emptyTitle: "Kateqoriya yoxdur",
            emptyIcon: "list.bullet.rectangle",
            retry: viewModel.load
        ) { grades in
            ScrollView {
                VStack(spacing: 16) {
                    totalCard(grades)

                    InfoCard {
                        ForEach(grades.grades) { category in
                            CategoryScoreRow(category: category)

                            if category.id != grades.grades.last?.id {
                                InfoDivider()
                            }
                        }
                    }
                }
                .padding(.horizontal, AppLayout.horizontalPadding)
                .padding(.vertical, 16)
            }
        }
        .background(.appBackground)
        .navigationTitle(viewModel.module.moduleName)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.load()
        }
    }

    // MARK: - Total

    private func totalCard(_ grades: ModuleGrades) -> some View {
        VStack(spacing: 8) {
            Text("Modul balı")
                .font(.manropeRegular(15))
                .foregroundStyle(.white.opacity(0.85))

            Text("\(grades.totalScore.formatted()) / \(grades.maxScore.formatted())")
                .font(.manropeBold(34))
                .foregroundStyle(.white)
                .accessibilityIdentifier("module_total_score")
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(.brandBlue)
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }
}

// MARK: - Category Row

private struct CategoryScoreRow: View {

    let category: ModuleGrades.CategoryScore

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(category.category)
                    .font(.manropeSemiBold(15))
                    .foregroundStyle(.textPrimary)

                Spacer()

                Text("\(category.score.formatted()) / \(category.maxScore.formatted())")
                    .font(.manropeSemiBold(15))
                    .foregroundStyle(.textPrimary)
            }

            ProgressBar(
                color: .attendanceBlue,
                progress: category.maxScore > 0 ? category.score / category.maxScore : 0
            )
        }
        .padding(16)
    }
}
