struct User: Decodable, Identifiable {
    let id: String
    let name: String
    let email: String
    let currency: String
    let phone: String
    let imageUrl: String?
}
