import SwiftUI

// MARK: - Action Types & Emphasis

public enum MockRallyActionType {
    case primary, destructive
}

public struct MockRallyActionAttributes {
    let type: MockRallyActionType
    let title: String
    let isLoading: Bool
    let disabled: Bool
    let accessibilityIdentifier: String?
    let action: () -> Void

    public init(
        type: MockRallyActionType = .primary,
        title: String,
        isLoading: Bool = false,
        disabled: Bool = false,
        accessibilityIdentifier: String? = nil,
        action: @escaping () -> Void
    ) {
        self.type = type
        self.title = title
        self.isLoading = isLoading
        self.disabled = disabled
        self.accessibilityIdentifier = accessibilityIdentifier
        self.action = action
    }
}

public enum MockRallyActionEmphasis {
    case primary(MockRallyActionAttributes)
    case secondary(MockRallyActionAttributes)
    case tertiary(MockRallyActionAttributes)

    @ViewBuilder func createButton() -> some View {
        switch self {
        case .primary(let attrs):
            Button(action: attrs.action) {
                if attrs.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                } else {
                    Text(attrs.title)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
            }
            .background(attrs.type == .destructive ? Color.red : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .disabled(attrs.disabled)
            .accessibilityIdentifier(attrs.accessibilityIdentifier ?? attrs.title)

        case .secondary(let attrs):
            Button(action: attrs.action) {
                if attrs.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                } else {
                    Text(attrs.title)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
            }
            .background(Color.clear)
            .foregroundColor(attrs.type == .destructive ? .red : .blue)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(attrs.type == .destructive ? Color.red : Color.blue, lineWidth: 1)
            )
            .cornerRadius(8)
            .disabled(attrs.disabled)
            .accessibilityIdentifier(attrs.accessibilityIdentifier ?? attrs.title)

        case .tertiary(let attrs):
            Button(action: attrs.action) {
                if attrs.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                } else {
                    Text(attrs.title)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
            }
            .background(Color.blue.opacity(0.1))
            .foregroundColor(attrs.type == .destructive ? .red : .blue)
            .cornerRadius(8)
            .disabled(attrs.disabled)
            .accessibilityIdentifier(attrs.accessibilityIdentifier ?? attrs.title)
        }
    }
}

// MARK: - Action Sheet Content View

public struct MockRallyActionSheetContentView: View {
    private let iconSystemName: String?
    private let iconColor: Color
    private let titleText: String?
    private let bodyText: String?
    private let actions: [MockRallyActionEmphasis]

    public init(
        titleText: String?,
        bodyText: String?,
        action1: MockRallyActionEmphasis,
        action2: MockRallyActionEmphasis? = nil,
        action3: MockRallyActionEmphasis? = nil,
        action4: MockRallyActionEmphasis? = nil,
        action5: MockRallyActionEmphasis? = nil
    ) {
        self.iconSystemName = nil
        self.iconColor = .clear
        self.titleText = titleText
        self.bodyText = bodyText
        self.actions = [action1, action2, action3, action4, action5].compactMap { $0 }
    }

    public init(
        iconSystemName: String,
        iconColor: Color,
        titleText: String?,
        bodyText: String?,
        action1: MockRallyActionEmphasis,
        action2: MockRallyActionEmphasis? = nil,
        action3: MockRallyActionEmphasis? = nil,
        action4: MockRallyActionEmphasis? = nil,
        action5: MockRallyActionEmphasis? = nil
    ) {
        self.iconSystemName = iconSystemName
        self.iconColor = iconColor
        self.titleText = titleText
        self.bodyText = bodyText
        self.actions = [action1, action2, action3, action4, action5].compactMap { $0 }
    }

