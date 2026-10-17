import SwiftUI

// MARK: - Attendance

struct GroupAttendanceView: View {

    @State private var viewModel: GroupAttendanceViewModel

    init(viewModel: GroupAttendanceViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        let report = viewModel.report

        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                MonthSwitcher(month: report.month) {
                    Task { await report.goBack() }
                } onForward: {
                    Task { await report.goForward() }
                }

                PrimaryButton(title: "Excel-dən davamiyyət yüklə") {
                    viewModel.showImport()
                }
                .disabled(!viewModel.canImport)
                .opacity(viewModel.canImport ? 1 : 0.5)
                .accessibilityIdentifier("import_attendance_button")

                switch report.state {
                case .loaded(let summary):
                    Text(viewModel.lessonDaysText(summary))
                        .font(.manropeRegular(14))
                        .foregroundStyle(.textSecondary)

                    studentsCard(summary.students)
                case .failed(let message):
                    ContentUnavailableView("Yüklənmədi", systemImage: "exclamationmark.triangle", description: Text(message))
                default:
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                }
            }
            .padding(.horizontal, AppLayout.horizontalPadding)
            .padding(.vertical, 16)
        }
        .refreshable {
            await report.load()
        }
        .background(.appBackground)
        .navigationTitle("Davamiyyət")
        .navigationBarTitleDisplayMode(.inline)
        .importFlow(viewModel.importFlow)
        .task {
            await report.load()
        }
    }

    private func studentsCard(_ students: [GroupAttendanceSummary.StudentRow]) -> some View {
        VStack(spacing: 0) {
            ForEach(students) { student in
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(student.fullName)
                            .font(.manropeSemiBold(15))
                            .foregroundStyle(.textPrimary)

                        Text("Var \(student.present) · Gecikib \(student.late) · Yox \(student.absent) · Üzrlü \(student.excused)")
                            .font(.manropeRegular(12))
                            .foregroundStyle(.textSecondary)
                    }

                    Spacer()

                    Text(student.percentage.map { "\($0)%" } ?? "—")
                        .font(.manropeBold(16))
                        .foregroundStyle(color(for: student.percentage))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .accessibilityElement(children: .combine)

                if student.id != students.last?.id {
                    InfoDivider()
                }
            }
        }
        .cardStyle()
        .accessibilityIdentifier("attendance_students")
    }

    private func color(for percentage: Int?) -> Color {
        guard let percentage else {
            return .textSecondary
        }

        return percentage >= 80 ? .green : percentage >= 60 ? .orange : .red
    }
}

// MARK: - Scores

struct GroupScoresView: View {

    @State private var viewModel: GroupScoresViewModel

    init(viewModel: GroupScoresViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        let report = viewModel.report

        List {
            Section {
                MonthSwitcher(month: report.month) {
                    Task { await report.goBack() }
                } onForward: {
                    Task { await report.goForward() }
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)

                PrimaryButton(title: "Excel-dən tapşırıq ballarını yüklə") {
                    viewModel.showImport()
                }
                .disabled(!viewModel.canImport)
                .opacity(viewModel.canImport ? 1 : 0.5)
                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
                .listRowBackground(Color.clear)
                .accessibilityIdentifier("import_tasks_button")
            }

            switch report.state {
            case .loaded(let assessments):
                if assessments.isEmpty {
                    Section {
                        ContentUnavailableView(
                            "Bal yoxdur",
                            systemImage: "star",
                            description: Text("\(report.month.title) üçün bal yüklənməyib.")
                        )
                    }
                } else {
                    assessmentSection("Tapşırıqlar", viewModel.tasks(assessments))
                    assessmentSection("İmtahanlar", viewModel.exams(assessments))
                }
            case .failed(let message):
                Section {
                    ContentUnavailableView("Yüklənmədi", systemImage: "exclamationmark.triangle", description: Text(message))
                }
            default:
                Section {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .listStyle(.insetGrouped)
        .refreshable {
            await report.load()
        }
        .navigationTitle("Ballar")
        .navigationBarTitleDisplayMode(.inline)
        .importFlow(viewModel.importFlow)
        .task {
            await report.load()
        }
    }

    @ViewBuilder
    private func assessmentSection(_ title: String, _ assessments: [GroupAssessment]) -> some View {
        if !assessments.isEmpty {
            Section(title) {
                ForEach(assessments) { assessment in
                    DisclosureGroup {
                        ForEach(assessment.scores) { score in
                            HStack {
                                Text(score.studentName)
                                    .font(.manropeRegular(15))

                                Spacer()

                                Text(ScoreFormatting.text(score.score))
                                    .font(.manropeSemiBold(15))
                            }
                        }
                    } label: {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(assessment.title)
                                .font(.manropeSemiBold(16))
                                .foregroundStyle(.textPrimary)

                            Text(viewModel.averageText(assessment))
                                .font(.manropeRegular(13))
                                .foregroundStyle(.textSecondary)
                        }
                    }
                }
            }
        }
    }
}
