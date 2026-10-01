import SwiftUI

let themeColorNames = ["Gray", "Blue", "Green", "Orange", "Purple", "Pink"]

func themeColor(_ name: String) -> Color {
    switch name {
    case "Blue":
        return .blue
    case "Green":
        return .green
    case "Orange":
        return .orange
    case "Purple":
        return .purple
    case "Pink":
        return .pink
    default:
        return .gray
    }
}

func cardFill(_ name: String) -> Color {
    themeColor(name).opacity(0.15)
}
