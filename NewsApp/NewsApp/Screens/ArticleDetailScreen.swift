import UIKit
import WebKit

class ArticleDetailScreen: UIView {
    
    // MARK: - UI Components
    let webView: WKWebView = {
        let configuration = WKWebViewConfiguration()
        // Allows inline media playback if any
        configuration.allowsInlineMediaPlayback = true
        
        let wv = WKWebView(frame: .zero, configuration: configuration)
        wv.translatesAutoresizingMaskIntoConstraints = false
        wv.backgroundColor = .white
        wv.scrollView.showsVerticalScrollIndicator = false
        return wv
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .white
        
        addSubview(webView)
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: topAnchor),
            webView.leadingAnchor.constraint(equalTo: leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
