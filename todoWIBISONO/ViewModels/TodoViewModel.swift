import Foundation
import FirebaseFirestore

@MainActor
final class TodoViewModel: ObservableObject {
    @Published var todos: [TodoItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var selectedFilter: FilterOption = .all

    private var listener: ListenerRegistration?
    private let service = FirestoreService.shared
    private let userId: String

    enum FilterOption: String, CaseIterable {
        case all = "All"
        case active = "Active"
        case done = "Done"
    }

    var filteredTodos: [TodoItem] {
        let byFilter: [TodoItem]
        switch selectedFilter {
        case .all:    byFilter = todos
        case .active: byFilter = todos.filter { !$0.isCompleted }
        case .done:   byFilter = todos.filter { $0.isCompleted }
        }
        guard !searchText.isEmpty else { return byFilter }
        return byFilter.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.description.localizedCaseInsensitiveContains(searchText)
        }
    }

    var completedCount: Int { todos.filter { $0.isCompleted }.count }
    var totalCount: Int { todos.count }

    init(userId: String) {
        self.userId = userId
        startListening()
    }

    private func startListening() {
        listener = service.listenToTodos(
            for: userId,
            onChange: { [weak self] updated in self?.todos = updated },
            onError: { [weak self] error in self?.errorMessage = error.localizedDescription }
        )
    }

    // MARK: - CRUD

    func addTodo(title: String, description: String, priority: TodoItem.Priority, dueDate: Date?) {
        let todo = TodoItem(
            title: title,
            description: description,
            priority: priority,
            dueDate: dueDate,
            userId: userId
        )
        do {
            try service.addTodo(todo)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggleCompletion(_ todo: TodoItem) {
        var updated = todo
        updated.isCompleted.toggle()
        updated.updatedAt = Date()
        Task {
            do { try await service.updateTodo(updated) }
            catch { errorMessage = error.localizedDescription }
        }
    }

    func updateTodo(_ todo: TodoItem) {
        var updated = todo
        updated.updatedAt = Date()
        Task {
            do { try await service.updateTodo(updated) }
            catch { errorMessage = error.localizedDescription }
        }
    }

    func deleteTodo(_ todo: TodoItem) {
        Task {
            do { try await service.deleteTodo(todo) }
            catch { errorMessage = error.localizedDescription }
        }
    }

    func deleteTodos(at offsets: IndexSet) {
        offsets.forEach { deleteTodo(filteredTodos[$0]) }
    }

    deinit {
        listener?.remove()
    }
}
