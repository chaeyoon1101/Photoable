//
//  AlbumModel.swift
//  Photoable
//
//  Created by 임채윤 on 2023/02/13.
//

import Foundation
import Photos

struct AlbumModel {
    let asset: PHFetchResult<PHAsset>
    let title: String
    let count: Int
    let albumType: String
}
