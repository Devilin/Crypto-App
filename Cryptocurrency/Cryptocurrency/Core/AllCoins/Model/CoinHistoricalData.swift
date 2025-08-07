import Foundation

struct CoinHistoricalData: Codable {
    let prices: [PricePoint]
    
    struct PricePoint: Codable {
        let timestamp: TimeInterval
        let price: Double
        
        var date: Date {
            return Date(timeIntervalSince1970: timestamp / 1000)
        }
        
        enum CodingKeys: String, CodingKey {
            case timestamp = 0
            case price = 1
        }
    }
}