import SwiftUI
import UIKit
import Foundation

// GIF Loader utility
class GifLoader {
    static let shared = GifLoader()
    
    private init() {}
    
    // Cache for loaded GIF names
    private var cachedGifNames: [String]?
    
    /// Get all available GIF files from the Animations folder
    func getAvailableGifs() -> [String] {
        // Return cached names if available
        if let cached = cachedGifNames {
            return cached
        }
        
        var gifNames: [String] = []
        
        // Get all files in the bundle
        if let resourcePath = Bundle.main.resourcePath {
            do {
                let resourceContents = try FileManager.default.contentsOfDirectory(atPath: resourcePath)
                
                // Filter for GIF files
                gifNames = resourceContents
                    .filter { $0.lowercased().hasSuffix(".gif") }
                    .map { String($0.dropLast(4)) } // Remove .gif extension
                    .sorted() // Sort alphabetically
                
                print("Found GIFs: \(gifNames)")
            } catch {
                print("Error loading GIFs: \(error)")
            }
        }
        
        // Also check in the Animations subfolder specifically
        if let animationsPath = Bundle.main.path(forResource: "Animations", ofType: nil) {
            do {
                let animationContents = try FileManager.default.contentsOfDirectory(atPath: animationsPath)
                let animationGifs = animationContents
                    .filter { $0.lowercased().hasSuffix(".gif") }
                    .map { String($0.dropLast(4)) }
                
                // Merge and remove duplicates
                gifNames = Array(Set(gifNames + animationGifs)).sorted()
                print("Found GIFs in Animations folder: \(animationGifs)")
            } catch {
                print("Error loading GIFs from Animations folder: \(error)")
            }
        }
        
        // If no GIFs found, try to find them by scanning for all possible GIFs
        if gifNames.isEmpty {
            // Check for any GIF files as fallback
            let possibleGifs = ["lofi-girl", "lofi-girl-pixel", "snow", "rabbit", "rain", "study", "coffee", "night", "sunset", "city"]
            gifNames = possibleGifs.filter { gifName in
                Bundle.main.url(forResource: gifName, withExtension: "gif") != nil
            }
            if !gifNames.isEmpty {
                print("Found GIFs using fallback scan: \(gifNames)")
            }
        }
        
        // Cache the results
        cachedGifNames = gifNames
        
        return gifNames
    }
    
    /// Clear the cache (useful if GIFs are added dynamically)
    func clearCache() {
        cachedGifNames = nil
    }
    
    /// Check if a specific GIF exists
    func gifExists(_ name: String) -> Bool {
        return Bundle.main.url(forResource: name, withExtension: "gif") != nil
    }
    
    /// Get display name for a GIF (formats the filename nicely)
    func getDisplayName(for gifName: String) -> String {
        // Convert snake_case or kebab-case to Title Case
        let words = gifName
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "-", with: " ")
            .split(separator: " ")
            .map { word in
                word.prefix(1).uppercased() + word.dropFirst().lowercased()
            }
            .joined(separator: " ")
        
        return words
    }
    
    /// Get file size of a GIF
    func getFileSize(for gifName: String) -> String? {
        guard let url = Bundle.main.url(forResource: gifName, withExtension: "gif"),
              let attributes = try? FileManager.default.attributesOfItem(atPath: url.path),
              let fileSize = attributes[.size] as? Int64 else {
            return nil
        }
        
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: fileSize)
    }
    
    /// Get thumbnail data for a GIF (first frame)
    func getThumbnailData(for gifName: String) -> Data? {
        guard let url = Bundle.main.url(forResource: gifName, withExtension: "gif"),
              let data = try? Data(contentsOf: url) else {
            return nil
        }
        
        return data
    }
}

enum GifDisplayMode: String, CaseIterable {
    case fill = "fill"
    case fit = "fit"
    case stretch = "stretch"
    case original = "original"
    
    var displayName: String {
        switch self {
        case .fill:
            return "Fill Screen"
        case .fit:
            return "Fit to Screen"
        case .stretch:
            return "Stretch"
        case .original:
            return "Original Size"
        }
    }
    
