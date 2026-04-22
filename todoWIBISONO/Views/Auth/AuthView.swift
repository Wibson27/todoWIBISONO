import SwiftUI

struct AuthView: View {
    @EnvironmentObject private var authVM: AuthViewModel

    var body: some View {
        ZStack {
            LinearGradient.pinkBgGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()
                logoSection
                Spacer()
                loginSection
                    .padding(.horizontal, 32)
                    .padding(.bottom, 60)
            }
        }
    }

    // MARK: - Subviews

    private var logoSection: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.pinkPrimary.opacity(0.15))
                    .frame(width: 130, height: 130)
                Circle()
                    .fill(Color.pinkPrimary.opacity(0.08))
                    .frame(width: 160, height: 160)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.pinkPrimary)
            }

            VStack(spacing: 8) {
                Text("My Todos")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.pinkDeep)
                Text("Stay organized, stay fabulous ✨")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }

    private var loginSection: some View {
        VStack(spacing: 16) {
            if authVM.isLoading {
                ProgressView()
                    .tint(.pinkPrimary)
                    .scaleEffect(1.3)
                    .frame(height: 54)
            } else {
                googleSignInButton
            }

            if let error = authVM.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
    }

    private var googleSignInButton: some View {
        Button(action: { authVM.signInWithGoogle() }) {
            HStack(spacing: 12) {
                Image(systemName: "globe")
                    .font(.title3)
                Text("Continue with Google")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(LinearGradient.pinkGradient)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .pinkPrimary.opacity(0.45), radius: 10, x: 0, y: 5)
        }
    }
}
