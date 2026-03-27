import SwiftUI

/// View that allows the image edit operation. It allows operations like cropping, rotating or mirroring.
struct IONCAMRImageEditorView: View {
    /// Allows the return of the resulting image to its caller.
    weak var delegate: IONCAMRImageEditorResultsDelegate?
    /// The image being edited.
    @State var image: UIImage
    /// Indicates if the device is in Portrait or Landspace mode.
    @State var isPortrait: Bool

    /// The original image's width dimension
    @State private var imageWidth: CGFloat = 0.0
    /// The original image's height dimension
    @State private var imageHeight: CGFloat = 0.0
    /// The original image's location and dimensions.
    @State private var imageRect: CGRect = .zero

    /// The offset to perform the crop on the image.
    @State private var croppingOffset: CGSize = .zero
    /// The width magnification value to perform the crop on the image.
    @State private var croppingWidthMagnification: CGFloat = 1.0
    /// The height magnification value to perform the crop on the image.
    @State private var croppingHeightMagnification: CGFloat = 1.0

    /// `IONCAMRCropView`'s ID. Its goal is to indicate that changes need to be propagated some changes are performed by the user (p.e., device or
    /// image rotation, mirroring, ...).
    @State private var viewID = 0

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack(spacing: 20.0) {
                // If device is in Landscape, the bar is shown on top.
                if !isPortrait {
                    bar
                }

                DynamicStack(showHorizontalStack: !isPortrait) {
                    Spacer()
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .overlay(GeometryReader { geo -> AnyView in
                            DispatchQueue.main.async {
                                imageWidth = geo.size.width
                                imageHeight = geo.size.height
                                imageRect = geo.frame(in: .global)
                            }

                            return AnyView(IONCAMRCropView(
                                imageWidth: imageWidth,
                                imageHeight: imageHeight,
                                imageRect: imageRect,
                                finalOffset: $croppingOffset,
                                finalWidthMagnification: $croppingWidthMagnification,
                                finalHeightMagnification: $croppingHeightMagnification
                            ).id(viewID))
                        })

                    Spacer()
                    DynamicStack(showHorizontalStack: isPortrait, spacing: 50.0) {
                        Button {
                            if let fixedImage = image.fixOrientation() {
                                image = fixedImage.flippedHorizontally()
                            }
                        } label: {
                            IONCAMRAssets.bundleImage(IONCAMRAssets.ImageEditor.flip)
                        }

                        Button {
                            image = image.rotate(radians: CGFloat.pi / -2.0)
                            croppingOffset = .zero
                            croppingWidthMagnification = 1.0
                            croppingHeightMagnification = 1.0
                            viewID += 1
                        } label: {
                            IONCAMRAssets.bundleImage(IONCAMRAssets.ImageEditor.rotate)
                        }
                    }
                }

                // If device is in Portrait, the bar is shown on the bottom.
                if isPortrait {
                    bar
                }
            }
            .padding()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            guard isPortrait != UIApplication.shared.windows.first?.windowScene?.interfaceOrientation.isPortrait else { return }
            isPortrait.toggle()
            croppingOffset = .init(width: 0.0, height: 0.0)
            croppingWidthMagnification = 1.0
            croppingHeightMagnification = 1.0
            viewID += 1
        }
    }

    var bar: some View {
        HStack {
            Button {
                delegate?.didCancelEdit()
            } label: {
                Text("Cancel")
            }

            Spacer()

            Button {
                Task {
                    guard let cgImage = image.cgImage else {
                        await delegate?.finishEditing(with: .editPictureIssue) // it wasn't possible to retrieve the image, so an error is returned.
                        return
                    }
                    let scaler = CGSize(width: CGFloat(cgImage.width) / imageWidth, height: CGFloat(cgImage.height) / imageHeight)
                    let dim = CGSize(width: cgImage.width, height: cgImage.height)
                    let cropRect = CGRect(
                        x: croppingOffset.width * scaler.width,
                        y: croppingOffset.height * scaler.height,
                        width: dim.width * croppingWidthMagnification,
                        height: dim.height * croppingHeightMagnification
                    )

                    if let cImage = cgImage.cropping(to: cropRect) {
                        let croppedImage = UIImage(cgImage: cImage)
                        await delegate?.finishEditing(with: croppedImage) // the resulting cropped image is returned.
                    } else {
                        await delegate?.finishEditing(with: .editPictureIssue) // it wasn't possible to retrieve the image, so an error is returned.
                    }
                }
            } label: {
                Text("Done")
                    .bold()
            }
        }
        .padding()
        .foregroundColor(.white)
    }
}

extension UIImage {
    /// Rotates the image with the passed radians.
    /// - Parameter radians: The radians value to rotate the image.
    /// - Returns: The rotated image.
    fileprivate func rotate(radians: CGFloat) -> UIImage {
        let rotatedSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
            .integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        guard let context = UIGraphicsGetCurrentContext() else { return self }

        let origin = CGPoint(x: rotatedSize.width / 2.0, y: rotatedSize.height / 2.0)
        context.translateBy(x: origin.x, y: origin.y)
        context.rotate(by: radians)
        draw(in: CGRect(x: -origin.y, y: -origin.x, width: size.width, height: size.height))
        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return rotatedImage ?? self
    }

    /// Flips the image horizontally.
    /// - Returns: The flipped image.
    fileprivate func flippedHorizontally() -> UIImage {
        guard let cgImage else { return self }

        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return self
        }
        context.translateBy(x: size.width, y: size.height)
        context.scaleBy(x: -scale, y: -scale)
        context.draw(cgImage, in: CGRect(origin: .zero, size: size))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage ?? self
    }
}

/// A view that constructs an Horizontal or Vertical Stack based on its parameters.
private struct DynamicStack<Content: View>: View {
    /// Indicates if an `HStack` should be returned as the view's body.
    var showHorizontalStack: Bool
    /// Spacing to apply to the `HStack`or `VStack`
    var spacing: CGFloat?
    /// The content to display on the `HStack` or `VStack`.
    @ViewBuilder var content: () -> Content

    var body: some View {
        if showHorizontalStack {
            HStack(spacing: spacing, content: content)
        } else {
            VStack(spacing: spacing, content: content)
        }
    }
}
