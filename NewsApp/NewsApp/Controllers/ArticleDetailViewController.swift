import UIKit
import WebKit

class ArticleDetailViewController: UIViewController {
    
    private let detailScreen = ArticleDetailScreen()
    private let article: Article
    
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
        configureWebView()
    }
    
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
            <img class="banner" src="\(article.thumbnailUrl)" />
            <div class="header">
                <div class="category">\(article.categoryName)</div>
                <div class="title">\(article.title)</div>
                <div class="meta">✍️ \(article.author) • ⏱ \(article.readingTime) phút đọc</div>
            </div>
            <div class="content">
                <p><strong>\(article.description)</strong></p>
                \(article.content)
            </div>
            
            <script>
                // 1. Convert VNExpress <meta> tags in <figure> to real images
                document.querySelectorAll('figure').forEach(fig => {
                    if (!fig.querySelector('img')) {
                        let meta = fig.querySelector('meta[content*=".jpg"], meta[content*=".png"], meta[content*=".jpeg"], meta[itemprop="url"]');
                        if (meta && meta.content) {
                            let img = document.createElement('img');
                            img.src = meta.content;
                            fig.appendChild(img);
                        }
                    }
                });
                
                // 2. Bypass lazy loading for all elements (img, iframe, video) with data-src
                document.querySelectorAll('[data-src]').forEach(el => {
                    el.src = el.getAttribute('data-src');
                });
            </script>
        </body>
        </html>
        """
        
        detailScreen.webView.loadHTMLString(htmlString, baseURL: nil)
    }
}
