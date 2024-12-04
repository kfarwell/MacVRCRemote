import SwiftUI

struct ChatInputView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var message: String = ""
    @FocusState private var isFocused: Bool

    var onSend: (String) -> Void

    var body: some View {
        VStack(spacing: 15) {
            TextField("Input Chatbox Text", text: $message)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 300)
                .padding(.bottom, 10)
                .focused($isFocused)
                .onAppear {
                    self.isFocused = true
                    NSApp.activate(ignoringOtherApps: true)
                }

            HStack {
                Spacer()
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .keyboardShortcut(.cancelAction)
                Button("Send") {
                    onSend(message)
                    presentationMode.wrappedValue.dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(message.isEmpty)
            }
        }
        .padding()
        .frame(width: 350)
    }
}
