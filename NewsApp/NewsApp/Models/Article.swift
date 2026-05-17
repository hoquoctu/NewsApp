import Foundation

struct Article: Codable, Identifiable {
    var id: String?
    let author: String
    let bookmarkCount: Int64
    let categoryId: String
    let categoryName: String
    let content: String
    let createdAt: Date
    let description: String
    let imageUrls: [String]
    let isFeatured: Bool
    let isTrending: Bool
    let publishedAt: Date?
    let readingTime: Int64
    let sourceUrl: String
    let thumbnailUrl: String
    let title: String
    let viewCount: Int64
    
    enum CodingKeys: String, CodingKey {
        case id // optional, might be mapped manually from document ID
        case author
        case bookmarkCount
        case categoryId
        case categoryName
        case content
        case createdAt
        case description
        case imageUrls
        case isFeatured
        case isTrending
        case publishedAt
        case readingTime
        case sourceUrl
        case thumbnailUrl
        case title
        case viewCount
    }
}
