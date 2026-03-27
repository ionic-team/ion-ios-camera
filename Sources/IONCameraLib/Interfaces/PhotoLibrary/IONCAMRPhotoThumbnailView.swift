import Photos
import SwiftUI

/// The photo thumbnail view is responsible for showing a photo in the photo grid.
struct IONCAMRPhotoThumbnailView: View {
    /// The image view that will render the photo that we'll be fetching. It is set to optional since we don't have an actual photo when this view
    /// starts to render.
    ///
    /// We need to give time for the photo library service to fetch a copy of the photo using the asset id, so we'll set the image with the fetched
    /// photo at a later time.
    ///
    /// Fetching make take time, especially if the photo has been requested initially. However, photos that were successfully fetched are cached, so
    /// any fetching from that point forward will be fast.
    ///
    /// Also, we would want to free up the image from the memory when this view disappears in order to save up memory.
    @State private var image: Image?

    /// We'll use the photo library service to fetch a photo given an asset id, and cache it for later use. If the photo is already cached, a cached
    /// copy will be provided instead.
    ///
    /// Ideally, we don't want to store a reference to an image itself and pass it around views as it would cost memory.
    /// We'll use the asset id instead as a reference, and allow the photo library's cache to handle any memory management for us.
    @EnvironmentObject var photoLibraryService: IONCAMRPhotoLibraryService

    /// The reference id of the selected photo
    private let assetLocalId: String
    private let showVideoIcon: Bool

    init(assetLocalId: String, showVideoIcon: Bool) {
        self.assetLocalId = assetLocalId
        self.showVideoIcon = showVideoIcon
    }

    var body: some View {
        Group {
            // Show the image if it's available
            if let image {
                ZStack(alignment: .bottomLeading) {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipped()
                    if showVideoIcon {
                        Image(systemName: "video.fill")
                            .resizable()
                            .frame(width: 15, height: 10)
                            .foregroundColor(.white)
                            .offset(x: 5, y: -5)
                    }
                }
            } else {
                ZStack {
                    // Otherwise, show a gray rectangle with a spinning progress view
                    Rectangle()
                        .foregroundColor(.gray)
                        .aspectRatio(1, contentMode: .fit)
                    ProgressView()
                }
            }
        }
        // We need to use the task to work on a concurrent request to load the image from the photo library service, which is asynchronous work.
        .taskOperation {
            await loadImageAsset()
        }
        // Finally, when the view disappears, we need to free it up from the memory
        .onDisappear {
            image = nil
        }
    }
}

extension IONCAMRPhotoThumbnailView {
    func loadImageAsset() async {
        guard let uiImage = try? await photoLibraryService.fetchImage(
            byLocalIdentifier: assetLocalId,
            targetSize: CGSize(width: 150, height: 150),
            contentMode: .aspectFill
        ) else {
            image = nil
            return
        }
        image = Image(uiImage: uiImage)
    }
}

extension View {
    func taskOperation(priority: TaskPriority = .userInitiated, _ action: @escaping @Sendable () async -> Void) -> some View {
        if #available(iOS 15, *) {
            return task(priority: priority, action)
        } else {
            return taskiOS14(priority: priority, action)
        }
    }

    @available(iOS, deprecated: 15.0, message: "This extension is no longer necessary. Use API built into SDK")
    func taskiOS14(priority: TaskPriority = .userInitiated, _ action: @escaping @Sendable () async -> Void) -> some View {
        onAppear {
            Task(priority: priority) {
                await action()
            }
        }
    }
}
