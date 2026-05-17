import UIKit
import FirebaseFirestore

class HomeViewController: UIViewController {
    
    // MARK: - View
    private let homeScreen = HomeScreen()
    private let apiService = FirebaseAPIService.shared
    
    // MARK: - Data
    private var articles: [Article] = []
    private var categories: [Category] = []
    private var selectedCategoryIndex: Int = 0
    
    // MARK: - Pagination State
    private var lastDocument: DocumentSnapshot?
    private var isLoadingMore = false
    private var isFinished = false
    private let fetchLimit = 20
    
    // MARK: - Lifecycle
    override func loadView() {
        view = homeScreen
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "NewsFlow"
        
        setupTableView()
        setupCollectionView()
        fetchData()
    }
    
    // MARK: - Setup
    private func setupTableView() {
        homeScreen.tableView.delegate = self
        homeScreen.tableView.dataSource = self
        homeScreen.tableView.register(ArticleCell.self, forCellReuseIdentifier: ArticleCell.identifier)
        homeScreen.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "BasicCell")
    }
    
    private func setupCollectionView() {
        homeScreen.categoryCollectionView.delegate = self
        homeScreen.categoryCollectionView.dataSource = self
        homeScreen.categoryCollectionView.register(CategoryCell.self, forCellWithReuseIdentifier: CategoryCell.identifier)
    }
    
    // MARK: - Networking
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
            self?.fetchArticles()
        }
    }
    
    private func resetPagination() {
        articles.removeAll()
        lastDocument = nil
        isFinished = false
        isLoadingMore = false
        DispatchQueue.main.async {
            self.homeScreen.tableView.reloadData()
        }
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

// MARK: - UITableViewDataSource, UITableViewDelegate
extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.isEmpty ? 1 : articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
        if !articles.isEmpty {
            let selectedArticle = articles[indexPath.row]
            let detailVC = ArticleDetailViewController(article: selectedArticle)
            navigationController?.pushViewController(detailVC, animated: true)
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
        // Nếu chọn lại tab cũ thì bỏ qua
        guard selectedCategoryIndex != indexPath.row else { return }
        
        selectedCategoryIndex = indexPath.row
        collectionView.reloadData()
        
        // Load lại danh sách bài theo category mới
        homeScreen.showLoading()
        resetPagination()
        fetchArticles()
    }
}
