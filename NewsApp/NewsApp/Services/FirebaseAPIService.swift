import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class FirebaseAPIService {
    static let shared = FirebaseAPIService()
    
    private let db = Firestore.firestore()
    
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
}
