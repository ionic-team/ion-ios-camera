import SwiftUI

/// Centralized asset management
public enum IONCAMRAssets {
    /// System icons used in the image editor
    public enum ImageEditor {
        /// Horizontal flip icon
        public static let flip = "flip"

        /// 90-degree rotation icon
        public static let rotate = "rotate"
    }

    /// Create an Image view from bundle asset name
    ///
    /// - Parameter name: The asset name in the bundle
    /// - Returns: SwiftUI Image view
    public static func bundleImage(_ name: String) -> Image {
        #if SWIFT_PACKAGE
            return Image(name, bundle: .module)
        #else
            if let bundle = resourceBundle {
                return Image(name, bundle: bundle)
            } else {
                return Image(name)
            }
        #endif
    }

    /// Helper to find the CocoaPods resource bundle
    private static var resourceBundle: Bundle? {
        if let url = Bundle.module.url(forResource: "IONCameraLibResources", withExtension: "bundle") {
            return Bundle(url: url)
        }
        return nil
    }
}

#if !SWIFT_PACKAGE

    // MARK: - Bundle Extension for non-SPM builds

    extension Bundle {
        /// IONCameraLib module bundle for non-SPM builds
        static var module: Bundle {
            Bundle(for: IONCAMRCameraManager.self)
        }
    }
#endif
