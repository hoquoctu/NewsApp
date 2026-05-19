import UIKit
import FirebaseFirestore

class HomeViewController: UIViewController {
    
    // MARK: - View
    private let homeScreen = HomeScreen()
    private let apiService = FirebaseAPIService.shared
    private let featuredArticleView = FeaturedArticleView()
    
    // MARK: - Data
    private var articles: [Article] = []
    private var categories: [Category] = []
    private var selectedCategoryIndex: Int = 0
    
    // MARK: - Pagination State
    private var lastDocument: DocumentSnapshot?
    private var isLoadingMore = false
    private var isFinished = false
    private let fetchLimit = 20
    
    // MARK: - Search State
    private let searchController = UISearchController(searchResultsController: nil)
    private var searchResults: [Article] = []
    private var searchTimer: Timer?
    private var isSearching: Bool {
        return searchController.isActive && !(searchController.searchBar.text?.isEmpty ?? true)
    }
    
    // MARK: - Lifecycle
    override func loadView() {
        view = homeScreen
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "NewsFlow"
        
        setupSearchController()
        setupTableView()
        setupCollectionView()
        fetchData()
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Tìm theo tác giả, nội dung..."
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    // MARK: - Setup
    private func setupTableView() {
        homeScreen.tableView.delegate = self
        homeScreen.tableView.dataSource = self
        homeScreen.tableView.register(ArticleCell.self, forCellReuseIdentifier: ArticleCell.identifier)
        homeScreen.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "BasicCell")
        
        featuredArticleView.delegate = self
    }
    
    private func setupCollectionView() {
        homeScreen.categoryCollectionView.delegate = self
        homeScreen.categoryCollectionView.dataSource = self
        homeScreen.categoryCollectionView.register(CategoryCell.self, forCellWithReuseIdentifier: CategoryCell.identifier)
    }
    
    // MARK: - Networking / LUỒNG LẤY DỮ LIỆU CHÍNH
    // CƠ CHẾ: Khi màn hình vừa bật lên (viewDidLoad), hàm này sẽ được gọi.
    // 1. Gửi lệnh lên Firebase để lấy danh sách Thể loại (Categories).
    // 2. Tự động chèn thêm chữ "Tất cả" vào đầu danh sách (mặc định id là "all").
    // 3. Sau khi có danh mục, nó mới gọi tiếp lệnh tải Bài báo (fetchArticles) dựa trên Category đầu tiên.
    private func fetchData() {
        homeScreen.showLoading()
        
        // Fetch Categories
        apiService.fetchCategories { [weak self] result in
            switch result {
            case .success(let fetchedCategories):
                // Add a default "All" category
                let allCategory = Category(id: "all", name: "Tất cả", updatedAt: Date())
                var finalCategories = [allCategory]
                finalCategories.append(contentsOf: fetchedCategories)
                self?.categories = finalCategories
                
                DispatchQueue.main.async {
                    self?.homeScreen.categoryCollectionView.reloadData()
                }
            case .failure(let error):
                print("Error fetching categories: \(error.localizedDescription)")
            }
            
            // Lần đầu fetch Articles: reset các biến phân trang
            self?.resetPagination()
            self?.fetchContentForCurrentCategory()
        }
    }
    
    private func resetPagination() {
        articles.removeAll()
        lastDocument = nil
        isFinished = false
        isLoadingMore = false
        DispatchQueue.main.async {
            self.homeScreen.tableView.reloadData()
            self.homeScreen.tableView.tableHeaderView = nil // Ẩn featured view đi khi đổi tab
        }
    }
    
