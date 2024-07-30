// Abstract: View that shows all the products.

import SwiftUI
import StoreKit

struct ShopView: View {
    @EnvironmentObject var store: Store
    
    let onPurchaseCompletion: (Product) -> Void
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private var isCompact: Bool { horizontalSizeClass == .compact }
    
    @State private var isAlertPresented: Bool = false
    @State private var alertMessage: LocalizedStringKey = ""
    
    var body: some View {
        VStack(spacing: isCompact ? 12.0 : 16.0) {
            ForEach(store.products.sorted(by: { $0.price < $1.price })) { product in
                ProductView(product) {
                    Text(emoji(for: product))
                        .font(.system(size: 32.0))
                        .padding(isCompact ? 6.0 : 12.0)
                        .background(Color.gradientEndColor.opacity(0.5), in: Circle())
                }
                .productViewStyle(.compact)
                .buttonStyle(CustomButton(isOutlined: false, size: .small, shape: Capsule()))
                Rectangle()
                    .fill(Color.primaryColor.opacity(0.5))
                    .frame(height: 0.5)
            }
        }
        .alert("Purchase failed", isPresented: $isAlertPresented, actions: {
            Button("OK") {
                isAlertPresented = false
            }
        }, message: {
            Text(alertMessage)
        })
        .onInAppPurchaseCompletion { product, result in
            switch result {
            case .success(let purchaseResult):
                do {
                    if try await store.purchase(product: product, purchaseResult: purchaseResult) {
                        onPurchaseCompletion(product)
                    }
                } catch {
                    alertMessage = generateAlertMessage(for: product)
                    isAlertPresented = true
                    Log.sharedInstance.log(error: "Failed to complete purchase of '\(product.id)'. Error: \(error.localizedDescription)")
                }
            case .failure(let purchaseError):
                alertMessage = generateAlertMessage(for: product)
                isAlertPresented = true
                Log.sharedInstance.log(error: "Failed to purchase '\(product.id)'. Error: \(purchaseError.localizedDescription)")
            }
        }
    }
    
    private func emoji(for product: Product) -> String {
        let tip = Tip(rawValue: product.id)
        if let emoji = tip?.emoji {
            return emoji
        } else {
            return "❓"
        }
    }
    
    private func generateAlertMessage(for product: Product) -> LocalizedStringKey {
        return "Failed to complete the purchase of '\(product.displayName)'. Please try again later."
    }
}
