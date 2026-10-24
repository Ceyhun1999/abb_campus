import SwiftUI

/// "Gələcək / Keçmiş" with the lessons of that period grouped by day.
/// The student, teacher and group schedules show their lessons with it.
struct SchedulePeriodList: View {

    @Binding var period: SchedulePeriod
    let state: ViewState<[ScheduleLesson]>
    let sections: [ScheduleSection]
    let emptyMessage: String
    /// Swipe and long-press actions to cancel a lesson; none for students.
    var lessonActions: LessonActions?
    var listIdentifier = "schedule_list"
    /// Space between the period picker and the list.
    var spacing: CGFloat = 8
    let load: () async -> Void

    var body: some View {
        VStack(spacing: 0) {
            Picker("Dövr", selection: $period) {
                ForEach(SchedulePeriod.allCases) { period in
                    Text(period.title).tag(period)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, AppLayout.horizontalPadding)
            .padding(.bottom, spacing)

            AsyncContentView(
                state: state,
                isEmpty: { _ in sections.isEmpty },
                emptyTitle: "Dərs yoxdur",
                emptyMessage: emptyMessage,
                emptyIcon: "calendar",
                retry: load
            ) { _ in
                List(sections) { section in
                    Section(section.title) {
                        ForEach(section.lessons) { lesson in
                            if let lessonActions {
                                LessonRow(lesson: lesson)
                                    .lessonActionMenu(for: lesson, actions: lessonActions)
                            } else {
                                LessonRow(lesson: lesson)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .refreshable {
                    await load()
                }
                .accessibilityIdentifier(listIdentifier)
            }
        }
    }
}
