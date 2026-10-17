import SwiftUI

/// "Tələbələr (N)" with a card of the group's students.
struct GroupStudentsSection: View {

    let students: [GroupStudent]
    let emptyMessage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tələbələr (\(students.count))")
                .font(.manropeBold(20))
                .foregroundStyle(.textPrimary)

            if students.isEmpty {
                ContentUnavailableView(
                    "Qrupda tələbə yoxdur",
                    systemImage: "person.3",
                    description: Text(emptyMessage)
                )
            } else {
                VStack(spacing: 0) {
                    ForEach(students) { student in
                        HStack(spacing: 12) {
                            AvatarView(firstName: student.firstName, lastName: student.lastName, size: 38)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(student.fullName)
                                    .font(.manropeSemiBold(15))
                                    .foregroundStyle(.textPrimary)

                                Text(student.email)
                                    .font(.manropeRegular(12))
                                    .foregroundStyle(.textSecondary)
                            }

                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)

                        if student.id != students.last?.id {
                            InfoDivider()
                        }
                    }
                }
                .cardStyle()
            }
        }
    }
}
