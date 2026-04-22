//
//  ContentView.swift
//  todoWIBISONO
//
//  Created by 22 on 2026/4/21.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var authVM: AuthViewModel

    var body: some View {
        Group {
            if authVM.isAuthenticated, let user = authVM.currentUser {
                // AuthenticatedView owns the TodoViewModel via @StateObject,
                // preventing re-creation on every ContentView render
                AuthenticatedView(userId: user.id)
            } else {
                AuthView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authVM.isAuthenticated)
    }
}

// Separate view so @StateObject is tied to the authenticated session lifetime
private struct AuthenticatedView: View {
    @StateObject private var todoVM: TodoViewModel

    init(userId: String) {
        _todoVM = StateObject(wrappedValue: TodoViewModel(userId: userId))
    }

    var body: some View {
        TodoListView()
            .environmentObject(todoVM)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthViewModel())
    }
}
