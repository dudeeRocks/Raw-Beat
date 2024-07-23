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
    
    func purchase(product: Product) async throws {
        let purchaseResult: Product.PurchaseResult = try await product.purchase()
        switch purchaseResult {
        case .success(let verificationResult):
            let transaction = try verify(transaction: verificationResult)
            process(transaction)
            await transaction.finish()
            Log.sharedInstance.log(message: "Purchase success. Product: \(product.id)")
        case .pending:
            Log.sharedInstance.log(message: "Purchase is pending.")
            break
        case .userCancelled:
            Log.sharedInstance.log(message: "The user canceled the purchase.")
            break
        @unknown default:
            break
        }
    }
    
    @MainActor
    private func requestProducts() async {
        do {
            let loadedProducts: [Product] = try await Product.products(for: productIDs)
            products = loadedProducts
            Log.sharedInstance.log(message: "Requested products.")
        } catch {
            Log.sharedInstance.log(error: "Failed product request. Error: \(error.localizedDescription)")
        }
    }
    
    private func process(_ transaction: Transaction) {
        if let purchasedProduct = products.first(where: { $0.id == transaction.productID} ) {
            Log.sharedInstance.log(message: "Adding \(purchasedProduct.id) to 'purchasedProducts'.")
            purchasedProducts.append(purchasedProduct)
            
            // TODO: Deliver purchased product here.
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
                Log.sharedInstance.log(error: "\(#function) caught error: \(error.localizedDescription)")
            }
        }
    }
    
    private func listenToTransactionUpdates() {
        Log.sharedInstance.log(message: "Observing transaction updates")
        transactionsUpdates = Task.detached {
            for await update in Transaction.updates {
                do {
                    let transaction = try self.verify(transaction: update)
                    
                    self.process(transaction)
                    
                    await transaction.finish()
                } catch {
                    Log.sharedInstance.log(error: "\(#function) caught error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func stopListeningForTransactionUpdates() {
        transactionsUpdates?.cancel()
        Log.sharedInstance.log(message: "Stopped listening for transations updates.")
    }
}
