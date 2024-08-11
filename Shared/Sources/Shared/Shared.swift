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
