import SwiftUI

private struct LessonActionsModifier: ViewModifier {

    @Bindable var actions: LessonActions

    func body(content: Content) -> some View {
        content
            .sheet(item: $actions.cancelViewModel) { cancelViewModel in
                CancelLessonView(viewModel: cancelViewModel, onCancelled: actions.cancelFinished)
            }
            .confirmationDialog(
                "Dərs yenidən cədvələ qaytarılsın? Tələbələrə bildiriş göndəriləcək.",
                isPresented: Binding(
                    get: { actions.lessonToRestore != nil },
                    set: { if !$0 { actions.lessonToRestore = nil } }
                ),
                titleVisibility: .visible
            ) {
                Button("Bərpa et") {
                    Task {
                        await actions.restore()
                    }
                }

                Button("İmtina", role: .cancel) {}
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
        } else if actions.canRestore(lesson) {
            Button {
                actions.askRestore(lesson)
            } label: {
                Label("Bərpa et", systemImage: "arrow.uturn.backward")
            }
            .tint(.blue)
        }
    }
}

extension View {

    /// Presents the cancel sheet, the restore confirmation and errors of `actions`.
    func lessonActions(_ actions: LessonActions) -> some View {
        modifier(LessonActionsModifier(actions: actions))
    }

    /// Swipe and long-press actions to cancel or restore one lesson.
    func lessonActionMenu(for lesson: ScheduleLesson, actions: LessonActions) -> some View {
        modifier(LessonActionMenu(lesson: lesson, actions: actions))
    }
}
