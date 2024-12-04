import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode

    @State private var host: String = UserDefaults.standard.string(forKey: "OSCHost") ?? "127.0.0.1"
    @State private var port: String = {
        let savedPort = UserDefaults.standard.integer(forKey: "OSCPort")
        return savedPort == 0 ? "9000" : String(savedPort)
    }()
    @State private var quickMenuHand: String = UserDefaults.standard.string(forKey: "QuickMenuHand") ?? "Left"

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("VRChat/OSC Host:")
                TextField("Host", text: $host)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 120)
            }

            HStack {
                Text("Port:")
                TextField("Port", text: $port)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 60)
                    .onReceive(port.publisher.collect()) {
                        self.port = String($0.prefix(5))
                    }
            }

            HStack {
                Text("Quick Menu Hand:")
                Picker(selection: $quickMenuHand, label: Text("")) {
                    Text("Left").tag("Left")
                    Text("Right").tag("Right")
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 150)
            }

            Spacer()

            HStack {
                Spacer()
                Button("Save") {
                    saveSettings()
                }
            }
        }
        .padding()
    }

    private func saveSettings() {
        guard let portNumber = UInt16(port), portNumber > 0 else {
            return
        }

        UserDefaults.standard.set(host, forKey: "OSCHost")
        UserDefaults.standard.set(Int(portNumber), forKey: "OSCPort")
        UserDefaults.standard.set(quickMenuHand, forKey: "QuickMenuHand")

        OSCController.shared.updateSettings(host: host, port: Int(portNumber), quickMenuHand: quickMenuHand)

        presentationMode.wrappedValue.dismiss()
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
