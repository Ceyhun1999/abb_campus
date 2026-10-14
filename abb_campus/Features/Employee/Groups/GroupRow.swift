import SwiftUI

struct GroupRow: View {

    let group: StudyGroup

    var body: some View {
        LabeledContent {
            if !group.isActive {
                Text("Bitib")
                    .foregroundStyle(.red)
            } else if let progress = group.progress {
                Gauge(value: Double(progress), in: 0...100) {
                    Text("Proqres")
                } currentValueLabel: {
                    Text("\(progress)")
                }
                .gaugeStyle(.accessoryCircularCapacity)
                .tint(.blue)
                .scaleEffect(0.75)
                .accessibilityLabel("Proqres \(progress) faiz")
            }
        } label: {
            Text(group.name)
                .font(.manropeSemiBold(16))

            Text(subtitle)
        }
    }

    private var subtitle: String {
        var parts: [String] = []

        if let course = group.course?.name {
            parts.append(course)
        }

        if let count = group.studentsCount {
            parts.append("\(count) tələbə")
        }

        return parts.joined(separator: " · ")
    }
}
