import UIKit

// MARK: - Page Options
public enum Page: String, CaseIterable {
    case compositionalLayout
    case features
    case structuredConcurrency
    case diffing
    
    public var title: String {
        switch self {
        case .compositionalLayout:
            "UI - Compositional Layout - Diffing"
        case .features:
            "Movers"
        case .structuredConcurrency:
            "Structured Concurrency Demo"
        case .diffing:
            "Diffing on TableView"
        }
    }
}

/// Stock Data
public struct Stock: Hashable {
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
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: Stock, rhs: Stock) -> Bool {
        lhs.id == rhs.id
    }
}

public func stockDemo() -> [Stock] {
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

@available(iOS 13.0, *)
extension Stock: Identifiable {}

// MARK: - Stock Cell
public final class StockCell: UICollectionViewCell {
    public static let reuseIdentifier = "StockCell"
    
    private let companyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    private let changeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    private let stackView: UIStackView = UIStackView()
    
    private var priceChangeColor: UIColor = .clear
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(companyLabel)
        contentView.addSubview(stackView)
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        
        stackView.addArrangedSubview(priceLabel)
        stackView.addArrangedSubview(changeLabel)
        companyLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            companyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            companyLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    public func configure(with stock: Stock) {
        companyLabel.text = stock.companyName + " (\(stock.stockCode))"
        priceLabel.text = String(format: "%.2f", stock.price)
        
        let change = stock.price - stock.previousPrice
        let changePercentage = (change / stock.previousPrice) * 100
        
        changeLabel.text = String(format: "%.2f (%.2f%%)", change, changePercentage)
        priceChangeColor = change >= 0 ? .green : .red
        changeLabel.textColor = priceChangeColor
    }
    
    public func animatePriceChange() {
        UIView.animate(withDuration: 0.3, animations: {
            self.contentView.backgroundColor = self.priceChangeColor.withAlphaComponent(0.3)
        }) { _ in
            UIView.animate(withDuration: 0.3) {
                self.contentView.backgroundColor = .clear
            }
        }
    }
}

// MARK: - Stock Section Header
public protocol SectionHeaderViewDelegate: AnyObject {
    func didTapSortButton()
}

public final class SectionHeaderView: UICollectionReusableView {
    public static let reuseIdentifier = "SectionHeaderView"
    
    public weak var delegate: SectionHeaderViewDelegate?
    
    private let stockNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Stock Name"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.text = "Price"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    private let sortButton: UIButton = {
        let button = UIButton(type: .system)
        if #available(iOS 13.0, *) {
            button.setImage(UIImage(systemName: "arrow.up.arrow.down"), for: .normal)
        } else {
            button.setImage(UIImage(named: "arrow"), for: .normal)
        }
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(stockNameLabel)
        addSubview(priceLabel)
        addSubview(sortButton)
        
        stockNameLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        sortButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stockNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stockNameLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            sortButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            sortButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            priceLabel.trailingAnchor.constraint(equalTo: sortButton.leadingAnchor, constant: -8),
            priceLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        sortButton.addTarget(self, action: #selector(sortButtonTapped), for: .touchUpInside)
    }
    
    @objc private func sortButtonTapped() {
        delegate?.didTapSortButton()
    }
}