    private func fetchContentForCurrentCategory() {
        var catId: String? = nil
        if !categories.isEmpty && selectedCategoryIndex < categories.count {
            let selectedCat = categories[selectedCategoryIndex]
            catId = selectedCat.id
        }
        
        // 1. Tải Bài Báo Nổi Bật (Trending by viewCount)
        apiService.fetchFeaturedArticle(categoryId: catId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let article):
                    if let article = article {
                        self?.featuredArticleView.configure(with: article)
                        self?.featuredArticleView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 280)
                        self?.homeScreen.tableView.tableHeaderView = self?.featuredArticleView
                    } else {
                        self?.homeScreen.tableView.tableHeaderView = nil
                    }
                case .failure(let error):
                    print("Error fetching featured article: \(error)")
                    self?.homeScreen.tableView.tableHeaderView = nil
                }
            }
        }
        
        // 2. Tải Danh Sách Phân Trang
        fetchArticles()
    }
    
    private func fetchArticles() {
        guard !isLoadingMore, !isFinished else { return }
        isLoadingMore = true
        
        // Lấy category ID đang được chọn
        var catId: String? = nil
        if !categories.isEmpty && selectedCategoryIndex < categories.count {
            let selectedCat = categories[selectedCategoryIndex]
            catId = selectedCat.id
        }
        
        apiService.fetchArticles(limit: fetchLimit, lastDocument: lastDocument, categoryId: catId) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.homeScreen.hideLoading()
                self.isLoadingMore = false
                
                switch result {
                case .success(let (fetchedArticles, newLastDocument)):
                    if fetchedArticles.isEmpty {
                        self.isFinished = true
                    } else {
                        self.articles.append(contentsOf: fetchedArticles)
                        self.lastDocument = newLastDocument
                        
                        // Nếu lấy về ít hơn số lượng yêu cầu (limit) -> đã hết bài
                        if fetchedArticles.count < self.fetchLimit {
                            self.isFinished = true
                        }
                    }
                    self.homeScreen.tableView.reloadData()
                    
                case .failure(let error):
                    print("Error fetching articles: \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - FeaturedArticleViewDelegate
extension HomeViewController: FeaturedArticleViewDelegate {
    func didTapFeaturedArticle(_ article: Article) {
        let detailVC = ArticleDetailViewController(article: article)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return searchResults.isEmpty ? 1 : searchResults.count
        }
        return articles.isEmpty ? 1 : articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isSearching {
            if searchResults.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath)
                cell.textLabel?.text = "Không tìm thấy kết quả phù hợp."
                cell.textLabel?.textAlignment = .center
                cell.textLabel?.textColor = .gray
                cell.backgroundColor = .clear
                cell.selectionStyle = .none
                return cell
            }
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ArticleCell.identifier, for: indexPath) as? ArticleCell else {
                return UITableViewCell()
            }
            let article = searchResults[indexPath.row]
            cell.configure(with: article)
            return cell
        }
        
        if articles.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath)
            cell.textLabel?.text = "Đang tải dữ liệu hoặc không có tin tức..."
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = .gray
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ArticleCell.identifier, for: indexPath) as? ArticleCell else {
            return UITableViewCell()
        }
        
        let article = articles[indexPath.row]
        cell.configure(with: article)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isSearching {
            if !searchResults.isEmpty {
                let selectedArticle = searchResults[indexPath.row]
                let detailVC = ArticleDetailViewController(article: selectedArticle)
                navigationController?.pushViewController(detailVC, animated: true)
            }
        } else {
            if !articles.isEmpty {
                let selectedArticle = articles[indexPath.row]
                let detailVC = ArticleDetailViewController(article: selectedArticle)
                navigationController?.pushViewController(detailVC, animated: true)
            }
        }
    }
    
    // MARK: Infinite Scrolling Logic
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Chỉ chạy khi scroll tableView
        guard scrollView == homeScreen.tableView else { return }
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        // Nếu người dùng cuộn đến cách đáy 150px
        if offsetY > contentHeight - height - 150 {
            // Tải thêm trang tiếp theo
            fetchArticles()
        }
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.isEmpty ? 4 : categories.count // 4 for mock loading state
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCell.identifier, for: indexPath) as? CategoryCell else {
            return UICollectionViewCell()
        }
        
        if categories.isEmpty {
            // Mock empty state cell
            let mockCategory = Category(id: "mock", name: "Loading...", updatedAt: Date())
            cell.configure(with: mockCategory, isSelected: indexPath.row == 0)
        } else {
            let category = categories[indexPath.row]
            cell.configure(with: category, isSelected: indexPath.row == selectedCategoryIndex)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Nếu đang tìm kiếm thì block tap category
        if searchController.isActive { return }
        
        // Nếu chọn lại tab cũ thì bỏ qua
        guard selectedCategoryIndex != indexPath.row else { return }
        
        selectedCategoryIndex = indexPath.row
        collectionView.reloadData()
        
        // Load lại danh sách bài theo category mới
        homeScreen.showLoading()
        resetPagination()
        fetchContentForCurrentCategory()
    }
}

// MARK: - UISearchResultsUpdating
extension HomeViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text, !query.isEmpty else {
            searchResults.removeAll()
            homeScreen.tableView.reloadData()
            homeScreen.tableView.tableHeaderView = articles.isEmpty ? nil : featuredArticleView
            return
        }
        
        homeScreen.tableView.tableHeaderView = nil // Ẩn banner nổi bật khi tìm kiếm
        
        searchTimer?.invalidate()
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { [weak self] _ in
            self?.performSearch(query: query)
        })
    }
    
    private func performSearch(query: String) {
        homeScreen.showLoading()
        apiService.searchArticles(query: query) { [weak self] result in
            DispatchQueue.main.async {
                self?.homeScreen.hideLoading()
                switch result {
                case .success(let results):
                    self?.searchResults = results
                    self?.homeScreen.tableView.reloadData()
                case .failure(let error):
                    print("Lỗi tìm kiếm: \(error.localizedDescription)")
                }
            }
        }
    }
}
