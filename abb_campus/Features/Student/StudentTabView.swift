import SwiftUI

struct StudentTabView: View {
    var body: some View {
        TabView {
            StudentHomeView()
                .tabItem {
                    Label("Ana səhifə", systemImage: "house.fill")
                }

            StudentGradesView()
                .tabItem {
                    Label("Qiymətlər", systemImage: "chart.bar.fill")
                }
            
            StudentScheduleView()
                .tabItem {
                    Label("Cədvəl", systemImage: "calendar")
                }
            
            StudentNotificationsView()
                .tabItem {
                    Label("Bildirişlər", systemImage: "bell.fill")
                }
            
            StudentProfileView()
                .tabItem {
                    Label("Profil", systemImage: "person.fill")
                }
        }
    }
}

#Preview {
    StudentTabView()
}
