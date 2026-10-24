import SwiftUI

private struct LessonActionsModifier: ViewModifier {

    @Bindable var actions: LessonActions

    func body(content: Content) -> some View {
        content
            .sheet(item: $actions.cancelViewModel) { cancelViewModel in
                CancelLessonView(viewModel: cancelViewModel, onCancelled: actions.cancelFinished)
            }
            .errorAlert(actions.errorMessage, onDismiss: actions.dismissError)
    }
}

private struct LessonActionMenu: ViewModifier {

    let lesson: ScheduleLesson
    let actions: LessonActions

    func body(content: Content) -> some View {
        content
            .swipeActions(edge: .trailing) {
                buttons
            }
            .contextMenu {
                buttons
            }
    }

    @ViewBuilder
    private var buttons: some View {
        if actions.canCancel(lesson) {
            Button(role: .destructive) {
                actions.startCancel(lesson)
            } label: {
                Label("Ləğv et", systemImage: "calendar.badge.minus")
            }
        }
    }
}

extension View {

    /// Presents the cancel sheet and errors of `actions`.
    func lessonActions(_ actions: LessonActions) -> some View {
        modifier(LessonActionsModifier(actions: actions))
    }

    /// Swipe and long-press actions to cancel one lesson.
    func lessonActionMenu(for lesson: ScheduleLesson, actions: LessonActions) -> some View {
        modifier(LessonActionMenu(lesson: lesson, actions: actions))
    }
}
