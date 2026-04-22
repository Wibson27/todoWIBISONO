import SwiftUI

// Separate ViewModel for detail/edit state — demonstrates @ObservedObject pattern
final class TodoDetailViewModel: ObservableObject {
    @Published var editTitle: String
    @Published var editDescription: String
    @Published var editPriority: TodoItem.Priority
    @Published var editHasDueDate: Bool
    @Published var editDueDate: Date

    let original: TodoItem

    init(todo: TodoItem) {
        self.original = todo
        self.editTitle = todo.title
        self.editDescription = todo.description
        self.editPriority = todo.priority
        self.editHasDueDate = todo.dueDate != nil
        self.editDueDate = todo.dueDate ?? Date()
    }

    func buildUpdated() -> TodoItem {
        var updated = original
        updated.title = editTitle.trimmingCharacters(in: .whitespaces)
        updated.description = editDescription.trimmingCharacters(in: .whitespaces)
        updated.priority = editPriority
        updated.dueDate = editHasDueDate ? editDueDate : nil
        updated.updatedAt = Date()
        return updated
    }
}

struct TodoDetailView: View {
    // @ObservedObject — VM is owned by the parent (passed in), not created here
    @ObservedObject var detailVM: TodoDetailViewModel
    @EnvironmentObject private var todoVM: TodoViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var isEditing = false
    @State private var showDeleteConfirm = false

    init(todo: TodoItem) {
        self._detailVM = ObservedObject(wrappedValue: TodoDetailViewModel(todo: todo))
    }

    // Always reads the current version of this todo from the live listener,
    // so the status card stays accurate after toggling or external changes
    private var liveTodo: TodoItem {
        todoVM.todos.first { $0.id == detailVM.original.id } ?? detailVM.original
    }

    var body: some View {
        ZStack {
            Color.pinkBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    statusCard
                    detailsCard
                    dueDateCard
                    metaCard
                    deleteButton
                }
                .padding()
            }
        }
        .navigationTitle("Detail")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { editToolbar }
        .confirmationDialog("Delete this todo?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                todoVM.deleteTodo(liveTodo)
                dismiss()
            }
        }
    }

    // MARK: - Cards

    private var statusCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Status")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.secondary)
                Text(liveTodo.isCompleted ? "Completed" : "Active")
                    .font(.headline)
                    .foregroundColor(liveTodo.isCompleted ? .pinkPrimary : .primary)
            }
            Spacer()
            Button { todoVM.toggleCompletion(liveTodo) } label: {
                Image(systemName: liveTodo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.largeTitle)
                    .foregroundColor(liveTodo.isCompleted ? .pinkPrimary : Color.gray.opacity(0.35))
            }
        }
        .padding()
        .pinkCard()
    }

    private var detailsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Details")
                .font(.caption.weight(.semibold))
                .foregroundColor(.secondary)

            if isEditing {
                TextField("Title", text: $detailVM.editTitle)
                    .font(.title3.weight(.semibold))
                    .textFieldStyle(.roundedBorder)

                TextField("Notes", text: $detailVM.editDescription, axis: .vertical)
                    .lineLimit(3...5)
                    .textFieldStyle(.roundedBorder)

                Picker("Priority", selection: $detailVM.editPriority) {
                    ForEach(TodoItem.Priority.allCases, id: \.self) { p in
                        Text(p.displayName).tag(p)
                    }
                }
                .pickerStyle(.segmented)
                .tint(.pinkPrimary)
            } else {
                Text(liveTodo.title)
                    .font(.title3.weight(.semibold))

                if !liveTodo.description.isEmpty {
                    Text(liveTodo.description)
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("Priority").foregroundColor(.secondary)
                    Spacer()
                    Text(liveTodo.priority.displayName)
                        .fontWeight(.semibold)
                        .foregroundColor(.pinkDeep)
                }
            }
        }
        .padding()
        .pinkCard()
    }

    private var dueDateCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Due Date")
                .font(.caption.weight(.semibold))
                .foregroundColor(.secondary)

            if isEditing {
                Toggle("Set a due date", isOn: $detailVM.editHasDueDate)
                    .tint(.pinkPrimary)
                if detailVM.editHasDueDate {
                    DatePicker("", selection: $detailVM.editDueDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .tint(.pinkPrimary)
                        .labelsHidden()
                }
            } else {
                if let due = liveTodo.dueDate {
                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .foregroundColor(.pinkPrimary)
                        Text(due, style: .date)
                    }
                } else {
                    Text("No due date").foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .pinkCard()
    }

    private var metaCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Info")
                .font(.caption.weight(.semibold))
                .foregroundColor(.secondary)
            HStack {
                Text("Created").foregroundColor(.secondary)
                Spacer()
                Text(liveTodo.createdAt, style: .date)
                    .font(.caption)
            }
            HStack {
                Text("Updated").foregroundColor(.secondary)
                Spacer()
                Text(liveTodo.updatedAt, style: .relative)
                    .font(.caption)
            }
        }
        .padding()
        .pinkCard()
    }

    private var deleteButton: some View {
        Button(role: .destructive) { showDeleteConfirm = true } label: {
            Label("Delete Todo", systemImage: "trash")
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.75))
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var editToolbar: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(isEditing ? "Save" : "Edit") {
                if isEditing {
                    todoVM.updateTodo(detailVM.buildUpdated())
                }
                withAnimation { isEditing.toggle() }
            }
            .fontWeight(.semibold)
            .foregroundColor(.pinkDeep)
        }
    }
}

// MARK: - Card Modifier

private struct PinkCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.pinkLight.opacity(0.35), radius: 8, x: 0, y: 3)
    }
}

extension View {
    func pinkCard() -> some View {
        modifier(PinkCardModifier())
    }
}
