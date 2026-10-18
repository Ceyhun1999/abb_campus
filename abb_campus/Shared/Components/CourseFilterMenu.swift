import SwiftUI

/// The filter button that limits a list to one course.
struct CourseFilterMenu: View {

    @Binding var selection: Int?
    let courses: [Course]

    var body: some View {
        Menu {
            Picker("Kurs", selection: $selection) {
                Text("Bütün kurslar").tag(Int?.none)

                ForEach(courses) { course in
                    Text(course.name).tag(Optional(course.id))
                }
            }
        } label: {
            Image(systemName: selection == nil
                  ? "line.3.horizontal.decrease.circle"
                  : "line.3.horizontal.decrease.circle.fill")
        }
        .accessibilityLabel("Kurs filtri")
    }
}
