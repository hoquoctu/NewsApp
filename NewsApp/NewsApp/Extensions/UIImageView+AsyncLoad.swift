import UIKit

// Bộ nhớ đệm (Cache) để lưu trữ ảnh đã tải.
// CƠ CHẾ: Khi người dùng cuộn lên xuống danh sách, NSCache giúp ảnh không bị tải lại từ đầu.
// Điều này tiết kiệm băng thông và giúp thao tác cuộn cực kỳ mượt mà, không bị giật lag.
let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    
    // LUỒNG XUẤT HÌNH ẢNH (Từ URL -> Giao diện):
    // Bước 1: Nhận đường link ảnh (urlString) từ Firebase (hoặc API).
    // Bước 2: Kiểm tra xem ảnh đã có trong Cache chưa, nếu có thì lấy ra xài luôn để không tốn thời gian tải lại.
    // Bước 3: Nếu chưa có, mở một luồng chạy ngầm (Background Thread) dùng URLSession để tải dữ liệu ảnh từ mạng.
    // Bước 4: Sau khi tải xong, chuyển dữ liệu thành UIImage và lưu vào Cache.
    // Bước 5: Nhảy lại về luồng giao diện (Main Thread - DispatchQueue.main) để gán ảnh vào self.image.
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