    public var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    if let iconSystemName {
                        Image(systemName: iconSystemName)
                            .font(.system(size: 32))
                            .foregroundColor(iconColor)
                    }
                    if let titleText {
                        Text(titleText)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .accessibilityAddTraits([.isHeader])
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    if let bodyText {
                        Text(bodyText)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                Spacer()
            }
            VStack(alignment: .leading, spacing: 8) {
                ForEach(0..<actions.count, id: \.self) { index in
                    actions[index].createButton()
                        .accessibilityRespondsToUserInteraction(true)
                }
            }
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Sheet Behavior

public enum MockRallySheetBehavior {
    case fullscreen(dismissable: Bool, dimBackground: Bool = true)
    case bottomSheet(dismissable: Bool, dimBackground: Bool = true)
    case resizable(dismissable: Bool, detents: Set<PresentationDetent>, dimBackground: Bool = false)

    var showHandle: Bool {
        switch self {
        case .fullscreen:
            return false
        case .bottomSheet:
            return false
        case .resizable(_, let detents, _):
            return detents.count > 1
        }
    }

    var isDismissable: Bool {
        switch self {
        case .fullscreen(let dismissable, _),
             .bottomSheet(let dismissable, _),
             .resizable(let dismissable, _, _):
            return dismissable
        }
    }

    var hasDimmedBackground: Bool {
        switch self {
        case .fullscreen(_, let dim),
             .bottomSheet(_, let dim),
             .resizable(_, _, let dim):
            return dim
        }
    }

    var isFullscreen: Bool {
        if case .fullscreen = self { return true }
        return false
    }

    var isContentFittedSheet: Bool {
        if case .bottomSheet = self { return true }
        return false
    }

    func detents(sheetHeight: CGFloat? = nil) -> Set<PresentationDetent> {
        switch self {
        case .fullscreen:
            return [.large]
        case .bottomSheet:
            if let sheetHeight {
                return [.height(sheetHeight)]
            }
            return [.medium]
        case .resizable(_, let detents, _):
            return detents
        }
    }
}

// MARK: - Sheet ViewModifier

struct MockRallySheet<ContentView: View>: ViewModifier {
    @Binding var isPresented: Bool
    let sheetBehavior: MockRallySheetBehavior
    let contentBuilder: () -> ContentView
    let onDismiss: (() -> Void)?

    init(
        isPresented: Binding<Bool>,
        sheetBehavior: MockRallySheetBehavior,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder contentBuilder: @escaping () -> ContentView
    ) {
        self._isPresented = isPresented
        self.sheetBehavior = sheetBehavior
        self.onDismiss = onDismiss
        self.contentBuilder = contentBuilder
    }

    private func contentHeight(givenMaxWidth maxWidth: CGFloat) -> CGFloat {
        let hostingController = UIHostingController(rootView: contentBuilder())
        let size = hostingController.sizeThatFits(in: CGSize(
            width: maxWidth,
            height: .greatestFiniteMagnitude)
        )
        return size.height + (sheetBehavior.isFullscreen ? 0.0 : 32)
    }

    func body(content: Content) -> some View {
        if sheetBehavior.isContentFittedSheet {
            content.sheet(isPresented: $isPresented, onDismiss: onDismiss) {
                GeometryReader { reader in
                    VStack(spacing: 0) {
                        contentBuilder()
                            .fixedSize(horizontal: false, vertical: !sheetBehavior.isFullscreen)
                            .padding(.top, sheetBehavior.isFullscreen ? 0.0 : 16)
                            .padding(.bottom, sheetBehavior.isFullscreen ? 0.0 : 16)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(10)
                    .presentationDetents(sheetBehavior.detents(
                        sheetHeight: contentHeight(givenMaxWidth: reader.size.width)
                    ))
                    .presentationDragIndicator(sheetBehavior.showHandle ? .visible : .hidden)
                    .interactiveDismissDisabled(!sheetBehavior.isDismissable)
                    .presentationBackgroundInteraction(
                        sheetBehavior.hasDimmedBackground ? .automatic : .enabled
                    )
                }
            }
        } else {
            content.sheet(isPresented: $isPresented, onDismiss: onDismiss) {
                VStack(spacing: 0) {
                    contentBuilder()
                        .fixedSize(horizontal: false, vertical: !sheetBehavior.isFullscreen)
                        .padding(.top, sheetBehavior.isFullscreen ? 0.0 : 16)
                        .padding(.bottom, sheetBehavior.isFullscreen ? 0.0 : 16)
                }
                .frame(maxWidth: .infinity)
                .background(Color(UIColor.systemBackground))
                .cornerRadius(10)
                .presentationDetents(sheetBehavior.detents())
                .presentationDragIndicator(sheetBehavior.showHandle ? .visible : .hidden)
                .interactiveDismissDisabled(!sheetBehavior.isDismissable)
                .presentationBackgroundInteraction(
                    sheetBehavior.hasDimmedBackground ? .automatic : .enabled
                )
            }
        }
    }
}

// MARK: - View Extensions

public extension View {
    /// Shortcut to create a mock RallySheet that contains a MockRallyActionSheetContentView.
    func mockRallyActionSheet(
        isPresented: Binding<Bool>,
        dismissable: Bool = false,
        titleText: String?,
        bodyText: String?,
        action1: MockRallyActionEmphasis,
        action2: MockRallyActionEmphasis? = nil,
        action3: MockRallyActionEmphasis? = nil,
        action4: MockRallyActionEmphasis? = nil,
        action5: MockRallyActionEmphasis? = nil
    ) -> some View {
        self.modifier(
            MockRallySheet(
                isPresented: isPresented,
                sheetBehavior: .bottomSheet(
                    dismissable: dismissable,
                    dimBackground: true
                ),
                contentBuilder: {
                    MockRallyActionSheetContentView(
                        titleText: titleText,
                        bodyText: bodyText,
                        action1: action1,
                        action2: action2,
                        action3: action3,
                        action4: action4,
                        action5: action5
                    )
                    .accessibilityIdentifier("mockRallyActionSheet")
                }
            )
        )
    }

    /// Shortcut with icon to create a mock RallySheet.
    func mockRallyActionSheet(
        isPresented: Binding<Bool>,
        dismissable: Bool = false,
        iconSystemName: String,
        iconColor: Color,
        titleText: String?,
        bodyText: String?,
        action1: MockRallyActionEmphasis,
        action2: MockRallyActionEmphasis? = nil,
        action3: MockRallyActionEmphasis? = nil,
        action4: MockRallyActionEmphasis? = nil,
        action5: MockRallyActionEmphasis? = nil
    ) -> some View {
        self.modifier(
            MockRallySheet(
                isPresented: isPresented,
                sheetBehavior: .bottomSheet(
                    dismissable: dismissable,
                    dimBackground: true
                ),
                contentBuilder: {
                    MockRallyActionSheetContentView(
                        iconSystemName: iconSystemName,
                        iconColor: iconColor,
                        titleText: titleText,
                        bodyText: bodyText,
                        action1: action1,
                        action2: action2,
                        action3: action3,
                        action4: action4,
                        action5: action5
                    )
                    .accessibilityIdentifier("mockRallyActionSheet")
                }
            )
        )
    }

    /// Generic sheet with item binding (similar to Rally's implementation).
    func mockRallyActionSheet<ItemType: Identifiable>(
        item: Binding<ItemType?>,
        dismissable: Bool = false,
        contentBuilder: @escaping (ItemType) -> MockRallyActionSheetContentView
    ) -> some View {
        self.sheet(item: item) { shownItem in
            GeometryReader { reader in
                VStack(spacing: 0) {
                    contentBuilder(shownItem)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.vertical, 16)
                }
                .frame(maxWidth: .infinity)
                .background(Color(UIColor.systemBackground))
                .cornerRadius(10)
                .presentationDetents([.height(calculateContentHeight(
                    content: contentBuilder(shownItem),
                    maxWidth: reader.size.width
                ))])
                .presentationDragIndicator(.hidden)
                .interactiveDismissDisabled(!dismissable)
                .accessibilityIdentifier("mockRallyActionSheet")
            }
        }
    }
}

// MARK: - Helper Functions

private func calculateContentHeight<V: View>(content: V, maxWidth: CGFloat) -> CGFloat {
    let hostingController = UIHostingController(rootView: content)
    let size = hostingController.sizeThatFits(in: CGSize(
        width: maxWidth,
        height: .greatestFiniteMagnitude
    ))
    return size.height + 32
}

// MARK: - Previews

#Preview("Mock Action Sheet") {
    Color.clear
        .mockRallyActionSheet(
            isPresented: .constant(true),
            titleText: "Check the organization number",
            bodyText: "We can't register an account for this number. Check the number you entered or contact Customer Care.",
            action1: .primary(MockRallyActionAttributes(
                type: .primary,
                title: "Primary Action",
                accessibilityIdentifier: "primaryButton",
                action: {}
            )),
            action2: .secondary(MockRallyActionAttributes(
                type: .primary,
                title: "Secondary Action",
                accessibilityIdentifier: "secondaryButton",
                action: {}
            ))
        )
}

#Preview("Mock Action Sheet with Icon") {
    Color.clear
        .mockRallyActionSheet(
            isPresented: .constant(true),
            iconSystemName: "creditcard",
            iconColor: .green,
            titleText: "Add Payment Method",
            bodyText: "Choose how you'd like to pay for parking.",
            action1: .primary(MockRallyActionAttributes(
                title: "Add Credit Card",
                accessibilityIdentifier: "addCardButton",
                action: {}
            ))
        )
}
