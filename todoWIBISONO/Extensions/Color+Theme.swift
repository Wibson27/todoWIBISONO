import SwiftUI

extension Color {
    static let pinkPrimary    = Color(hex: "#FF69B4") // Hot Pink
    static let pinkLight      = Color(hex: "#FFB6C1") // Light Pink
    static let pinkDeep       = Color(hex: "#FF1493") // Deep Pink
    static let pinkBackground = Color(hex: "#FFF0F5") // Lavender Blush
    static let pinkCard       = Color(hex: "#FFF5F8") // Soft card bg

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:  (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:  (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:  (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 255, 105, 180)
        }
        self.init(.sRGB,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}

extension LinearGradient {
    static let pinkGradient = LinearGradient(
        colors: [Color.pinkPrimary, Color.pinkDeep],
        startPoint: .leading,
        endPoint: .trailing
    )
    static let pinkBgGradient = LinearGradient(
        colors: [Color.pinkBackground, Color.pinkLight.opacity(0.4)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
