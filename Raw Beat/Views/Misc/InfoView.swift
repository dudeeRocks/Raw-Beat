// Abstract: view with info about the app and developer.

import SwiftUI

struct InfoView: View {
    @EnvironmentObject var store: Store
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    
    private var appVersion: String {
        var result: String = ""
        
        if let versionNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            result = versionNumber
        } else {
            Log.sharedInstance.log(error: "Failed to get the version number")
        }
        
        return result
    }
    
    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    private var logoSize: CGFloat {
        isCompact ? 64.0 : 100.0
    }
    
    private var globalPadding: CGFloat {
        isCompact ? 24.0 : 48.0
    }
    
    @State private var isThanksShown: Bool = false
    @State private var purchasedTip: Tip? = nil
    
    var body: some View {
        ZStack {
            LinearGradient(colors: .gradientStartColor, .gradientEndColor)
                .ignoresSafeArea()
            ScrollView {
                VStack(alignment: .center, spacing: 30.0) {
                    
                    // MARK: - Logo & Name
                    VStack(spacing: isCompact ? 5.0 : 10.0) {
                        
                        Image("AppIconImage")
                            .resizable()
                            .frame(width: logoSize, height: logoSize, alignment: .center)
                            .clipShape(RoundedRectangle(cornerRadius: logoSize * 0.25))
                            .shadow(color: .gradientEnd, radius: logoSize * 0.12, x: 0.0, y: logoSize * 0.06)
                        Text("Raw Beat")
                            .font(.title)
                            .fontWeight(.black)
                        Text("Version " + appVersion)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Text("Thanks for downloading Raw Beat—a simple metronome designed and developed by an amateur musician.")
                        .fontWeight(.medium)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 500.0)
                    
                    // MARK: - Tip Card
                    VStack(alignment: .center, spacing: 20.0) {
                        VStack(alignment: .leading, spacing: isCompact ? 5.0 : 10.0) {
                            Text("Tip the developer")
                                .font(.title3)
                                .fontWeight(.black)
                            Text("I don't run ads in this app, and it's free for you forever. If you find it useful, please consider treating me to a drink.")
                                .font(.callout)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.leading)
                        
                        ShopView(onPurchaseCompletion: { product in
                            if let tip = Tip(rawValue: product.id) {
                                purchasedTip = tip
                                withAnimation {
                                    isThanksShown = true
                                }
                                Log.sharedInstance.log(message: "ShopView registered successful purchase of '\(product.id)' \(tip.emoji)")
                            }
                        })
                        
                        Text("Note: These purchases won't unlock any features, but they'll help support the app's development.")
                            .font(.caption)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.center)
                    }
                    .padding(isCompact ? 18.0 : 36.0)
                    .background {
                        Color.gradientStartColor
                            .opacity(colorScheme == .dark ? 0.5 : 0.3)
                            .background(.ultraThinMaterial)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 20.0))
                    
                    // MARK: - Support links
                    HStack(spacing: 10.0) {
                        Link("Privacy Policy", destination: URL(string: "https://dudee.rocks/raw-beat-privacy-policy/")!)
                        Rectangle()
                            .fill(Color.primaryColor.opacity(0.5))
                            .frame(width: 0.5)
                        Link("Contact Support", destination: URL(string: "https://dudee.rocks/raw-beat-support/")!)
                    }
                    .font(.caption)
                    
                    // MARK: - Developer logo
                    VStack(alignment: .center, spacing: 5.0) {
                        Text("Developed by")
                            .font(.caption)
                        Link(destination: URL(string: "https://dudee.rocks")!, label: {
                            Image("dudee_logo")
                                .renderingMode(.template)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: isCompact ? 20.0 : 30.0)
                                .foregroundStyle(Color.primaryColor)
                        })
                    }
                }
                .foregroundStyle(Color.primaryColor)
                .padding(EdgeInsets(top: 60.0, leading: globalPadding, bottom: globalPadding, trailing: globalPadding))
            }
        }
        .fullScreenCover(item: $purchasedTip) { tip in
            ThankYouNote(tip: tip, onDismiss: { purchasedTip = nil })
        }
    }
}

#Preview {
    @StateObject var store = Store()
    return InfoView().environmentObject(store)
}
