import SwiftUI

/// View that allows user interaction to perform the crop operation.
struct IONCAMRCropView: View {
    /// The original width of the image to crop.
    var imageWidth: CGFloat
    /// The original height of the image to crop.
    var imageHeight: CGFloat
    /// The dimensions and location of the image to crop.
    var imageRect: CGRect

    /// The In Progress offset value of the cropped image.
    @State private var activeOffset: CGSize = .zero
    /// The final offset value of the cropped image.
    @Binding var finalOffset: CGSize

    /// The In Progress width magnification value of the cropped image.
    @State private var activeWidthMagnification: CGFloat = 1.0
    /// The final width magnification value of the cropped image.
    @Binding var finalWidthMagnification: CGFloat

    /// The In Progress height magnification value of the cropped image.
    @State private var activeHeightMagnification: CGFloat = 1.0
    /// The final height magnification value of the cropped image.
    @Binding var finalHeightMagnification: CGFloat

    /// If a drag operation is in course, it indicates which corner, side or area is being dragged.
    @State private var currentDragState: DragState = .notDragging

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.clear

            // The black background view(s)
            Group {
                surroundingColour
                    .frame(width: activeOffset.width, height: imageHeight)

                surroundingColour
                    .frame(width: activeWidth, height: activeOffset.height)
                    .offset(x: activeOffset.width)

                surroundingColour
                    .frame(width: max(0, imageWidth - activeWidth - activeOffset.width), height: imageHeight)
                    .offset(x: activeWidth + activeOffset.width)

                surroundingColour
                    .frame(width: activeWidth, height: max(0, imageHeight - activeHeight - activeOffset.height))
                    .offset(x: activeOffset.width, y: activeHeight + activeOffset.height)
            }

            Rectangle()
                .frame(width: activeWidth, height: activeHeight)
                .foregroundColor(.white.opacity(0.05))
                .offset(activeOffset)
                .gesture(
                    DragGesture(coordinateSpace: .global)
                        .onChanged { drag in
                            let point = drag.location

                            if currentDragState == .notDragging {
                                currentDragState = isPanningACorner(point)
                                if currentDragState == .notDragging {
                                    currentDragState = isPanningASide(point)
                                    if currentDragState == .notDragging {
                                        currentDragState = isPanningArea(point)
                                    }
                                }
                            }

                            performDrag(drag.translation)
                        }
                        .onEnded { _ in
                            finalOffset = activeOffset
                            finalWidthMagnification = activeWidthMagnification
                            finalHeightMagnification = activeHeightMagnification
                            currentDragState = .notDragging
                        }
                )

            IONCAMRCropInternalView(offset: activeOffset, width: activeWidth, height: activeHeight)
            IONCAMRCropThickEdgesView(offset: activeOffset, width: activeWidth, height: activeHeight)
        }
    }
}

extension IONCAMRCropView {
    /// Enumerator that indicates which corner, side or area is being dragged.
    fileprivate enum DragState {
        // Corners
        case draggingTopLeftCorner
        case draggingTopRightCorner
        case draggingBottomLeftCorner
        case draggingBottomRightCorner

        // Edges
        case draggingTopEdge
        case draggingBottomEdge
        case draggingLeftEdge
        case draggingRightEdge

        case draggingArea

        case notDragging

        /// Creates the related `IONCAMRSideModel` object.
        ///
        /// Returns `nil` if dragging is not in progress.
        var toSideModel: IONCAMRSideModel? {
            switch self { // `mid` is assigned when the side doesn't impact the calculations
            case .draggingTopLeftCorner: .init(vertical: .top, horizontal: .left)
            case .draggingTopRightCorner: .init(vertical: .top, horizontal: .right)
            case .draggingBottomLeftCorner: .init(vertical: .bottom, horizontal: .left)
            case .draggingBottomRightCorner: .init(vertical: .bottom, horizontal: .right)
            case .draggingTopEdge: .init(vertical: .top, horizontal: .mid)
            case .draggingBottomEdge: .init(vertical: .bottom, horizontal: .mid)
            case .draggingLeftEdge: .init(vertical: .mid, horizontal: .left)
            case .draggingRightEdge: .init(vertical: .mid, horizontal: .right)
            case .draggingArea: .init(vertical: .mid, horizontal: .mid)
            case .notDragging: nil
            }
        }
    }

    /// The offset that helps identify which corner or edge is being selected. It helps create an invisible rectangle around the selectable object.
    private var minimumEdgesOffset: CGFloat {
        20.0
    }

    /// The minimum height magnification that can be applied
    private var minimumHeightMagnification: CGFloat {
        max(70.0 / imageHeight, 0.4)
    }

