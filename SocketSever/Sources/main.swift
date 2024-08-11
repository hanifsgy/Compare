import Vapor
import Foundation

let app = Application()
defer { app.shutdown() }

app.http.server.configuration.hostname = "127.0.0.1"
app.http.server.configuration.port = 8080

func stockDemo() -> [Stock] {
    return [
        Stock(companyName: "Apple", stockCode: "AAPL", price: 150.0, previousPrice: 149.0),
        Stock(companyName: "Microsoft", stockCode: "MSFT", price: 300.0, previousPrice: 301.0),
        Stock(companyName: "Amazon", stockCode: "AMZN", price: 3300.0, previousPrice: 3290.0),
        Stock(companyName: "Google", stockCode: "GOOGL", price: 2800.0, previousPrice: 2795.0),
        Stock(companyName: "Facebook", stockCode: "FB", price: 330.0, previousPrice: 332.0),
        Stock(companyName: "Tesla", stockCode: "TSLA", price: 700.0, previousPrice: 695.0),
        Stock(companyName: "NVIDIA", stockCode: "NVDA", price: 600.0, previousPrice: 605.0),
        Stock(companyName: "JPMorgan Chase", stockCode: "JPM", price: 150.0, previousPrice: 151.0),
        Stock(companyName: "Johnson & Johnson", stockCode: "JNJ", price: 170.0, previousPrice: 169.0),
        Stock(companyName: "Visa", stockCode: "V", price: 230.0, previousPrice: 232.0),
        Stock(companyName: "Procter & Gamble", stockCode: "PG", price: 140.0, previousPrice: 139.0),
        Stock(companyName: "UnitedHealth", stockCode: "UNH", price: 400.0, previousPrice: 402.0),
        Stock(companyName: "Home Depot", stockCode: "HD", price: 320.0, previousPrice: 318.0),
        Stock(companyName: "Mastercard", stockCode: "MA", price: 350.0, previousPrice: 352.0),
        Stock(companyName: "Bank of America", stockCode: "BAC", price: 40.0, previousPrice: 39.5),
        Stock(companyName: "Walt Disney", stockCode: "DIS", price: 180.0, previousPrice: 182.0),
        Stock(companyName: "Netflix", stockCode: "NFLX", price: 550.0, previousPrice: 545.0),
        Stock(companyName: "Coca-Cola", stockCode: "KO", price: 55.0, previousPrice: 54.5),
        Stock(companyName: "Pepsi", stockCode: "PEP", price: 150.0, previousPrice: 151.0),
        Stock(companyName: "Adobe", stockCode: "ADBE", price: 550.0, previousPrice: 548.0),
        Stock(companyName: "Salesforce", stockCode: "CRM", price: 240.0, previousPrice: 242.0),
        Stock(companyName: "Cisco Systems", stockCode: "CSCO", price: 55.0, previousPrice: 54.0),
        Stock(companyName: "Intel", stockCode: "INTC", price: 60.0, previousPrice: 59.5),
        Stock(companyName: "Verizon", stockCode: "VZ", price: 57.0, previousPrice: 56.5),
        Stock(companyName: "AT&T", stockCode: "T", price: 30.0, previousPrice: 30.5),
        Stock(companyName: "Walmart", stockCode: "WMT", price: 140.0, previousPrice: 141.0),
        Stock(companyName: "Exxon Mobil", stockCode: "XOM", price: 60.0, previousPrice: 59.0),
        Stock(companyName: "Chevron", stockCode: "CVX", price: 105.0, previousPrice: 104.0),
        Stock(companyName: "Boeing", stockCode: "BA", price: 240.0, previousPrice: 238.0),
        Stock(companyName: "Caterpillar", stockCode: "CAT", price: 220.0, previousPrice: 222.0),
        Stock(companyName: "Goldman Sachs", stockCode: "GS", price: 350.0, previousPrice: 348.0),
        Stock(companyName: "3M", stockCode: "MMM", price: 200.0, previousPrice: 201.0),
        Stock(companyName: "McDonald's", stockCode: "MCD", price: 230.0, previousPrice: 231.0),
        Stock(companyName: "Nike", stockCode: "NKE", price: 135.0, previousPrice: 134.0),
        Stock(companyName: "American Express", stockCode: "AXP", price: 160.0, previousPrice: 159.0),
        Stock(companyName: "IBM", stockCode: "IBM", price: 140.0, previousPrice: 141.0),
        Stock(companyName: "Merck", stockCode: "MRK", price: 75.0, previousPrice: 74.5),
        Stock(companyName: "Pfizer", stockCode: "PFE", price: 40.0, previousPrice: 39.5),
        Stock(companyName: "Amgen", stockCode: "AMGN", price: 240.0, previousPrice: 242.0),
        Stock(companyName: "Costco", stockCode: "COST", price: 380.0, previousPrice: 378.0),
        Stock(companyName: "Starbucks", stockCode: "SBUX", price: 115.0, previousPrice: 116.0),
        Stock(companyName: "PayPal", stockCode: "PYPL", price: 280.0, previousPrice: 282.0),
        Stock(companyName: "Accenture", stockCode: "ACN", price: 290.0, previousPrice: 288.0),
        Stock(companyName: "Oracle", stockCode: "ORCL", price: 80.0, previousPrice: 79.5),
        Stock(companyName: "Comcast", stockCode: "CMCSA", price: 55.0, previousPrice: 54.5),
        Stock(companyName: "Abbott Laboratories", stockCode: "ABT", price: 120.0, previousPrice: 119.0),
        Stock(companyName: "Thermo Fisher Scientific", stockCode: "TMO", price: 480.0, previousPrice: 482.0),
        Stock(companyName: "Danaher", stockCode: "DHR", price: 260.0, previousPrice: 258.0),
        Stock(companyName: "Broadcom", stockCode: "AVGO", price: 470.0, previousPrice: 468.0),
        Stock(companyName: "Texas Instruments", stockCode: "TXN", price: 190.0, previousPrice: 191.0)
    ]
}


var stocks: [Stock] = stockDemo()

app.webSocket("stocks") { req, ws in
    print("New WebSocket connection")
    let encoder = JSONEncoder()
    if let data = try? encoder.encode(stocks) {
        ws.send([UInt8](data))
    }
    let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
    timer.schedule(deadline: .now(), repeating: .seconds(1))
    timer.setEventHandler {
        for i in 0..<stocks.count {
            stocks[i].previousPrice = stocks[i].price
            stocks[i].price += Double.random(in: -5...5)
        }
        
        if let data = try? encoder.encode(stocks) {
            ws.send([UInt8](data))
        }
    }
    timer.resume()
    ws.onClose.whenComplete { _ in
        print("WebSocket connection closed")
        timer.cancel()
    }
}

try app.run()

