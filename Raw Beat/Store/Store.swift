// Abstract: Object that handles in-app purchases.

import StoreKit

class Store: ObservableObject {
    
    @Published private(set) var products: [Product]
    @Published private(set) var purchasedProducts: [Product]
    
    private let productIDs: Set<String> = {
        var productIDsResult: Set<String> = []
        
        for tip in Tip.allCases {
            productIDsResult.insert(tip.rawValue)
        }
        
        return productIDsResult
    }()
    
    private var transactionsUpdates: Task<Void, Never>? = nil
    
    private(set) var productRequestAttempts: Int = 0
    
    init() {
        products = []
        purchasedProducts = []
        
        listenToTransactionUpdates()
        
        Task {
            await requestProducts()
            await refreshPurchasedProducts()
        }
        Log.sharedInstance.log(message: "Store initialized")
    }
    
    deinit {
        stopListeningForTransactionUpdates()
    }
    
    /// Function that handles purchases from UI.
    /// Returns `true` if `Product.PurchaseResult` is `.success`.
    /// The return value of this function determines whether the Thank you note will be presented.
    func purchase(product: Product, purchaseResult: Product.PurchaseResult) async throws -> Bool {
        switch purchaseResult {
        case .success(let verificationResult):
            let transaction = try verify(transaction: verificationResult)
            await process(transaction)
            await transaction.finish()
            Log.sharedInstance.log(message: "Purchase success. Product: \(product.id)")
            return true
        case .pending:
            Log.sharedInstance.log(message: "Purchase is pending.")
            return false
        case .userCancelled:
            Log.sharedInstance.log(message: "The user canceled the purchase.")
            return false
        @unknown default:
            return false
        }
    }
    
    @MainActor
    private func requestProducts() async {
        do {
            let loadedProducts: [Product] = try await Product.products(for: productIDs)
            products = loadedProducts
            productRequestAttempts = 0
            Log.sharedInstance.log(message: "✅ Successfully requested and loaded \(products.count) products.")
        } catch {
            Log.sharedInstance.log(error: "❌ Failed product request. Error: \(error.localizedDescription)")
            switch productRequestAttempts {
            case 0..<3:
                productRequestAttempts += 1
                retryRequestingProducts(after: 2)
            case 3..<6:
                productRequestAttempts += 1
                retryRequestingProducts(after: 5)
            case 6...10:
                productRequestAttempts += 1
                retryRequestingProducts(after: 60)
            default:
                Log.sharedInstance.log(error: "❌ Failed product request \(productRequestAttempts) times. Stopping retry mechanism now.")
            }
        }
    }
    
    func retryRequestingProducts(after delay: TimeInterval?) {
        Log.sharedInstance.log(message: "Retrying product request. Attempts: \(productRequestAttempts)")
        Task {
            if let delay = delay {
                try await Task.sleep(for: .seconds(delay))
            }
            await requestProducts()
        }
    }
    
    @MainActor
    private func process(_ transaction: Transaction) {
        if let purchasedProduct = products.first(where: { $0.id == transaction.productID} ) {
            Log.sharedInstance.log(message: "Adding \(purchasedProduct.id) to 'purchasedProducts'.")
            purchasedProducts.append(purchasedProduct)
            
            // This is the place to deliver any products that need it.
            if let tip = Tip(rawValue: purchasedProduct.id) {
                // Tips don't provide any value to the user ATM
                Log.sharedInstance.log(message: "Processed Tip: \(tip.emoji)")
            }
        }
    }
    
    private func verify(transaction verificationResult: VerificationResult<Transaction>) throws -> Transaction {
        switch verificationResult {
        case .unverified(let unverifiedTransaction, let verificationError):
            Log.sharedInstance.log(error: "Failed to verifiy transaction \(unverifiedTransaction.id) for product \(unverifiedTransaction.productID).")
            throw verificationError
        case .verified(let transaction):
            return transaction
        }
    }
    
    @MainActor
    private func refreshPurchasedProducts() async {
        Log.sharedInstance.log(message: "Refreshing products")
        for await verificationResult in Transaction.currentEntitlements {
            do {
                let transaction = try verify(transaction: verificationResult)
                process(transaction)
            } catch {
                Log.sharedInstance.log(error: "Failed to refresh purchased products. Error: \(error.localizedDescription)")
            }
        }
    }
    
    private func listenToTransactionUpdates() {
        Log.sharedInstance.log(message: "Observing transaction updates")
        transactionsUpdates = Task.detached {
            for await update in Transaction.updates {
                do {
                    let transaction = try self.verify(transaction: update)
                    
                    await self.process(transaction)
                    
                    await transaction.finish()
                } catch {
                    Log.sharedInstance.log(error: "Failed to get transaction updates. Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func stopListeningForTransactionUpdates() {
        transactionsUpdates?.cancel()
        Log.sharedInstance.log(message: "Stopped listening for transations updates.")
    }
}
