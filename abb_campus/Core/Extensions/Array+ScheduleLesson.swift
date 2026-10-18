import Foundation

extension Array where Element == ScheduleLesson {

    /// The same list with `lesson` put in place of the lesson with its id.
    /// The group name and score status of the old lesson are kept when the response leaves them out.
    func replacing(_ lesson: ScheduleLesson) -> [ScheduleLesson] {
        map { old in
            guard old.id == lesson.id else {
                return old
            }

            return ScheduleLesson(
                id: lesson.id, title: lesson.title, date: lesson.date,
                startsAt: lesson.startsAt, endsAt: lesson.endsAt,
                room: lesson.room, description: lesson.description,
                kind: lesson.kind, isCancelled: lesson.isCancelled,
                cancelReason: lesson.cancelReason, cancelNote: lesson.cancelNote,
                groupName: lesson.groupName ?? old.groupName,
                hasScores: lesson.hasScores || old.hasScores
            )
        }
    }
}