    /// The minimum width magnifciation that can be applied
    private var minimumWidthMagnification: CGFloat {
        max(70.0 / imageWidth, 0.4)
    }

    /// The current width of the cropped image.
    private var activeWidth: CGFloat {
        imageWidth * activeWidthMagnification
    }

    /// The current height of the cropped image.
    private var activeHeight: CGFloat {
        imageHeight * activeHeightMagnification
    }

    /// Colour to apply to the outer background of the crop view.
    private var surroundingColour: Color {
        .black.opacity(0.45)
    }

    /// Adapts the crop view to the selected corner, edge or area, apply the translation passed.
    /// - Parameter translation: The total translation from the start of the drag gesture to its current event.
    private func performDrag(_ translation: CGSize) {
        if let sideModel = currentDragState.toSideModel {
            dragging(sideModel, translation)
        }
    }
}

// MARK: - Corner Verification

extension IONCAMRCropView {
    /// The Top Left Corner's location and dimensions.
    private var topLeftCornerRect: CGRect {
        .init(
            x: imageRect.minX + activeOffset.width - minimumEdgesOffset,
            y: imageRect.minY + activeOffset.height - minimumEdgesOffset,
            width: minimumEdgesOffset * 2.0,
            height: minimumEdgesOffset * 2.0
        )
    }

    /// The Top Right Corner's location and dimensions.
    private var topRightCornerRect: CGRect {
        .init(
            x: imageRect.minX + activeOffset.width + activeWidth - minimumEdgesOffset,
            y: imageRect.minY + activeOffset.height - minimumEdgesOffset,
            width: minimumEdgesOffset * 2.0,
            height: minimumEdgesOffset * 2.0
        )
    }

    /// The Bottom Left Corner's location and dimensions.
    private var bottomLeftCornerRect: CGRect {
        .init(
            x: imageRect.minX + activeOffset.width - minimumEdgesOffset,
            y: imageRect.minY + activeOffset.height + activeHeight - minimumEdgesOffset,
            width: minimumEdgesOffset * 2.0,
            height: minimumEdgesOffset * 2.0
        )
    }

    /// The Bottom Right Corner's location and dimensions.
    private var bottomRightCornerRect: CGRect {
        .init(
            x: imageRect.minX + activeOffset.width + activeWidth - minimumEdgesOffset,
            y: imageRect.minY + activeOffset.height + activeHeight - minimumEdgesOffset,
            width: minimumEdgesOffset * 2.0,
            height: minimumEdgesOffset * 2.0
        )
    }

    /// Verifies if the user is currently dragging one of the crop view's corners.
    ///
    /// If the passed point doesn't belong to any of the corners, it returns a `notDragging` state.
    /// - Parameter point: The location of the drag gesture’s current event.
    /// - Returns: Returns the corner the location belongs to, or `notDragging` otherwise.
    private func isPanningACorner(_ point: CGPoint) -> DragState {
        var result = DragState.notDragging

        if topLeftCornerRect.contains(point) {
            result = .draggingTopLeftCorner
        } else if topRightCornerRect.contains(point) {
            result = .draggingTopRightCorner
        } else if bottomLeftCornerRect.contains(point) {
            result = .draggingBottomLeftCorner
        } else if bottomRightCornerRect.contains(point) {
            result = .draggingBottomRightCorner
        }

        return result
    }
}

// MARK: - Edge Verification Logic

extension IONCAMRCropView {
    /// The Top Edge Corner's location and dimensions.
    private var topEdgeRect: CGRect {
        .init(
            x: imageRect.minX + activeOffset.width,
            y: imageRect.minY + activeOffset.height - minimumEdgesOffset,
            width: activeWidth,
            height: minimumEdgesOffset * 2
        )
    }

    /// The Bottom Edge Corner's location and dimensions.
    private var bottomEdgeRect: CGRect {
        .init(
            x: imageRect.minX + activeOffset.width,
            y: imageRect.minY + activeOffset.height + activeHeight - minimumEdgesOffset,
            width: activeWidth,
            height: minimumEdgesOffset * 2
        )
    }

    /// The Left Edge Corner's location and dimensions.
    private var leftEdgeRect: CGRect {
        .init(
            x: imageRect.minX + activeOffset.width - minimumEdgesOffset,
            y: imageRect.minY + activeOffset.height,
            width: minimumEdgesOffset * 2,
            height: activeHeight
        )
    }

    /// The Right Edge Corner's location and dimensions.
    private var rightEdgeRect: CGRect {
        .init(
            x: imageRect.minX + activeOffset.width + activeWidth - minimumEdgesOffset,
            y: imageRect.minY + activeOffset.height,
            width: minimumEdgesOffset * 2,
            height: activeHeight
        )
    }

