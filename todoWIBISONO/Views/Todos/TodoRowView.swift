import SwiftUI

struct TodoRowView: View {
    let todo: TodoItem
    // @Binding — parent owns the state, this view reads and writes through the binding
    @Binding var isCompleted: Bool

    var body: some View {
        HStack(spacing: 14) {
            toggleButton
            content
            Spacer(minLength: 0)
        }
        .padding(.vertical, 6)
    }

    // MARK: - Subviews

    private var toggleButton: some View {
        Button {
            isCompleted.toggle()
        } label: {
            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .foregroundColor(isCompleted ? .pinkPrimary : Color.gray.opacity(0.35))
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isCompleted)
        }
        .buttonStyle(.plain)
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(todo.title)
                .font(.body.weight(.medium))
                .strikethrough(isCompleted, color: .gray)
                .foregroundColor(isCompleted ? .gray : .primary)
                .lineLimit(2)

            if !todo.description.isEmpty {
                Text(todo.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            HStack(spacing: 6) {
                priorityBadge
                if let due = todo.dueDate {
                    dueBadge(due)
                }
            }
        }
    }

    private var priorityBadge: some View {
        Text(todo.priority.displayName)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(priorityColor.opacity(0.15))
            .foregroundColor(priorityColor)
            .clipShape(Capsule())
    }

    private func dueBadge(_ date: Date) -> some View {
        let overdue = date < Date() && !isCompleted
        return HStack(spacing: 3) {
            Image(systemName: "calendar")
                .font(.caption2)
            Text(date, style: .date)
                .font(.caption2)
        }
        .foregroundColor(overdue ? .red : .secondary)
    }

    private var priorityColor: Color {
        switch todo.priority {
        case .low:    return .green
        case .medium: return Color(hex: "#FFA500")
        case .high:   return .pinkDeep
        }
    }
}
