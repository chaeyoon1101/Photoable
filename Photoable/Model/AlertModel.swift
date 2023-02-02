//
//  AlertModel.swift
//  Photoable
//
//  Created by 임채윤 on 2023/02/01.
//

import Foundation
import UIKit

struct AlertModel {
    let title: String
    let style: UIAlertAction.Style
    let handler: (UIAlertAction) -> Void
}
