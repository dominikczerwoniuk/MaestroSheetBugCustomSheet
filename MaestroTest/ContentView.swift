import SwiftUI

struct ContentView: View {

    @State var isOpen: Bool = false
    @State var isFullScreenOpen: Bool = false
    @State var sheetHeight: CGFloat = 0.5
    @State var showCustomSheet = false

    var body: some View {
        VStack {
            Text("Hello, world!")
                .font(.title)

            Spacer()

            Text("\(Int(sheetHeight*100)) %")

            HStack {
                Text("0 %")
                Slider(value: $sheetHeight, in: 0...1)
                Text("100 %")
            }

            Spacer()

            HStack {
                Button("Open FullScreen") {
                    isFullScreenOpen = true
                }
                Button("Open Sheet") {
                    isOpen = true
                }
                Button("Show Action Sheet") {
                    showCustomSheet = true
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .fullScreenCover(isPresented: $isFullScreenOpen) {
            FullScreenCoverView()
        }
        .sheet(isPresented: $isOpen) {
            SheetView(sheetHeight: $sheetHeight)
        }
        .mockCustomActionSheet(
            isPresented: $showCustomSheet,
            dismissable: true,
            titleText: "Confirm Action",
            bodyText: "Are you sure you want to proceed?",
            action1: .primary(MockCustomActionAttributes(
                title: "Confirm",
                accessibilityIdentifier: "confirmButton",
                action: { showCustomSheet = false }
            )),
            action2: .secondary(MockCustomActionAttributes(
                title: "Cancel",
                accessibilityIdentifier: "cancelButton",
                action: { showCustomSheet = false }
            ))
        )
    }

    private func openSheet(to height: CGFloat) {
        sheetHeight = height/100
        isOpen = true
    }
}

#Preview {
    ContentView()
}
