import Foundation

struct CategoryDTO: Codable {
    let id: UUID
    let name: String
}
struct ProductDTO: Codable {
    let id: UUID
    let sku: String
    let name: String
    let description: String?
    let base_price: Double
    let category_id: UUID?
    let image_url: String?
    let created_at: String?
    let categories: CategoryDTO?
}

let json = """
[{"id":"1437abd2-5cc3-4095-94ba-cdb89262b463","sku":"BAG-LVT-002","name":"Leather Travel Tote","description":"Hand-stitched Italian calfskin leather.","base_price":120000.00,"category_id":"2539c3ed-8e61-4cf6-9d07-452290c8551b","image_url":null,"created_at":"2026-04-16T04:51:42.361506+00:00","inRepair":false,"is_active":true,"categories":{"id": "2539c3ed-8e61-4cf6-9d07-452290c8551b", "name": "Leather Goods"}}]
"""

do {
    let data = json.data(using: .utf8)!
    let dtos = try JSONDecoder().decode([ProductDTO].self, from: data)
    print("Success: \(dtos.count)")
} catch {
    print("Error: \(error)")
}
