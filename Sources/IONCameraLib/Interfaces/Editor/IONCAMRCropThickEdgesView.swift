import SwiftUI

/// Draws all the corner/edges think lines on the Crop View. These lines represent the marks the user can interact with to perform the crop operation.
struct IONCAMRCropThickEdgesView: View {
    /// Base offset values to draw the lines from.
    var offset: CGSize
    /// Base width to draw the lines with.
    var width: CGFloat
    /// Base height to draw the lines with.
    var height: CGFloat

    var body: some View {
        // Top
        IONCAMRCropThickView(
            offset: offset,
            width: width,
            height: height,
            side: .init(vertical: .top, horizontal: .left)
        )
        IONCAMRCropThickView(
            offset: offset,
            width: width,
            height: height,
            side: .init(vertical: .top, horizontal: .mid)
        )
        IONCAMRCropThickView(
            offset: offset,
            width: width,
            height: height,
            side: .init(vertical: .top, horizontal: .right)
        )

        // Mid
        IONCAMRCropThickView(
            offset: offset,
            width: width,
            height: height,
            side: .init(vertical: .mid, horizontal: .left)
        )
        IONCAMRCropThickView(
            offset: offset,
            width: width,
            height: height,
            side: .init(vertical: .mid, horizontal: .right)
        )

        // Bottom
        IONCAMRCropThickView(
            offset: offset,
            width: width,
            height: height,
            side: .init(vertical: .bottom, horizontal: .left)
        )
        IONCAMRCropThickView(
            offset: offset,
            width: width,
            height: height,
            side: .init(vertical: .bottom, horizontal: .mid)
        )
        IONCAMRCropThickView(
            offset: offset,
            width: width,
            height: height,
            side: .init(vertical: .bottom, horizontal: .right)
        )
    }
}
