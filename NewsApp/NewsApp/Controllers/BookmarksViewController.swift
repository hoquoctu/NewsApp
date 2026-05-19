import UIKit

class BookmarksViewController: UIViewController {
    
    private let bookmarksScreen = BookmarksScreen()
    private var savedArticles: [Article] = []
    
    override func loadView() {
        view = bookmarksScreen
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Tin đã lưu"
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchBookmarks()
    }
    
    private func setupTableView() {
        bookmarksScreen.tableView.delegate = self
        bookmarksScreen.tableView.dataSource = self
        bookmarksScreen.tableView.register(ArticleCell.self, forCellReuseIdentifier: ArticleCell.identifier)
    }
    
    private func fetchBookmarks() {
        FirebaseAPIService.shared.fetchBookmarkedArticles { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let articles):
                    self?.savedArticles = articles
                    self?.bookmarksScreen.tableView.reloadData()
                    self?.updateEmptyState()
                case .failure(let error):
                    print("Error fetching bookmarks: \(error)")
                }
            }
        }
    }
    
    private func updateEmptyState() {
        bookmarksScreen.emptyLabel.isHidden = !savedArticles.isEmpty
        bookmarksScreen.tableView.isHidden = savedArticles.isEmpty
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension BookmarksViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedArticles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ArticleCell.identifier, for: indexPath) as? ArticleCell else {
            return UITableViewCell()
        }
        let article = savedArticles[indexPath.row]
        cell.configure(with: article)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let article = savedArticles[indexPath.row]
        let detailVC = ArticleDetailViewController(article: article)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
