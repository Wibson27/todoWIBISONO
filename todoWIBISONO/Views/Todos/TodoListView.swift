import SwiftUI

struct TodoListView: View {
    @EnvironmentObject private var todoVM: TodoViewModel
    @EnvironmentObject private var authVM: AuthViewModel

    @State private var showingAddSheet = false
    @State private var showingSignOutConfirm = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.pinkBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    progressBanner
                    filterPicker
                    todoContent
                }
            }
            .navigationTitle("My Todos")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $todoVM.searchText, prompt: "Search todos…")
            .accentColor(.pinkPrimary)
            .toolbar { toolbarItems }
            .sheet(isPresented: $showingAddSheet) {
                AddTodoView(isPresented: $showingAddSheet)
                    .environmentObject(todoVM)
            }
            .confirmationDialog(
                authVM.currentUser?.email ?? "Account",
                isPresented: $showingSignOutConfirm,
                titleVisibility: .visible
            ) {
                Button("Sign Out", role: .destructive) { authVM.signOut() }
                Button("Cancel", role: .cancel) {}
            }
            .alert("Something went wrong", isPresented: Binding(
                get: { todoVM.errorMessage != nil },
                set: { if !$0 { todoVM.errorMessage = nil } }
            )) {
                Button("OK") { todoVM.errorMessage = nil }
            } message: {
                Text(todoVM.errorMessage ?? "Unknown error")
            }
        }
    }

    // MARK: - Subviews

    private var progressBanner: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Hello, \(authVM.currentUser?.displayName.components(separatedBy: " ").first ?? "friend") 👋")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.pinkDeep)
                Text("\(todoVM.completedCount) of \(todoVM.totalCount) completed")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            // Compact progress ring
            ZStack {
                Circle()
                    .stroke(Color.pinkLight.opacity(0.4), lineWidth: 4)
                Circle()
                    .trim(from: 0, to: todoVM.totalCount == 0 ? 0 : CGFloat(todoVM.completedCount) / CGFloat(todoVM.totalCount))
                    .stroke(LinearGradient.pinkGradient, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut, value: todoVM.completedCount)
            }
            .frame(width: 36, height: 36)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.6))
    }

    private var filterPicker: some View {
        Picker("Filter", selection: $todoVM.selectedFilter) {
            ForEach(TodoViewModel.FilterOption.allCases, id: \.self) { opt in
                Text(opt.rawValue).tag(opt)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private var todoContent: some View {
        if todoVM.filteredTodos.isEmpty {
            emptyState
        } else {
            todoList
        }
    }

    private var todoList: some View {
        List {
            ForEach(todoVM.filteredTodos) { todo in
                NavigationLink {
                    TodoDetailView(todo: todo)
                        .environmentObject(todoVM)
                } label: {
                    // @Binding for isCompleted drives the row toggle inline
                    TodoRowView(
                        todo: todo,
                        isCompleted: Binding(
                            get: { todo.isCompleted },
                            set: { _ in todoVM.toggleCompletion(todo) }
                        )
                    )
                }
                .listRowBackground(Color.white.opacity(0.85))
                .listRowSeparatorTint(Color.pinkLight.opacity(0.5))
            }
            .onDelete { todoVM.deleteTodos(at: $0) }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
    }

    private var emptyState: some View {
        VStack(spacing: 18) {
            Spacer()
            Image(systemName: todoVM.searchText.isEmpty ? "sparkles" : "magnifyingglass")
                .font(.system(size: 56))
                .foregroundColor(.pinkLight)
            Text(todoVM.searchText.isEmpty ? "No todos yet!" : "No results")
                .font(.title3.bold())
                .foregroundColor(.pinkDeep)
            Text(todoVM.searchText.isEmpty ? "Tap + to add your first task 🌸" : "Try a different search")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button { showingSignOutConfirm = true } label: {
                Image(systemName: "person.circle.fill")
                    .font(.title3)
                    .foregroundColor(.pinkPrimary)
            }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            Button { showingAddSheet = true } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                    .foregroundColor(.pinkPrimary)
            }
        }
    }
}
