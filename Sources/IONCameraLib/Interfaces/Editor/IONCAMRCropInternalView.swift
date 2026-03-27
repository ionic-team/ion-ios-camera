import SwiftUI

/// View divides the crop view into 9 equal rectangles.
///
/// The division is done by drawing the outher rectangle and two other, one with a 3rd of the width and another with a 3rd of the height.
struct IONCAMRCropInternalView: View {
    /// Base offset values to draw the rectangles from.
    var offset: CGSize
    /// Base width to draw the rectangles with.
    var width: CGFloat
    /// Base height to draw the rectangles with.
    var height: CGFloat

    /// Size of the stroke line
    private let lineWidth: CGFloat = 1.0
    /// Colour to use as foreground color for the rectangles.
    private let foregroundColour: Color = .white
    /// Opacity to apply to the internal rectangles.
    private let thinOpacity: CGFloat = 0.6

    var body: some View {
        Group {
            // These views create the white grid
            // This view creates the outer square
            Rectangle()
                .stroke(lineWidth: lineWidth)
                .frame(width: width, height: height)
                .foregroundColor(foregroundColour)
                .offset(offset)

            // This view creates a thin rectangle in the center that is 1/3 the outer square's width
            Rectangle()
                .stroke(lineWidth: lineWidth)
                .frame(width: width / 3, height: height)
                .foregroundColor(foregroundColour.opacity(thinOpacity))
                .offset(x: offset.width + width / 3, y: offset.height)

            // This view creates a thin rectangle in the center that is 1/3 the outer square's height
            Rectangle()
                .stroke(lineWidth: lineWidth)
                .frame(width: width, height: height / 3)
                .foregroundColor(foregroundColour.opacity(thinOpacity))
                .offset(x: offset.width, y: offset.height + height / 3)
        }
    }
}