    /// Verifies if the user is currently dragging one of the crop view's edges.
    ///
    /// If the passed point doesn't belong to any of the edges, it returns a `notDragging` state.
    /// - Parameter point: The location of the drag gesture’s current event.
    /// - Returns: Returns the edge the location belongs to, or `notDragging` otherwise.
    private func isPanningASide(_ point: CGPoint) -> DragState {
        var result: DragState = .notDragging

        if topEdgeRect.contains(point) {
            result = .draggingTopEdge
        } else if bottomEdgeRect.contains(point) {
            result = .draggingBottomEdge
        } else if leftEdgeRect.contains(point) {
            result = .draggingLeftEdge
        } else if rightEdgeRect.contains(point) {
            result = .draggingRightEdge
        }

        return result
    }
}

// MARK: - Area Verification Logic

extension IONCAMRCropView {
    /// The Area's location and dimensions.
    private var areaRect: CGRect {
        .init(
            x: imageRect.minX + activeOffset.width,
            y: imageRect.minY + activeOffset.height,
            width: activeWidth,
            height: activeHeight
        )
    }

    /// Verifies if the user is currently dragging the crop view's area.
    ///
    /// If the passed point doesn't belong to the area, it returns a `notDragging` state.
    /// - Parameter point: The location of the drag gesture’s current event.
    /// - Returns: Returns the area if the point belongs to it, or `notDragging` otherwise.
    private func isPanningArea(_ point: CGPoint) -> DragState {
        areaRect.contains(point) ? .draggingArea : .notDragging
    }
}

// MARK: - Reusable Methods

extension IONCAMRCropView {
    /// Verifies if the passed `currentValue` is within the optional range values.
    ///
    /// It can return one of the following values:
    /// - `currentValue`, if it's within the range values or if these are not defined.
    /// - `minimumValue` if this is defined and `currentValue` is lower than it.
    /// - `maximumValue` if this is defined and `currentValue` is higher than it.
    ///
    /// - Parameters:
    ///   - currentValue: The value being evaluted.
    ///   - minimumValue: The lower range value. It can be `nil` in order to ignore its comparison with `currentValue`.
    ///   - maximumValue: The higher range value. It can be `nil` in order to ignore its comparison with `currentValue`.
    /// - Returns: Returns the value to use by the caller.
    private func setValueInRange(
        current currentValue: CGFloat,
        minimum minimumValue: CGFloat? = nil,
        andMaximum maximumValue: CGFloat? = nil
    )
        -> CGFloat {
        if let minimumValue, currentValue < minimumValue {
            minimumValue
        } else if let maximumValue, currentValue > maximumValue {
            maximumValue
        } else {
            currentValue
        }
    }

    /// Calculates the offsets to be used to calculate the required transformation.
    /// - Parameters:
    ///   - sideValue: Integer value associated to the which vertical or horizontal side is being dragged.
    ///   - activeOffset: The current offset value to base the drag on.
    ///   - transformationOffset: The offset to apply based on the transformation in progress.
    ///   - remainingSize: The remaining width or height that can still be applied based on the current offset.
    /// - Returns: A tuple containing the current left/top and right/bottom offsets.
    private func calculateOffsets(
        sideValue: Int,
        _ activeOffset: CGFloat,
        transformationOffset: CGFloat,
        remainingSize: CGFloat
    )
        -> (workingOffset: CGFloat?, belowOffset: CGFloat?) {
        var workingOffset: CGFloat?
        var belowOffset: CGFloat?

        if sideValue != IONCAMRSideModel.upperValue {
            var minimumValue: CGFloat?
            if sideValue == IONCAMRSideModel.lowerValue {
                minimumValue = 0.0
                belowOffset = activeOffset == remainingSize ? 0.0 : remainingSize - activeOffset
            }
            workingOffset = setValueInRange(current: transformationOffset, minimum: minimumValue)
        }

        return (workingOffset, belowOffset)
    }

    /// Calculates the new magnification value to apply to the crop view.
    /// - Parameters:
    ///   - sideValue: Integer value associated to the which vertical or horizontal side is being dragged.
    ///   - workingOffset: The left/top offset being used during the current operation.
    ///   - belowOffset: The right/bottom offset being used during the current operation. It's basically the offset between the end of the crop view
    /// and of the original image.
    ///   - currentSize: The original image's size.
    ///   - translation: The total translation from the start of the drag gesture to its current event.
    ///   - currentMagnification: The current magnification value.
    ///   - currentOffset: The current offset value.
    ///   - minimumMagnification: The minimum magnification value it can assume.
    /// - Returns: The value of the calculated magnification.
    private func calculateNewMagnification( // swiftlint:disable:this function_parameter_count
        sideValue: Int,
        _ workingOffset: CGFloat?,
        _ belowOffset: CGFloat?,
        currentSize: CGFloat,
        _ translation: CGFloat,
        currentMagnification: CGFloat,
        currentOffset: CGFloat,
        _ minimumMagnification: CGFloat
    )
        -> CGFloat? {
        guard sideValue == IONCAMRSideModel.lowerValue || sideValue == IONCAMRSideModel.upperValue else { return nil }

        let workingMagnification: CGFloat
        let maximumMagnification: CGFloat
        if let workingOffset, let belowOffset {
            workingMagnification = (currentSize - workingOffset - belowOffset) / currentSize
            maximumMagnification = 1.0
        } else {
            workingMagnification = translation / currentSize + currentMagnification
            maximumMagnification = (currentSize - currentOffset) / currentSize
        }

        return setValueInRange(current: workingMagnification, minimum: minimumMagnification, andMaximum: maximumMagnification)
    }

