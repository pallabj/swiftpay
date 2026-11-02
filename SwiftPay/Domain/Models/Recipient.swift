import Foundation

struct Recipient: Codable, Identifiable {
    let id: String
    let name: String
    let phone: String
}
