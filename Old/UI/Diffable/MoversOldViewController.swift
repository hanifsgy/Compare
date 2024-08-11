import UIKit
import Shared
import DifferenceKit

extension Stock: Differentiable {
    
    public var differenceIdentifier: String {
        return stockCode
    }
    
    public func isContentEqual(to source: Stock) -> Bool {
        return self.price == source.price && self.previousPrice == source.previousPrice
    }
}

final class MoversViewController: UIViewController {
    private var collectionView: UICollectionView!
    private var stocks: [Stock] = []
    private var timer: Timer?
    private var sortAscending = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        loadInitialData()
        startUpdatingPrices()
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.bounds.width, height: 60)
        layout.minimumLineSpacing = 1
        layout.headerReferenceSize = CGSize(width: view.bounds.width, height: 44)
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .white
        view.addSubview(collectionView)
        
        collectionView.register(StockCell.self, forCellWithReuseIdentifier: StockCell.reuseIdentifier)
        collectionView.register(
            SectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionHeaderView.reuseIdentifier
        )
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func loadInitialData() {
        stocks = [
            Stock(companyName: "Apple", stockCode: "AAPL", price: 150.0, previousPrice: 149.0),
            Stock(companyName: "Google", stockCode: "GOOGL", price: 2800.0, previousPrice: 2795.0),
            Stock(companyName: "Microsoft", stockCode: "MSFT", price: 300.0, previousPrice: 301.0),
            Stock(companyName: "Amazon", stockCode: "AMZN", price: 3300.0, previousPrice: 3290.0),
            Stock(companyName: "Facebook", stockCode: "FB", price: 330.0, previousPrice: 332.0)
        ]
        
        collectionView.reloadData()
    }
    
    private func startUpdatingPrices() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.25, repeats: true) { [weak self] _ in
            self?.updatePrices()
        }
    }
    
    private func updatePrices() {
        let oldStocks = stocks
        var updatedStocks: [Stock] = []
        for stock in stocks {
            let randomPercentage = Double.random(in: -3...3) / 100
            let priceChange = stock.price * randomPercentage
            let newPrice = stock.price + priceChange
            let roundedNewPrice = (newPrice * 100).rounded() / 100
            let updatedStock = Stock(companyName: stock.companyName,
                                     stockCode: stock.stockCode,
                                     price: roundedNewPrice,
                                     previousPrice: stock.price)
            updatedStocks.append(updatedStock)
        }
        stocks = updatedStocks
        sortStocks()
        
        let changeset = StagedChangeset(source: oldStocks, target: stocks)
        collectionView.reload(using: changeset) { [weak self] _ in
            self?.animatePriceChanges()
        }
    }
    
    private func animatePriceChanges() {
        for cell in collectionView.visibleCells {
            guard let stockCell = cell as? StockCell else { continue }
            stockCell.animatePriceChange()
        }
    }
    
    private func sortStocks() {
        stocks.sort { (stock1, stock2) -> Bool in
            let change1 = (stock1.price - stock1.previousPrice) / stock1.previousPrice
            let change2 = (stock2.price - stock2.previousPrice) / stock2.previousPrice
            return sortAscending ? change1 < change2 : change1 > change2
        }
    }
}

extension MoversViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stocks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StockCell.reuseIdentifier, for: indexPath) as? StockCell else {
            fatalError("Unable to dequeue StockCell")
        }
        cell.configure(with: stocks[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeaderView.reuseIdentifier, for: indexPath) as? SectionHeaderView else {
            return UICollectionReusableView()
        }
        headerView.delegate = self
        return headerView
    }
}

extension MoversViewController: SectionHeaderViewDelegate {
    func didTapSortButton() {
        sortAscending.toggle()
        sortStocks()
        collectionView.reloadData()
    }
}
