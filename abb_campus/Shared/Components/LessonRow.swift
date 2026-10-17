import SwiftUI

struct LessonRow: View {

    let lesson: ScheduleLesson

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 2) {
                Text(lesson.startsAt)
                    .font(.manropeBold(15))
                    .foregroundStyle(.textPrimary)

                Text(lesson.endsAt)
                    .font(.manropeRegular(13))
                    .foregroundStyle(.textSecondary)
            }
            .frame(width: 52)

            Rectangle()
                .fill(Color.blue)
                .frame(width: 3)
                .clipShape(Capsule())

            VStack(alignment: .leading, spacing: 4) {
                Text(lesson.title)
                    .font(.manropeSemiBold(16))
                    .foregroundStyle(.textPrimary)

                if let room = lesson.room {
                    Label("Otaq \(room)", systemImage: "mappin.and.ellipse")
                        .font(.manropeRegular(13))
                        .foregroundStyle(.textSecondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
