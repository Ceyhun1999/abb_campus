import SwiftUI

struct AttendanceView: View {

    @State private var viewModel: AttendanceViewModel

    init(viewModel: AttendanceViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        AsyncContentView(
            state: viewModel.state,
            isEmpty: \.records.isEmpty,
            emptyTitle: "Qeyd yoxdur",
            emptyMessage: "Hələ davamiyyət qeyd edilməyib.",
            emptyIcon: "checklist",
            retry: viewModel.load
        ) { summary in
            List {
                Section {
                    summaryHeader(summary)
                }

                Section("Qeydlər") {
                    ForEach(summary.records) { record in
                        AttendanceRow(record: record)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .refreshable {
                await viewModel.load()
            }
        }
        .navigationTitle("Davamiyyət")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.load()
        }
    }

    // MARK: - Summary

    private func summaryHeader(_ summary: AttendanceSummary) -> some View {
        HStack(spacing: 20) {
            ProgressRing(progress: Int(summary.attendancePercentage.rounded()), size: 76)

            VStack(alignment: .leading, spacing: 4) {
                Text("\(summary.presentDays) / \(summary.totalDays) dərs")
                    .font(.manropeBold(20))
                    .foregroundStyle(.textPrimary)
                    .accessibilityIdentifier("attendance_summary")

                Text("Gecikmələr iştirak kimi sayılır")
                    .font(.manropeRegular(13))
                    .foregroundStyle(.textSecondary)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Attendance Row

private struct AttendanceRow: View {

    let record: AttendanceRecord

    var body: some View {
        HStack {
            Text(DateFormatting.dayTitle(fromAPI: record.date))
                .font(.manropeRegular(15))
                .foregroundStyle(.textPrimary)

            Spacer()

            Text(record.status.title)
                .font(.manropeSemiBold(12))
                .foregroundStyle(record.status.tint)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(record.status.tint.opacity(0.12))
                .clipShape(Capsule())
        }
    }
}

// MARK: - Status Color

private extension AttendanceStatus {

    var tint: Color {
        switch self {
        case .present: return .green
        case .late: return .orange
        case .excused: return .blue
        case .absent: return .red
        }
    }
}
