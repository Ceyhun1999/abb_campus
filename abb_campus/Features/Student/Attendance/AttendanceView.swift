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
            .font(.manropeRegular(16))
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

    private func summaryHeader(_ summary: AttendanceSummary) -> some View {
        let percentage = Int(summary.attendancePercentage.rounded())

        return HStack(spacing: 16) {
            Gauge(value: Double(percentage), in: 0...100) {
                Text("Davamiyyət")
            } currentValueLabel: {
                Text("\(percentage)%")
            }
            .gaugeStyle(.accessoryCircularCapacity)
            .tint(.blue)

            LabeledContent {
                EmptyView()
            } label: {
                Text("\(summary.presentDays) / \(summary.totalDays) dərs")
                    .font(.manropeBold(20))
                    .accessibilityIdentifier("attendance_summary")

                Text("Gecikmələr iştirak kimi sayılır")
            }
        }
    }
}

private struct AttendanceRow: View {

    let record: AttendanceRecord

    var body: some View {
        LabeledContent(DateFormatting.dayTitle(fromAPI: record.date)) {
            Text(record.status.title)
                .foregroundStyle(record.status.tint)
        }
    }
}

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
