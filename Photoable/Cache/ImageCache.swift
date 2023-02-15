import UIKit

class ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSString, UIImage>()
    
    func setImage(_ image: UIImage?, forKey key: String) {
        if let image = image, image.size.width + image.size.height >= 1500 {
            cache.setObject(image, forKey: key as NSString)
        }
    }
    
    func image(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
}