    var description: String {
        switch self {
        case .fill:
            return "Fills entire screen, may crop edges"
        case .fit:
            return "Fits within screen, may show borders"
        case .stretch:
            return "Stretches to fill, may distort"
        case .original:
            return "Shows at original size"
        }
    }
    
    var contentMode: UIView.ContentMode {
        switch self {
        case .fill:
            return .scaleAspectFill
        case .fit:
            return .scaleAspectFit
        case .stretch:
            return .scaleToFill
        case .original:
            return .center
        }
    }
}

struct GifGalleryView: View {
    @ObservedObject var userSettings: UserSettings
    @Environment(\.dismiss) private var dismiss
    @State private var availableGifs: [String] = []
    @State private var selectedGif: String = ""
    @State private var selectedDisplayMode: GifDisplayMode = .fill
    @State private var customScale: CGFloat = 1.0
    @State private var offsetX: CGFloat = 0
    @State private var offsetY: CGFloat = 0
    
    private let gifLoader = GifLoader.shared
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Current GIF Preview with controls
                    VStack(spacing: 16) {
                        Text("Preview")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        // Preview container
                        GeometryReader { geometry in
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.black.opacity(0.9))
                                
                                if !selectedGif.isEmpty {
                                    GifImageView(
                                        gifName: selectedGif,
                                        isAnimating: true,
                                        contentMode: selectedDisplayMode.contentMode
                                    )
                                    .frame(width: geometry.size.width, height: geometry.size.height)
                                    .scaleEffect(selectedDisplayMode == .original ? customScale : 1.0)
                                    .offset(x: offsetX, y: offsetY)
                                    .clipped()
                                }
                                
                                // Grid overlay for reference
                                GridOverlay()
                                    .opacity(0.1)
                            }
                        }
                        .frame(height: 240)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Display Mode Selector
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Display Mode")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(GifDisplayMode.allCases, id: \.self) { mode in
                                        DisplayModeButton(
                                            mode: mode,
                                            isSelected: selectedDisplayMode == mode,
                                            action: {
                                                withAnimation(.spring()) {
                                                    selectedDisplayMode = mode
                                                }
                                            }
                                        )
                                    }
                                }
                            }
                            
                            Text(selectedDisplayMode.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        // Scale control (only for original mode)
                        if selectedDisplayMode == .original {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Scale")
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Text("\(Int(customScale * 100))%")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .monospacedDigit()
                                }
                                
                                Slider(value: $customScale, in: 0.5...3.0)
                                    .tint(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(red: 1.0, green: 0.7, blue: 0.5),
                                                Color(red: 0.8, green: 0.5, blue: 1.0)
                                            ]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            }
                        }
                        
                        // Position adjustment
                        if selectedDisplayMode == .original || selectedDisplayMode == .fit {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Position Adjustment")
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                
                                HStack(spacing: 20) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Horizontal")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Slider(value: $offsetX, in: -100...100)
                                            .frame(width: 140)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Vertical")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Slider(value: $offsetY, in: -100...100)
                                            .frame(width: 140)
                                    }
                                }
                                
                                Button(action: {
                                    withAnimation(.spring()) {
                                        offsetX = 0
                                        offsetY = 0
                                    }
                                }) {
                                    Text("Reset Position")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(UIColor.secondarySystemBackground))
                    )
                    .padding(.horizontal)
                    
                    // GIF Gallery
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Choose Background")
                                .font(.headline)
                            
                            Spacer()
                            
                            Text("\(availableGifs.count) GIFs")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        
                        if availableGifs.isEmpty {
                            // Empty state
                            VStack(spacing: 20) {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray)
                                
                                Text("No GIFs Found")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                Text("Add GIF files to the Resources/Animations folder")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 50)
                        } else {
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(availableGifs, id: \.self) { gifName in
                                    GifThumbnailCard(
                                        gifName: gifName,
                                        isSelected: gifName == selectedGif,
                                        onTap: {
                                            withAnimation(.spring()) {
                                                selectedGif = gifName
                                            }
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("GIF Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Button(action: {
                        // Refresh GIF list
                        gifLoader.clearCache()
                        loadAvailableGifs()
                    }) {
                        Label("Refresh", systemImage: "arrow.clockwise")
                            .labelStyle(.iconOnly)
                            .font(.system(size: 16))
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        userSettings.selectedGif = selectedGif
                        userSettings.gifDisplayMode = selectedDisplayMode.rawValue
                        userSettings.gifScale = Double(customScale)
                        userSettings.gifOffsetX = Double(offsetX)
                        userSettings.gifOffsetY = Double(offsetY)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            loadAvailableGifs()
            selectedGif = userSettings.selectedGif
            selectedDisplayMode = GifDisplayMode(rawValue: userSettings.gifDisplayMode) ?? .fill
            customScale = CGFloat(userSettings.gifScale)
            offsetX = CGFloat(userSettings.gifOffsetX)
            offsetY = CGFloat(userSettings.gifOffsetY)
        }
    }
    
    private func loadAvailableGifs() {
        // Automatically load all GIFs from the bundle
        availableGifs = gifLoader.getAvailableGifs()
        
        // If no GIFs found, show a message
        if availableGifs.isEmpty {
            print("Warning: No GIF files found in the bundle")
        } else {
            print("Loaded \(availableGifs.count) GIFs: \(availableGifs)")
        }
    }
}

struct DisplayModeButton: View {
    let mode: GifDisplayMode
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: iconName)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .white : .primary)
                
                Text(mode.displayName)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(width: 80, height: 60)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? 
                          LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 1.0, green: 0.7, blue: 0.5),
                                Color(red: 0.8, green: 0.5, blue: 1.0)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                          ) : 
                          LinearGradient(
                            gradient: Gradient(colors: [
                                Color.gray.opacity(0.1),
                                Color.gray.opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                          )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var iconName: String {
        switch mode {
        case .fill:
            return "rectangle.fill"
        case .fit:
            return "rectangle.arrowtriangle.2.inward"
        case .stretch:
            return "arrow.up.left.and.arrow.down.right"
        case .original:
            return "circle.grid.2x2"
        }
    }
}

struct GridOverlay: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                let gridSize: CGFloat = 20
                
                // Vertical lines
                for i in stride(from: 0, through: width, by: gridSize) {
                    path.move(to: CGPoint(x: i, y: 0))
                    path.addLine(to: CGPoint(x: i, y: height))
                }
                
                // Horizontal lines
                for i in stride(from: 0, through: height, by: gridSize) {
                    path.move(to: CGPoint(x: 0, y: i))
                    path.addLine(to: CGPoint(x: width, y: i))
                }
            }
            .stroke(Color.white.opacity(0.5), lineWidth: 0.5)
        }
    }
}

