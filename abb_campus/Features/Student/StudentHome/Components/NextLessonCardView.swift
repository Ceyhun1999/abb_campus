import SwiftUI

struct NextLessonCardView: View {

    let lesson: ScheduleLesson?

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "calendar")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 52, height: 52)
                .background(Color.white.opacity(0.18))
                .clipShape(RoundedRectangle(cornerRadius: 14))

            VStack(alignment: .leading, spacing: 5) {
                Text("Növbəti dərs")
                    .font(.manropeRegular(16))
                    .foregroundStyle(.white.opacity(0.85))

                if let lesson {
                    Text(lesson.title)
                        .font(.manropeSemiBold(20))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .accessibilityIdentifier("next_lesson_title")

                    Text("\(DateFormatting.dayTitle(fromAPI: lesson.date)) · \(lesson.timeRange)")
                        .font(.manropeRegular(15))
                        .foregroundStyle(.white.opacity(0.95))

                    if let room = lesson.room {
                        Text("Otaq \(room)")
                            .font(.manropeRegular(15))
                            .foregroundStyle(.white.opacity(0.95))
                    }
                } else {
                    Text("Yaxın günlərdə dərs yoxdur")
                        .font(.manropeSemiBold(18))
                        .foregroundStyle(.white)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(.brandBlue)
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }
}

#Preview {
    NextLessonCardView(lesson: ScheduleLesson(
        id: 1, title: "SwiftUI layout", date: "2026-10-14",
        startsAt: "19:00", endsAt: "21:00", room: "402", description: nil
    ))
    .padding()
}
