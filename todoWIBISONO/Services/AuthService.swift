import Foundation
import FirebaseAuth
import FirebaseCore
import GoogleSignIn

final class AuthService {
    static let shared = AuthService()
    private init() {}

    // @MainActor ensures GIDSignIn and all UIKit calls stay on the main thread
    @MainActor
    @discardableResult
    func signInWithGoogle(presenting viewController: UIViewController) async throws -> FirebaseAuth.User {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw AuthServiceError.missingClientID
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: viewController)

        guard let idToken = result.user.idToken?.tokenString else {
            throw AuthServiceError.missingIDToken
        }

        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: result.user.accessToken.tokenString
        )

        let authResult = try await Auth.auth().signIn(with: credential)
        return authResult.user
    }

    func signOut() throws {
        GIDSignIn.sharedInstance.signOut()
        try Auth.auth().signOut()
    }

    var currentUser: FirebaseAuth.User? {
        Auth.auth().currentUser
    }

    enum AuthServiceError: LocalizedError {
        case missingClientID
        case missingIDToken

        var errorDescription: String? {
            switch self {
            case .missingClientID: return "Firebase client ID is missing. Check GoogleService-Info.plist."
            case .missingIDToken: return "Could not retrieve Google ID token."
            }
        }
    }
}
