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
            List {
                Section {
                    LabeledContent("Modul balı") {
                        Text("\(grades.totalScore.formatted()) / \(grades.maxScore.formatted())")
                            .font(.manropeBold(17))
                            .accessibilityIdentifier("module_total_score")
                    }
                }

                Section("Kateqoriyalar") {
                    ForEach(grades.grades) { category in
                        ScoreRow(title: category.category, score: category.score, maxScore: category.maxScore)
                    }
                }
            }
            .font(.manropeRegular(16))
        }
        .navigationTitle(viewModel.module.moduleName)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.load()
        }
    }
}
