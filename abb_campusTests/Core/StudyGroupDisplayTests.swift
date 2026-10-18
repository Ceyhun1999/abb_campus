import Foundation
import Testing
@testable import abb_campus

@Suite("Group texts shown on group screens")
struct StudyGroupDisplayTests {

    private func group(
        teacher: StudyGroup.TeacherReference?,
        mentors: [StudyGroup.TeacherReference]?,
        endDate: String? = "2027-03-01",
        studentsCount: Int? = 6
    ) -> StudyGroup {
        StudyGroup(
            id: 1, name: "IOS-01", course: Course(id: 1, name: "Mobile Development iOS"),
            teacher: teacher, mentors: mentors, startDate: "2026-09-01", endDate: endDate,
            isActive: true, studentsCount: studentsCount, progress: nil
        )
    }

    @Test("A deactivated teacher is marked, a missing one says so")
    func teacherText() {
        let inactive = StudyGroup.TeacherReference(id: 1, firstName: "Kamal", lastName: "Əliyev", isActive: false)

        #expect(group(teacher: inactive, mentors: nil).teacherText == "Kamal Əliyev (deaktiv)")
        #expect(group(teacher: nil, mentors: nil).teacherText == "Təyin edilməyib")
    }

    @Test("Mentors are listed one per line")
    func mentorsText() {
        let mentors = [
            StudyGroup.TeacherReference(id: 2, firstName: "Fidan", lastName: "Kərimova"),
            StudyGroup.TeacherReference(id: 3, firstName: "Rəşad", lastName: "Səfərov")
        ]

        #expect(group(teacher: nil, mentors: mentors).mentorsText == "Fidan Kərimova\nRəşad Səfərov")
        #expect(group(teacher: nil, mentors: []).mentorsText == "Təyin edilməyib")
    }

    @Test("The period shows both dates, or an open end")
    func periodText() {
        #expect(group(teacher: nil, mentors: nil).periodText == "01.09.2026 – 01.03.2027")
        #expect(group(teacher: nil, mentors: nil, endDate: nil).periodText == "01.09.2026 – …")
    }

    @Test("The card subtitle joins the student count and the course")
    func cardSubtitle() {
        #expect(group(teacher: nil, mentors: nil).cardSubtitle == "Tələbə sayı: 6 · Mobile Development iOS")
        #expect(group(teacher: nil, mentors: nil, studentsCount: nil).cardSubtitle == "Mobile Development iOS")
    }
}
