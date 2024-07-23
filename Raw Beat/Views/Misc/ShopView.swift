// Abstract: View that shows all the products.

import SwiftUI
import StoreKit

struct ShopView: View {
    @EnvironmentObject var store: Store
    
    let onPurchaseCompletion: (Product) -> Void
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 20.0) {
            VStack(spacing: isCompact ? 8.0 : 12.0) {
                ForEach(store.products.sorted(by: { $0.price < $1.price })) { product in
                    ProductView(product) { // TODO: try making it a custom view with a button that calls store.purchase and see if this works with .fullScreenCover modifier.
                        Text(emoji(for: product))
                            .font(.system(size: 32.0))
                            .padding(isCompact ? 6.0 : 12.0)
                            .background(Color.gradientEndColor.opacity(0.5), in: Circle())
                    }
                    .productViewStyle(.compact)
                    .padding(.horizontal, isCompact ? 8.0 : 16.0)
                    .padding(.vertical, isCompact ? 4.0 : 8.0)
                    .buttonStyle(CustomButton(isOutlined: false, size: .small, shape: Capsule()))
                    .overlay {
                        RoundedRectangle(cornerRadius: 16.0)
                            .fill(.clear)
                            .stroke(Color.secondary, lineWidth: 1.0)
                    }
                }
            }
            
            if !store.purchasedProducts.isEmpty { // FIXME: purchasedProducts is empty on app relaunch. Check why this is happening.
                HStack {
                    Text("Drinks treated:")
                    Spacer()
                    Text("\(store.purchasedProducts.count)")
                }
                .padding()
                .background(.secondary.opacity(0.5), in: RoundedRectangle(cornerRadius: 8.0))
            }
        }
        .onInAppPurchaseCompletion { product, result in
            switch result {
            case .success(let purchaseResult):
                do {
                    if try await store.purchase(product: product, purchaseResult: purchaseResult) {
                        onPurchaseCompletion(product)
                    }
                } catch {
                    // TODO: Show alert to user.
                    Log.sharedInstance.log(error: "Failed to purchase '\(product.id)'. Error: \(error.localizedDescription)")
                }
            case .failure(let purchaseError):
                // TODO: Show alert to user.
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
}
