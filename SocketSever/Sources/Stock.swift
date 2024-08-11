import Foundation

public struct Stock: Hashable, Codable {
    public let id = UUID()
    public let companyName: String
    public let stockCode: String
    public var price: Double
    public var previousPrice: Double
    
    public init(companyName: String, stockCode: String, price: Double, previousPrice: Double) {
        self.companyName = companyName
        self.stockCode = stockCode
        self.price = price
        self.previousPrice = previousPrice
    }
}
