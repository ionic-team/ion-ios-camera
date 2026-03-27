import SwiftUI

/// View that draws the necessary lines for the interactive edges / corners
struct IONCAMRCropThickView: View {
    /// Base offset values to draw the lines from.
    var offset: CGSize
    /// Base width to draw the lines with.
    var width: CGFloat
    /// Base height to draw the lines with.
    var height: CGFloat
    /// Side being drawn.
    var side: IONCAMRSideModel

    /// Width for the stroke of the line to be drawn.
    private let stroke: CGFloat = 3.0
    /// Biggest width or height of the line to draw. The length to use depends on the side.
    private let biggestLength: CGFloat = 20.0
    /// Smallest width or height of the line to draw The length to use depends on the side.
    private let smallestLength: CGFloat = 1.0
    /// Colour to use as foreground color for the lines.
    private let foregroundColour: Color = .white

    var body: some View {
        Group {
            if side.vertical != .mid {
                Rectangle()
                    .stroke(lineWidth: stroke)
                    .frame(width: biggestLength, height: smallestLength)
                    .foregroundColor(foregroundColour)
                    .offset(topBottomOffset)
            }

            if side.horizontal != .mid {
                Rectangle()
                    .stroke(lineWidth: stroke)
                    .frame(width: smallestLength, height: biggestLength)
                    .foregroundColor(foregroundColour)
                    .offset(leftRightOffset)
            }
        }
    }
}

extension IONCAMRCropThickView {
    /// Enumerator indicating which side to consider
    fileprivate enum Side {
        case vertical
        case horizontal
    }

    /// Retrieves the offset for the biggest side.
    /// - Parameters:
    ///   - extra: Value to add on top of the current offset.
    ///   - sideValue: Value representation of the side being considered.
    /// - Returns: The calculated offset to use.
    private func getMajorExtraOffset(for extra: CGFloat, and sideValue: Int) -> CGFloat {
        sideValue != IONCAMRSideModel.lowerValue ? extra : 0.0
    }

    /// Retrieves the offset for the smallest side.
    /// - Parameters:
    ///   - extra: Value to add on top of the current offset.
    ///   - sideValue: Value representation of the side being considered.
    /// - Returns: The calculated offset to use.
    private func getMinorExtraOffset(for extra: CGFloat, and sideValue: Int) -> CGFloat {
        if sideValue != IONCAMRSideModel.lowerValue {
            extra / (sideValue != IONCAMRSideModel.lowerValue && sideValue != IONCAMRSideModel.upperValue ? 1.0 : 2.0)
        } else {
            0.0
        }
    }

    /// Retrivies the offset for the line.
    /// - Parameters:
    ///   - offsetSide: Indicates if its the horizontal or vertical side.
    ///   - offset: The base offset to apply.
    /// - Returns: The calculated offset to use.
    private func getOffset(for offsetSide: Side, with offset: CGSize) -> CGSize {
        var result = offset

        if offsetSide == .vertical {
            result.width += getMinorExtraOffset(for: width - biggestLength, and: side.horizontal.rawValue)
            result.height += getMajorExtraOffset(for: height, and: side.vertical.rawValue)
        } else {
            result.width += getMajorExtraOffset(for: width, and: side.horizontal.rawValue)
            result.height += getMinorExtraOffset(for: height - biggestLength, and: side.vertical.rawValue)
        }

        return result
    }

    /// Vertical offset to apply.
    private var topBottomOffset: CGSize {
        getOffset(for: .vertical, with: offset)
    }

    /// Horizontal offset to apply.
    private var leftRightOffset: CGSize {
        getOffset(for: .horizontal, with: offset)
    }
}
