import Foundation

struct User: Codable, Identifiable {
    var id: String
    let email: String
    let name: String
    let phoneNumber: String
    var note_article: [String] // Array of saved article IDs
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case name
        case phoneNumber
        case note_article
    }
}
