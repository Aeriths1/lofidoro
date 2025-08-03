import SwiftUI
import UIKit
import ImageIO

extension UIImage {
    static func gif(data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }
        
        let count = CGImageSourceGetCount(source)
        let delays = (0..<count).compactMap {
            CGImageSourceCopyPropertiesAtIndex(source, $0, nil) as? [String: Any]
        }.compactMap {
            $0[kCGImagePropertyGIFDictionary as String] as? [String: Any]
        }.compactMap {
            $0[kCGImagePropertyGIFDelayTime as String] as? Double
        }
        
        let duration = delays.reduce(0, +)
        
        let images = (0..<count).compactMap {
            CGImageSourceCreateImageAtIndex(source, $0, nil)
        }.map {
            UIImage(cgImage: $0)
        }
        
        let animatedImage = UIImage.animatedImage(with: images, duration: duration)
        return animatedImage
    }
}

struct GifImageView: UIViewRepresentable {
    let gifName: String
    let isAnimating: Bool
    let contentMode: UIView.ContentMode
    let playbackSpeed: Double
    
    init(gifName: String, isAnimating: Bool, contentMode: UIView.ContentMode = .scaleAspectFill, playbackSpeed: Double = 1.0) {
        self.gifName = gifName
        self.isAnimating = isAnimating
        self.contentMode = contentMode
        self.playbackSpeed = playbackSpeed
    }
    
    class Coordinator {
        var currentGifName: String = ""
        var currentPlaybackSpeed: Double = 1.0
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .clear
        
        let imageView = UIImageView()
        imageView.contentMode = contentMode
        imageView.clipsToBounds = true
        imageView.backgroundColor = .clear
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(imageView)
        
        // Pin imageView to container edges
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        loadGif(imageView: imageView)
        context.coordinator.currentGifName = gifName
        context.coordinator.currentPlaybackSpeed = playbackSpeed
        
        if isAnimating {
            imageView.startAnimating()
        }
        
        return containerView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let imageView = uiView.subviews.first as? UIImageView {
            // Check if GIF name or speed changed
            if context.coordinator.currentGifName != gifName || context.coordinator.currentPlaybackSpeed != playbackSpeed {
                print("GIF changed from \(context.coordinator.currentGifName) to \(gifName) or speed changed from \(context.coordinator.currentPlaybackSpeed) to \(playbackSpeed)")
                loadGif(imageView: imageView)
                context.coordinator.currentGifName = gifName
                context.coordinator.currentPlaybackSpeed = playbackSpeed
            }
            
            // Update content mode if changed
            imageView.contentMode = contentMode
            
            // Update animation state
            if isAnimating {
                imageView.startAnimating()
            } else {
                imageView.stopAnimating()
            }
        }
    }
    
    private func loadGif(imageView: UIImageView) {
        guard let url = Bundle.main.url(forResource: gifName, withExtension: "gif"),
              let data = try? Data(contentsOf: url) else {
            print("Failed to load GIF: \(gifName)")
            return
        }
        
        // Try using UIImage's built-in animated image support first
        if let animatedImage = UIImage.gif(data: data) {
            imageView.image = animatedImage
            print("Loaded GIF using UIImage.gif, size: \(animatedImage.size)")
            return
        }
        
        // Fallback to manual frame extraction
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            print("Failed to create image source")
            return
        }
        
        let count = CGImageSourceGetCount(source)
        var images: [UIImage] = []
        var duration: TimeInterval = 0
        
        // Get the actual pixel dimensions of the GIF
        if let properties = CGImageSourceCopyProperties(source, nil) as? [String: Any] {
            if let pixelWidth = properties[kCGImagePropertyPixelWidth as String] as? Int,
               let pixelHeight = properties[kCGImagePropertyPixelHeight as String] as? Int {
                print("GIF actual dimensions: \(pixelWidth)x\(pixelHeight)")
            }
        }
        
        for i in 0..<count {
            // Don't use any scaling options - get the raw image
            if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                // Create UIImage without any scale factor modification
                let image = UIImage(cgImage: cgImage, scale: 1.0, orientation: .up)
                images.append(image)
                
                if i == 0 {
                    print("First frame size: \(image.size), scale: \(image.scale)")
                }
                
                if let properties = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as? [String: Any],
                   let gifDict = properties[kCGImagePropertyGIFDictionary as String] as? [String: Any],
                   let delayTime = gifDict[kCGImagePropertyGIFDelayTime as String] as? NSNumber {
                    duration += delayTime.doubleValue
                }
            }
        }
        
        if !images.isEmpty {
            imageView.animationImages = images
            // Adjust duration based on playback speed (lower duration = faster playback)
            imageView.animationDuration = duration / playbackSpeed
            imageView.animationRepeatCount = 0
            imageView.image = images[0]
        }
    }
}

struct LofiGirlAnimationView: View {
    let isStudying: Bool
    let availableWidth: CGFloat
    let availableHeight: CGFloat
    let gifName: String
    let displayMode: String
    let scale: Double
    let offsetX: Double
    let offsetY: Double
    let playbackSpeed: Double
    
    var contentMode: UIView.ContentMode {
        switch displayMode {
        case "fill":
            return .scaleAspectFill
        case "fit":
            return .scaleAspectFit
        case "stretch":
            return .scaleToFill
        case "original":
            return .center
        default:
            return .scaleAspectFill
        }
    }
    
    var body: some View {
        // Full screen GIF background with customizable display mode
        GifImageView(gifName: gifName, isAnimating: true, contentMode: contentMode, playbackSpeed: playbackSpeed)
            .frame(width: availableWidth, height: availableHeight)
            .scaleEffect(displayMode == "original" ? CGFloat(scale) : 1.0)
            .offset(x: CGFloat(offsetX), y: CGFloat(offsetY))
            .clipped()
    }
}

#Preview {
    VStack(spacing: 20) {
        LofiGirlAnimationView(
            isStudying: true, 
            availableWidth: 300, 
            availableHeight: 200, 
            gifName: "lofi-girl",
            displayMode: "fill",
            scale: 1.0,
            offsetX: 0,
            offsetY: 0,
            playbackSpeed: 1.0
        )
        LofiGirlAnimationView(
            isStudying: false, 
            availableWidth: 300, 
            availableHeight: 200, 
            gifName: "lofi-girl",
            displayMode: "fit",
            scale: 1.0,
            offsetX: 0,
            offsetY: 0,
            playbackSpeed: 2.0
        )
    }
    .padding()
    .background(
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.05, green: 0.05, blue: 0.1),
                Color(red: 0.1, green: 0.1, blue: 0.2)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    )
}