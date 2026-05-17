import UIKit

let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    func loadImage(from urlString: String, placeholder: UIImage? = nil) {
        self.image = placeholder
        
        guard let url = URL(string: urlString) else { return }
        
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            self.image = cachedImage
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self, let data = data, error == nil, let downloadedImage = UIImage(data: data) else {
                return
            }
            
            imageCache.setObject(downloadedImage, forKey: urlString as NSString)
            
            DispatchQueue.main.async {
                self.image = downloadedImage
            }
        }.resume()
    }
}