    /// Calculates the new offset to apply based on the drag gesture and corner/edge/area selected.
    /// - Parameters:
    ///   - sideValue: Integer value associated to the which vertical or horizontal side is being dragged.
    ///   - workingOffset: The left/top offset being used during the current operation.
    ///   - belowOffset: The right/bottom offset being used during the current operation. It's basically the offset between the end of the crop view
    /// and of the original image.
    ///   - remainingSize: The remaining width or height that can still be applied based on the current offset.
    /// - Returns: The new offset value to apply to the crop view.
    private func calculateNewOffset(sideValue: Int, _ workingOffset: CGFloat?, _ belowOffset: CGFloat?, remainingSize: CGFloat) -> CGFloat? {
        guard sideValue != IONCAMRSideModel.upperValue, let workingOffset else { return nil }

        var minimumValue: CGFloat?
        var maximumValue = remainingSize
        if let belowOffset {
            maximumValue -= belowOffset
        } else {
            minimumValue = 0.0
        }

        return setValueInRange(current: workingOffset, minimum: minimumValue, andMaximum: maximumValue)
    }

    /// Updates the offset and magnification values on the crop view to incorporate the drag gesture performed by the user.
    /// - Parameters:
    ///   - side: The corner/edge/area picker by the user's gesture.
    ///   - translation: The total translation from the start of the drag gesture to its current event.
    private func dragging(_ side: IONCAMRSideModel, _ translation: CGSize) {
        let xValues = calculateOffsets(
            sideValue: side.horizontal.rawValue,
            activeOffset.width,
            transformationOffset: finalOffset.width + translation.width,
            remainingSize: imageWidth - activeWidth
        )
        let yValues = calculateOffsets(
            sideValue: side.vertical.rawValue,
            activeOffset.height,
            transformationOffset: finalOffset.height + translation.height,
            remainingSize: imageHeight - activeHeight
        )

        updateActiveMagnification(side: side, xValues: xValues, yValues: yValues, translation: translation)
        updateActiveOffset(side: side, xValues: xValues, yValues: yValues)
    }

    private func updateActiveMagnification(
        side: IONCAMRSideModel,
        xValues: (workingOffset: CGFloat?, belowOffset: CGFloat?),
        yValues: (workingOffset: CGFloat?, belowOffset: CGFloat?),
        translation: CGSize
    ) {
        if let newMagnification = calculateNewMagnification(
            sideValue: side.horizontal.rawValue,
            xValues.workingOffset,
            xValues.belowOffset,
            currentSize: imageWidth,
            translation.width,
            currentMagnification: finalWidthMagnification,
            currentOffset: finalOffset.width,
            minimumWidthMagnification
        ) {
            activeWidthMagnification = newMagnification
        }
        if let newMagnification = calculateNewMagnification(
            sideValue: side.vertical.rawValue,
            yValues.workingOffset,
            yValues.belowOffset,
            currentSize: imageHeight,
            translation.height,
            currentMagnification: finalHeightMagnification,
            currentOffset: finalOffset.height,
            minimumHeightMagnification
        ) {
            activeHeightMagnification = newMagnification
        }
    }

    private func updateActiveOffset(
        side: IONCAMRSideModel,
        xValues: (workingOffset: CGFloat?, belowOffset: CGFloat?),
        yValues: (workingOffset: CGFloat?, belowOffset: CGFloat?)
    ) {
        if let newOffset = calculateNewOffset(
            sideValue: side.horizontal.rawValue, xValues.workingOffset, xValues.belowOffset, remainingSize: imageWidth - activeWidth
        ) {
            activeOffset.width = newOffset
        }
        if let newOffset = calculateNewOffset(
            sideValue: side.vertical.rawValue, yValues.workingOffset, yValues.belowOffset, remainingSize: imageHeight - activeHeight
        ) {
            activeOffset.height = newOffset
        }
    }
}
