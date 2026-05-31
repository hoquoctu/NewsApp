import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth
import FirebaseFunctions

class FirebaseAPIService {
    static let shared = FirebaseAPIService()
    
    private let db = Firestore.firestore()
    private lazy var functions = Functions.functions()
    
    private init() {}
    
    func fetchArticles(limit: Int = 20, lastDocument: DocumentSnapshot? = nil, categoryId: String? = nil, completion: @escaping (Result<([Article], DocumentSnapshot?), Error>) -> Void) {
        
        var query: Query = db.collection("articles").order(by: "createdAt", descending: true)
        
        if let catId = categoryId, catId != "all" {
            query = query.whereField("categoryId", isEqualTo: catId)
        }
        
        if let lastDoc = lastDocument {
            query = query.start(afterDocument: lastDoc)
        }
        
        query.limit(to: limit).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Lấy tất cả bài báo từ database
            let articles = snapshot?.documents.compactMap { doc -> Article? in
                var article = try? doc.data(as: Article.self)
                article?.id = doc.documentID
                return article
            } ?? []
            
            completion(.success((articles, snapshot?.documents.last)))
        }
    }
    
    func fetchFeaturedArticle(categoryId: String? = nil, completion: @escaping (Result<Article?, Error>) -> Void) {
        var query: Query = db.collection("articles").order(by: "viewCount", descending: true).limit(to: 1)
        
        if let catId = categoryId, catId != "all" {
            query = query.whereField("categoryId", isEqualTo: catId)
        }
        
        query.getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let doc = snapshot?.documents.first {
                do {
                    var article = try doc.data(as: Article.self)
                    article.id = doc.documentID
                    completion(.success(article))
                } catch {
                    print("Error decoding featured article: \(error)")
                    completion(.success(nil))
                }
            } else {
                completion(.success(nil))
            }
        }
    }
    
    func fetchCategories(completion: @escaping (Result<[Category], Error>) -> Void) {
        db.collection("categories").getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Lấy tất cả danh mục từ database
            let categories = snapshot?.documents.compactMap { doc -> Category? in
                do {
                    var category = try doc.data(as: Category.self)
                    category.id = doc.documentID
                    return category
                } catch {
                    print("Error decoding category \(doc.documentID): \(error)")
                    return nil
                }
            } ?? []
            
            completion(.success(categories))
        }
    }
    
    // MARK: - Bookmarks
    
    func checkIsBookmarked(articleId: String, completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        
        let docRef = db.collection("users").document(userId).collection("note_articles").document(articleId)
        docRef.getDocument { document, error in
            if let document = document, document.exists {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func toggleBookmark(article: Article, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])))
            return
        }
        guard let articleId = article.id else {
            completion(.failure(NSError(domain: "DataError", code: 400, userInfo: [NSLocalizedDescriptionKey: "Article ID is missing"])))
            return
        }
        
        let docRef = db.collection("users").document(userId).collection("note_articles").document(articleId)
        
        docRef.getDocument { [weak self] document, error in
            guard let self = self else { return }
            if let error = error {
                completion(.failure(error))
                return
            }
            
            let data: [String: Any] = [
                "userId": userId,
                "articleId": articleId
            ]
            
            if let document = document, document.exists {
                // Đã lưu -> Gọi API deleteArticle qua Cloud Functions
                self.functions.httpsCallable("deleteArticle").call(data) { result, error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(false)) // false means "unbookmarked"
                    }
                }
            } else {
                // Chưa lưu -> Gọi API saveArticle qua Cloud Functions
                self.functions.httpsCallable("saveArticle").call(data) { result, error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(true)) // true means "bookmarked"
                    }
                }
            }
        }
    }
    
    func fetchBookmarkedArticles(completion: @escaping (Result<[Article], Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])))
            return
        }
        
        db.collection("users").document(userId).collection("note_articles").getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            let articles = snapshot?.documents.compactMap { doc -> Article? in
                var article = try? doc.data(as: Article.self)
                article?.id = doc.documentID
                return article
            } ?? []
            
            completion(.success(articles))
        }
    }
    
    // MARK: - Search
    
    func searchArticles(query: String, completion: @escaping (Result<[Article], Error>) -> Void) {
        // Fetch a large batch of recent articles to search locally
        db.collection("articles")
            .order(by: "createdAt", descending: true)
            .limit(to: 100) // Adjust limit based on database size and performance
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                let lowercasedQuery = query.lowercased()
                
                let articles = snapshot?.documents.compactMap { doc -> Article? in
                    var article = try? doc.data(as: Article.self)
                    article?.id = doc.documentID
                    
                    // Client-side filtering: check if author or content contains the query
                    let authorMatch = article?.author?.lowercased().contains(lowercasedQuery) ?? false
                    let contentMatch = article?.content?.lowercased().contains(lowercasedQuery) ?? false
                    
                    if authorMatch || contentMatch {
                        return article
                    }
                    return nil
                } ?? []
                
                completion(.success(articles))
            }
    }
}
