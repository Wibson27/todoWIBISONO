import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class FirestoreService {
    static let shared = FirestoreService()
    private let db = Firestore.firestore()
    private init() {}

    // MARK: - Collection Reference

    private func todosRef(for userId: String) -> CollectionReference {
        db.collection("users").document(userId).collection("todos")
    }

    // MARK: - Real-time Listener

    func listenToTodos(
        for userId: String,
        onChange: @escaping ([TodoItem]) -> Void,
        onError: @escaping (Error) -> Void
    ) -> ListenerRegistration {
        todosRef(for: userId)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    onError(error)
                    return
                }
                guard let snapshot = snapshot else { return }
                let todos = snapshot.documents.compactMap { doc -> TodoItem? in
                    try? doc.data(as: TodoItem.self)
                }
                onChange(todos)
            }
    }

    // MARK: - Write Operations

    func addTodo(_ todo: TodoItem) throws {
        // Encode explicitly so @DocumentID is handled correctly, then use addDocument(data:)
        let data = try Firestore.Encoder().encode(todo)
        todosRef(for: todo.userId).addDocument(data: data)
    }

    func updateTodo(_ todo: TodoItem) async throws {
        guard let id = todo.id else { return }
        let data = try Firestore.Encoder().encode(todo)
        try await todosRef(for: todo.userId).document(id).setData(data)
    }

    func deleteTodo(_ todo: TodoItem) async throws {
        guard let id = todo.id else { return }
        try await todosRef(for: todo.userId).document(id).delete()
    }
}
