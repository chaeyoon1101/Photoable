import Foundation
import Photos

struct AlbumModel {
    let asset: PHFetchResult<PHAsset>
    let identifier: String
    let title: String
    let count: Int
    let albumType: String
}
