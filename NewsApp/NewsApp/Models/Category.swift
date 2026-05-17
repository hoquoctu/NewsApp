import Foundation

struct Category: Codable, Identifiable {
    var id: String
    let name: String
    let updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case updatedAt
    }
}
