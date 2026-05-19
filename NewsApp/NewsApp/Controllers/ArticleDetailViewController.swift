import UIKit
import WebKit

class ArticleDetailViewController: UIViewController {
    
    private let detailScreen = ArticleDetailScreen()
    private let article: Article
    private var isBookmarked: Bool = false {
        didSet {
            updateBookmarkButtonIcon()
        }
    }
    
    init(article: Article) {
        self.article = article
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func loadView() {
        view = detailScreen
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        setupBookmarkButton()
        checkBookmarkState()
        configureWebView()
    }
    
    private func setupBookmarkButton() {
        let bookmarkButton = UIBarButtonItem(image: UIImage(systemName: "bookmark"), style: .plain, target: self, action: #selector(handleBookmarkTap))
        navigationItem.rightBarButtonItem = bookmarkButton
    }
    
    private func updateBookmarkButtonIcon() {
        let iconName = isBookmarked ? "bookmark.fill" : "bookmark"
        navigationItem.rightBarButtonItem?.image = UIImage(systemName: iconName)
    }
    
    private func checkBookmarkState() {
        guard let articleId = article.id else { return }
        FirebaseAPIService.shared.checkIsBookmarked(articleId: articleId) { [weak self] isBookmarked in
            DispatchQueue.main.async {
                self?.isBookmarked = isBookmarked
            }
        }
    }
    
    @objc private func handleBookmarkTap() {
        // Optimistic UI update
        isBookmarked.toggle()
        
        FirebaseAPIService.shared.toggleBookmark(article: article) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let isNowBookmarked):
                    self?.isBookmarked = isNowBookmarked
                case .failure(let error):
                    // Revert UI on failure
                    self?.isBookmarked.toggle()
                    print("Error toggling bookmark: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // LUỒNG XUẤT TEXT & HÌNH ẢNH BÀI BÁO (WKWebView):
    // Cơ chế: Bài báo của bạn (article.content) chứa mã HTML thô. Nếu đưa vào UITextView, nó sẽ in ra thẻ <p>, <img> rất xấu và lỗi.
    // Giải pháp: Sử dụng WKWebView (trình duyệt web nhúng). Đoạn mã dưới đây là bộ khung HTML và CSS.
    // Trong bộ khung này, đoạn CSS (style) sẽ can thiệp để ép chữ to ra dễ đọc, và ép hình ảnh/video
    // luôn tự động co giãn vừa vặn 100% màn hình điện thoại (max-width: 100% !important).
    private func configureWebView() {
        // Construct the full HTML to wrap the article content
        // This ensures the custom tags like <figure> and <p> display beautifully
        let htmlString = """
        <!DOCTYPE html>
        <html lang="vi">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
            <style>
                :root {
                    color-scheme: light dark;
                }
                body {
                    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
                    margin: 0;
                    padding: 0;
                    color: #222;
                    background-color: #fff;
                    word-wrap: break-word;
                }
                @media (prefers-color-scheme: dark) {
                    body {
                        color: #ddd;
                        background-color: #000;
                    }
                    .title { color: #fff !important; }
                    .meta { color: #aaa !important; }
                    .category { background-color: #1a3a5c !important; color: #4da6ff !important; }
                }
                .banner {
                    width: 100%;
                    height: 250px;
                    object-fit: cover;
                    display: block;
                }
                .header {
                    padding: 20px 16px 16px;
                }
                .category {
                    display: inline-block;
                    background: #e6f2ff;
                    color: #007aff;
                    padding: 4px 10px;
                    border-radius: 6px;
                    font-size: 12px;
                    font-weight: bold;
                    margin-bottom: 12px;
                    text-transform: uppercase;
                }
                .title {
                    font-size: 26px;
                    font-weight: 800;
                    line-height: 1.3;
                    margin-bottom: 12px;
                    color: #000;
                    letter-spacing: -0.5px;
                }
                .meta {
                    font-size: 14px;
                    color: #666;
                    font-weight: 500;
                    margin-bottom: 24px;
                }
                .content {
                    padding: 0 16px 30px;
                    font-size: 17px;
                    line-height: 1.6;
                }
                /* CSS ÉP DÀN TRANG HÌNH ẢNH */
                .content img, .content figure {
                    max-width: 100% !important;
                    height: auto !important;
                    margin: 16px 0 !important;
                    border-radius: 8px;
                    display: block;
                }
                .content figcaption {
                    font-size: 13px;
                    color: #888;
                    text-align: center;
                    margin-top: 8px;
                    font-style: italic;
                }
                p {
                    margin-bottom: 16px;
                }
            </style>
        </head>
        <body>
            <img class="banner" src="\(article.thumbnailUrl ?? "")" />
            <div class="header">
                <div class="category">\(article.categoryName ?? "Tin tức")</div>
                <div class="title">\(article.title)</div>
                <div class="meta">✍️ \(article.author ?? "Ẩn danh") • ⏱ \(article.readingTime ?? 0) phút đọc</div>
            </div>
            <div class="content">
                <p><strong>\(article.description ?? "")</strong></p>
                <!-- Tiêm đoạn HTML đã được sửa lỗi lười tải vào đây -->
                \(processContentHTML(article.content ?? ""))
            </div>
        </body>
        </html>
        """
        
        detailScreen.webView.loadHTMLString(htmlString, baseURL: nil)
    }
    
    // CƠ CHẾ FIX LỖI KHÔNG HIỆN ẢNH VÀ VIDEO CỦA VNEXPRESS:
    // Vì VNExpress dùng kỹ thuật Lazy-Load (Lười tải) để web load nhanh hơn. 
    // Tức là họ giấu link ảnh/video thật đi (dùng chữ data-src=, hoặc thẻ <meta>). 
    // Hàm này sẽ dùng Swift dùng để dò và "gỡ phong ấn" các đoạn mã đó.
    private func processContentHTML(_ content: String) -> String {
        var processed = content
        
        // 1. Ép tất cả các thẻ lười tải (lazy-load) như video, iframe, img về lại thuộc tính thật (src=) để trình duyệt phải vẽ ra.
        processed = processed.replacingOccurrences(of: "data-src=", with: "src=")
        processed = processed.replacingOccurrences(of: "data-video-src=", with: "src=")
        processed = processed.replacingOccurrences(of: "data-original=", with: "src=")
        
        // 2. Với các ảnh được VNExpress giấu tinh vi hơn bên trong thẻ <meta>, ta thay thẳng chữ <meta thành <img
        processed = processed.replacingOccurrences(of: "<meta content=\"http", with: "<img src=\"http")
        processed = processed.replacingOccurrences(of: "<meta itemprop=\"url\" content=\"http", with: "<img src=\"http")
        
        return processed
    }
}
