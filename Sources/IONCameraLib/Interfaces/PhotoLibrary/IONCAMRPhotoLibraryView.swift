import PhotosUI
import SwiftUI

struct IONCAMRPhotoLibraryView: View {
    /// Photo library will ask for permission to ask the user for Photo access, and will provide the photos as well.
    @EnvironmentObject var photoLibraryService: IONCAMRPhotoLibraryService

    var allowMultipleSelection: Bool
    var limit = 0

    @State var selectedAssetArray = [PHAsset]()
    @State var showActionSheet = false
    @State var showLimitedPicker = false

    var body: some View {
        VStack {
            if !photoLibraryService.hasAccessToFullAlbum {
                Button {
                    showActionSheet = true
                } label: {
                    // swiftlint:disable:next line_length
                    (
                        Text(
                            "You've given \(Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? "") access to only a selected number of media. "
                        )
                        .foregroundColor(.gray)
                        + Text("Manage")
                    )
                    .padding()
                    .multilineTextAlignment(.leading)
                    .font(.subheadline)
                }
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .actionSheet(isPresented: $showActionSheet, content: {
                    ActionSheet(title: Text("Please select your option"), buttons: [
                        .default(Text("Change multimedia selection")) {
                            showLimitedPicker = true
                            selectedAssetArray = []
                        },
                        .default(Text("Change settings")) {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        },
                        .cancel {
                            showActionSheet = false
                        }
                    ])
                })

                LimitedPicker(isPresented: $showLimitedPicker)
                    .frame(width: 0, height: 0)
            }

            if photoLibraryService.results.isEmpty {
                VStack(spacing: 16) {
                    Spacer()
                    Text("No Content")
                        .font(.title)
                    // swiftlint:disable:next line_length
                    Text(
                        "Currently, \(Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? "") doesn't have access to any media."
                    )
                    .font(.body)
                    Spacer()
                }
                .padding()
                .foregroundColor(.gray)
            } else {
                // We'll show the photo library in a grid
                ScrollViewReader { value in
                    ScrollView {
                        LazyVGrid(
                            // We'll set a 3-column row with an adaptive width of 100 for each grid item, and give it a spacing of 1 pixel in between
                            // columns and in between rows
                            columns: Array(repeating: .init(.adaptive(minimum: 100), spacing: 1), count: 3),
                            spacing: 1
                        ) {
                            // We'll go through the photo references fetched by the photo gallery and give a photo asset ID into the
                            // PhotoThumbnailView so it knows what image to load and show into the grid
                            ForEach(photoLibraryService.results, id: \.self) { asset in
                                ZStack(alignment: .bottomTrailing) {
                                    // Wrap the PhotoThumbnailView into a button so we can tap on it without overlapping the tap area of each photo,
                                    // as photos have their aspect ratios, and may go out of bounds of the square view.
                                    Button {
                                        if let assetIndex = selectedAssetArray.firstIndex(of: asset) {
                                            selectedAssetArray.remove(at: assetIndex)
                                        } else if allowMultipleSelection {
                                            if limit == 0 || selectedAssetArray.count < limit {
                                                selectedAssetArray.append(asset)
                                            }
                                        } else {
                                            selectedAssetArray = [asset]
                                        }
                                    } label: {
                                        IONCAMRPhotoThumbnailView(assetLocalId: asset.localIdentifier, showVideoIcon: asset.mediaType == .video)
                                            .opacity(selectedAssetArray.contains(asset) ? 0.5 : 1)
                                    }

                                    if selectedAssetArray.contains(asset) {
                                        Image(systemName: "checkmark.circle")
                                            .resizable()
                                            .frame(width: 25, height: 25)
                                            .foregroundColor(.white)
                                            .background(Color.blue)
                                            .clipShape(Circle())
                                            .offset(x: -5, y: -5)
                                    }
                                }
                            }
                        }
                        .onAppear {
                            value.scrollTo(photoLibraryService.results.startElement, anchor: .bottom)
                        }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    photoLibraryService.didCancelPicking()
                } label: {
                    Text("Cancel")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    photoLibraryService.didFinishPicking(selectedAssetArray)
                } label: {
                    Text("Done")
                        .bold()
                }
                .disabled(selectedAssetArray.isEmpty)
            }
        }
        .onAppear {
            photoLibraryService.fetchAllPhotos()
        }
    }
}

struct LimitedPicker: UIViewControllerRepresentable {
    @Binding var isPresented: Bool

    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isPresented {
            PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: uiViewController)
            DispatchQueue.main.async {
                isPresented = false
            }
        }
    }
}
