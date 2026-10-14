import SwiftUI

struct StudentGradesView: View {

    @State private var viewModel: StudentGradesViewModel

    init(viewModel: StudentGradesViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        AsyncContentView(
            state: viewModel.state,
            isEmpty: \.modules.isEmpty,
            emptyTitle: "Qiymət yoxdur",
            emptyMessage: "Kursunuzda hələ modul yoxdur.",
            emptyIcon: "chart.bar",
            retry: viewModel.load
        ) { overview in
            List {
                Section {
                    LabeledContent(
                        "Orta bal",
                        value: overview.averageScore.formatted(.number.precision(.fractionLength(0...1)))
                    )
                    LabeledContent(
                        "Ümumi nəticə",
                        value: "\(overview.overallScore.formatted(.number.precision(.fractionLength(0...1))))%"
                    )
                }

                Section("Modullar") {
                    ForEach(overview.modules) { module in
                        NavigationLink(value: module) {
                            ScoreRow(
                                title: module.moduleName,
                                score: module.totalScore,
                                maxScore: module.maxScore,
                                tint: .green
                            )
                        }
                        .accessibilityIdentifier("module_row_\(module.moduleId)")
                    }
                }
            }
            .font(.manropeRegular(16))
            .refreshable {
                await viewModel.load()
            }
        }
        .navigationTitle("Qiymətlər")
        .task {
            await viewModel.load()
        }
    }
}

struct ScoreRow: View {

    let title: String
    let score: Double
    let maxScore: Double
    var tint: Color = .blue

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            LabeledContent(title, value: "\(score.formatted()) / \(maxScore.formatted())")

            ProgressView(value: maxScore > 0 ? min(score / maxScore, 1) : 0)
                .tint(tint)
        }
    }
}
