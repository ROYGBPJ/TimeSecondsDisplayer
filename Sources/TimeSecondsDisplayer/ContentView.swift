import SwiftUI

// --- Luxury Theme Definition ---
struct LuxuryTheme: Identifiable {
    let id = UUID()
    let name: String
    let bgStart: Color
    let bgEnd: Color
    let accent: Color
    let accentGlow: Color
    let secondary: Color
}

class ThemeManager: ObservableObject {
    @Published var currentTheme: LuxuryTheme = .obsidian

    static let themes: [LuxuryTheme] = [
        .obsidian,
        .cyberpunk,
        .roseGold,
        .titanium
    ]
}

extension LuxuryTheme {
    static let obsidian = LuxuryTheme(
        name: "Obsidian",
        bgStart: Color(hex: "0A0A0C"),
        bgEnd: Color(hex: "1C1E"),
        accent: .cyan,
        accentGlow: .cyan,
        secondary: .white
    )
    static let cyberpunk = LuxuryTheme(
        name: "Cyberpunk",
        bgStart: Color(hex: "0D0221"),
        bgEnd: Color(hex: "240046"),
        accent: Color(hex: "39FF14"), // Neon Green
        accentGlow: Color(hex: "39FF14"),
        secondary: .white
    )
    static let roseGold = LuxuryTheme(
        name: "Rose Gold",
        bgStart: Color(hex: "1A0F0F"),
        bgEnd: Color(hex: "2D1B1B"),
        accent: Color(hex: "B76E79"), // Rose Gold
        accentGlow: Color(hex: "FFB7C5"),
        secondary: .white
    )
    static let titanium = LuxuryTheme(
        name: "Titanium",
        bgStart: Color(hex: "2C2C2C"),
        bgEnd: Color(hex: "4A4A4A"),
        accent: Color(hex: "E5E4E2"), // Platinum/Titanium
        accentGlow: .white,
        secondary: Color(hex: "A9A9A9")
    )
}

struct ContentView: View {
    @StateObject private var themeManager = ThemeManager()
    @State private var currentTime = Date()
    @State private var pulseAmount = 0.0
    @State private var showSettings = false

    // Custom Settings
    @State private var ringSpeed: Double = 1.0
    @State private var glowIntensity: Double = 1.0

    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            // Background: Theme-driven Gradient
            LinearGradient(
                gradient: Gradient(colors: [themeManager.currentTheme.bgStart, themeManager.currentTheme.bgEnd]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.8), value: themeManager.currentTheme)

            VStack(spacing: 40) {
                // Header / Settings Toggle
                HStack {
                    Spacer()
                    Button(action: { withAnimation(.spring()) { showSettings.toggle() } }) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 20, weight: .light))
                            .foregroundColor(themeManager.currentTheme.accent)
                            .padding(12)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(themeManager.currentTheme.accent.opacity(0.3), lineWidth: 1))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)

                // Core Display
                ZStack {
                    // Rotating Ambient Outer Ring
                    Circle()
                        .trim(from: 0, to: CGFloat(currentTime.second) / 60.0)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [themeManager.currentTheme.accent, themeManager.currentTheme.accentGlow]),
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            style: StrokeStyle(lineWidth: 6 * ringSpeed, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 280, height: 280)
                        .shadow(color: themeManager.currentTheme.accent.opacity(0.6), radius: 15 * glowIntensity)

                    // Neon Outer Glow Pulse
                    Circle()
                        .stroke(themeManager.currentTheme.accent.opacity(0.2), lineWidth: 2)
                        .frame(width: 270, height: 270)
                        .scaleEffect(1.0 + pulseAmount)
                        .blur(radius: 15 * glowIntensity)

                    VStack(spacing: -10) {
                        Text(formatTime(currentTime, format: "HH:mm"))
                            .font(.system(size: 80, weight: .thin, design: .monospaced))
                            .foregroundColor(.white)
                            .kerning(2)

                        Text(formatTime(currentTime, format: "ss"))
                            .font(.system(size: 100, weight: .ultraLight, design: .monospaced))
                            .foregroundColor(themeManager.currentTheme.accent)
                            .kerning(8)
                            .shadow(color: themeManager.currentTheme.accent, radius: 20 * glowIntensity)
                    }
                }
                .padding(.vertical, 60)

                // Glassmorphism Theme Picker
                VStack(spacing: 15) {
                    Text("LUXURY STYLE")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.gray)
                        .kerning(2)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(ThemeManager.themes) { theme in
                                ThemeCard(theme: theme, isSelected: themeManager.currentTheme.id == theme.id)
                                    .onTapGesture {
                                        withAnimation(.spring()) {
                                            themeManager.currentTheme = theme
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal, 30)
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .onReceive(timer) { input in
            currentTime = input
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                pulseAmount = 0.05
            }
        }
        .overlay(settingsOverlay)
    }

    // --- Animated Settings Menu ---
    @ViewBuilder
    var settingsOverlay: some View {
        if showSettings {
            ZStack {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture { withAnimation { showSettings = false } }

                VStack(spacing: 30) {
                    Text("SYSTEM TUNING")
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(themeManager.currentTheme.accent)
                        .kerning(3)

                    VStack(spacing: 20) {
                        FuturisticSlider(label: "RING WIDTH", value: $ringSpeed, range: 0.5...2.0, accent: themeManager.currentTheme.accent)
                        FuturisticSlider(label: "GLOW INTENSITY", value: $glowIntensity, range: 0.1...2.0, accent: themeManager.currentTheme.accent)
                    }
                    .padding(30)
                    .background(.ultraThinMaterial)
                    .cornerRadius(30)
                    .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color.white.opacity(0.1), lineWidth: 1))
                }
                .frame(width: 320)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            .zIndex(10)
        }
    }

    func formatTime(_ date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}

struct ThemeCard: View {
    let theme: LuxuryTheme
    let isSelected: Bool

    var body: some View {
        VStack {
            Circle()
                .fill(theme.accent)
                .frame(width: 50, height: 50)
                .shadow(color: theme.accentGlow, radius: isSelected ? 15 : 0)
                .scaleEffect(isSelected ? 1.2 : 1.0)

            Text(theme.name)
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundColor(isSelected ? .white : .gray)
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 20)
        .background(isSelected ? theme.accent.opacity(0.2) : Color.white.opacity(0.05))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isSelected ? theme.accent : Color.white.opacity(0.1), lineWidth: isSelected ? 2 : 1)
        )
        .animation(.spring(), value: isSelected)
    }
}

struct FuturisticSlider: View {
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(label)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.gray)
                    .kerning(1)
                Spacer()
                Text(String(format: "%.1f", value))
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(accent)
            }

            Slider(value: $value, in: range)
                .accentColor(accent)
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6: // RGB (24-bit)
            (r, g, b) = ( (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF )
        case 8: // RGB(A) (32-bit)
            (r, g, b) = ( (int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF )
        default:
            (r, g, b) = (128, 128, 128)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1.0
        )
    }
}
