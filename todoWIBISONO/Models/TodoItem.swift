import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct TodoItem: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var description: String
    var isCompleted: Bool
    var priority: Priority
    var dueDate: Date?
    var createdAt: Date
    var updatedAt: Date
    var userId: String

    enum Priority: String, Codable, CaseIterable {
        case low = "low"
        case medium = "medium"
        case high = "high"

        var displayName: String {
            rawValue.capitalized
        }
    }

    init(title: String, description: String = "", priority: Priority = .medium, dueDate: Date? = nil, userId: String) {
        self.title = title
        self.description = description
        self.isCompleted = false
        self.priority = priority
        self.dueDate = dueDate
        self.createdAt = Date()
        self.updatedAt = Date()
        self.userId = userId
    }
}
