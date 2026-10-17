import SwiftUI

struct LessonRow: View {

    let lesson: ScheduleLesson

    private var accent: Color {
        if lesson.isCancelled {
            return .gray
        }

        return lesson.isExam ? .orange : .blue
    }

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 2) {
                Text(lesson.startsAt)
                    .font(.manropeBold(15))
                    .foregroundStyle(lesson.isCancelled ? .textSecondary : .textPrimary)

                Text(lesson.endsAt)
                    .font(.manropeRegular(13))
                    .foregroundStyle(.textSecondary)
            }
            .frame(width: 52)

            Rectangle()
                .fill(accent)
                .frame(width: 3)
                .clipShape(Capsule())

            VStack(alignment: .leading, spacing: 4) {
                if lesson.isExam || lesson.isCancelled {
                    badges
                }

                Text(lesson.title)
                    .font(.manropeSemiBold(16))
                    .foregroundStyle(lesson.isCancelled ? .textSecondary : .textPrimary)
                    .strikethrough(lesson.isCancelled)

                if let groupName = lesson.groupName {
                    Label(groupName, systemImage: "person.3")
                        .font(.manropeRegular(13))
                        .foregroundStyle(.textSecondary)
                }

                if let room = lesson.room {
                    Label("Otaq \(room)", systemImage: "mappin.and.ellipse")
                        .font(.manropeRegular(13))
                        .foregroundStyle(.textSecondary)
                }

                if let cancellation = lesson.cancellationText {
                    Label(cancellation, systemImage: "exclamationmark.circle")
                        .font(.manropeRegular(13))
                        .foregroundStyle(.red)
                        .accessibilityIdentifier("lesson_cancel_reason")
                }
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }

    private var badges: some View {
        HStack(spacing: 6) {
            if lesson.isExam {
                badge("İmtahan", color: .orange)
            }

            if lesson.isCancelled {
                badge("Ləğv edildi", color: .red)
            } else if lesson.isExam && lesson.hasScores {
                badge("Ballar yüklənib", color: .green)
            }
        }
    }

    private func badge(_ title: String, color: Color) -> some View {
        Text(title)
            .font(.manropeSemiBold(11))
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }
}
