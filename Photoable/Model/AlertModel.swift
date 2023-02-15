import UIKit

struct AlertModel {
    let title: String
    let style: UIAlertAction.Style
    let handler: (UIAlertAction) -> Void
}
