import SwiftUI

struct AddTodoView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject private var todoVM: TodoViewModel

    // Local form state — all @State since this data only lives in this sheet
    @State private var title = ""
    @State private var description = ""
    @State private var priority: TodoItem.Priority = .medium
    @State private var hasDueDate = false
    @State private var dueDate = Date()

    var body: some View {
        NavigationView {
            ZStack {
                Color.pinkBackground.ignoresSafeArea()

                Form {
                    taskDetailsSection
                    prioritySection
                    dueDateSection
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("New Todo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarItems }
            .accentColor(.pinkPrimary)
        }
    }

    // MARK: - Sections

    private var taskDetailsSection: some View {
        Section {
            TextField("What needs to be done?", text: $title)
            TextField("Notes (optional)", text: $description, axis: .vertical)
                .lineLimit(3...5)
        } header: {
            Text("Task")
        }
        .listRowBackground(Color.white)
    }

    private var prioritySection: some View {
        Section {
            Picker("", selection: $priority) {
                ForEach(TodoItem.Priority.allCases, id: \.self) { p in
                    Text(p.displayName).tag(p)
                }
            }
            .pickerStyle(.segmented)
        } header: {
            Text("Priority")
        }
        .listRowBackground(Color.white)
    }

    private var dueDateSection: some View {
        Section {
            Toggle("Set a due date", isOn: $hasDueDate)
                .tint(.pinkPrimary)
            if hasDueDate {
                DatePicker("Due", selection: $dueDate, in: Date()..., displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .tint(.pinkPrimary)
            }
        } header: {
            Text("Due Date")
        }
        .listRowBackground(Color.white)
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") { isPresented = false }
                .foregroundColor(.pinkPrimary)
        }
        ToolbarItem(placement: .confirmationAction) {
            Button("Add") { save() }
                .fontWeight(.semibold)
                .foregroundColor(title.trimmingCharacters(in: .whitespaces).isEmpty ? .gray : .pinkDeep)
                .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
        }
    }

    // MARK: - Actions

    private func save() {
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        todoVM.addTodo(
            title: trimmed,
            description: description.trimmingCharacters(in: .whitespaces),
            priority: priority,
            dueDate: hasDueDate ? dueDate : nil
        )
        isPresented = false
    }
}
