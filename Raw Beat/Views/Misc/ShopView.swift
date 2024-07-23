// Abstract: View that shows all the products.

import SwiftUI
import StoreKit

struct ShopView: View {
    @EnvironmentObject var store: Store
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    var body: some View {
        VStack(spacing: isCompact ? 8.0 : 12.0) {
            ForEach(store.products.sorted(by: { $0.price < $1.price })) { product in
                ProductView(product) {
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