struct GifThumbnailCard: View {
    let gifName: String
    let isSelected: Bool
    let onTap: () -> Void
    
    private let gifLoader = GifLoader.shared
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                // GIF Preview
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.black.opacity(0.8))
                    
                    if gifLoader.gifExists(gifName) {
                        GifImageView(gifName: gifName, isAnimating: false, contentMode: .scaleAspectFit)
                            .padding(8)
                    } else {
                        VStack {
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                        }
                        .padding()
                    }
                    
                    if isSelected {
                        VStack {
                            HStack {
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .background(
                                        Circle()
                                            .fill(LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color(red: 1.0, green: 0.7, blue: 0.5),
                                                    Color(red: 0.8, green: 0.5, blue: 1.0)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ))
                                            .padding(-2)
                                    )
                                    .padding(8)
                            }
                            Spacer()
                        }
                    }
                }
                .aspectRatio(1.0, contentMode: .fit)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? 
                               LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 1.0, green: 0.7, blue: 0.5),
                                    Color(red: 0.8, green: 0.5, blue: 1.0)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                               ) : 
                               LinearGradient(
                                gradient: Gradient(colors: [Color.clear, Color.clear]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                               ), 
                               lineWidth: isSelected ? 3 : 0)
                )
                
                // GIF Name and info
                VStack(spacing: 4) {
                    Text(gifLoader.getDisplayName(for: gifName))
                        .font(.caption)
                        .fontWeight(isSelected ? .medium : .regular)
                        .foregroundColor(isSelected ? .primary : .secondary)
                        .lineLimit(1)
                    
                    if let fileSize = gifLoader.getFileSize(for: gifName) {
                        Text(fileSize)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(UIColor.secondarySystemBackground))
                )
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    GifGalleryView(userSettings: UserSettings())
}