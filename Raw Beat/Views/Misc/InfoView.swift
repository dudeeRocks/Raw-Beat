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
                        Text(String(localized: "Version \(appVersion)", comment: "Version of the app as shown in Info sheet."))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Text(InfoViewText.about.text)
                        .fontWeight(.medium)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 500.0)
                    
                    // MARK: - Tip Card
                    if !store.products.isEmpty {
                        VStack(alignment: .center, spacing: 20.0) {
                            VStack(alignment: .leading, spacing: isCompact ? 5.0 : 10.0) {
                                Text(InfoViewText.tipCardTitle.text)
                                    .font(.title3)
                                    .fontWeight(.black)
                                Text(InfoViewText.tipCardDescription.text)
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
                            
                            Text(InfoViewText.tipCardNote.text)
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
                    }
                    
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
                        Text(String(localized: "Developed by", comment: "Text above Dudee logo on Info sheet."))
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
                .overlay {
                    GeometryReader { geometry in
                        Color.clear.preference(key: InfoViewHeight.self, value: geometry.size.height)
                    }
                }
            }
        }
        .fullScreenCover(item: $purchasedTip) { tip in
            ThankYouNote(tip: tip, onDismiss: { purchasedTip = nil })
        }
    }
    
    enum InfoViewText {
        case about, tipCardTitle, tipCardDescription, tipCardNote
        
        var text: String {
            switch self {
            case .about:
                return String(localized: "Thanks for downloading Raw Beat—a simple metronome designed and developed by an amateur musician.", comment: "Text about the app in Info sheet.")
            case .tipCardTitle:
                return String(localized: "Tip the developer", comment: "Title of the 'tip the developer' card.")
            case .tipCardDescription:
                return String(localized: "I don't run ads in this app, and it's free for you forever. If you find it useful, please consider treating me to a drink.", comment: "Tip card description. Explains my reasoning behind tips feature.")
            case .tipCardNote:
                return String(localized: "Note: These purchases won't unlock any features, but they'll help support the app's development.", comment: "Note that explains that Tip IAP won't unlock features.")
            }
        }
    }
}

#Preview {
    @StateObject var store = Store()
    return InfoView().environmentObject(store)
}
