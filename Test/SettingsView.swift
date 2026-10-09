import SwiftUI
import LocalAuthentication

var x = "0.0.1"
var github = "https://github.com/wirenux"

struct SettingsView: View {
    @State private var notifSound = true
    @State private var notifBanner = true
    @State private var notifList = true
    
    @State var notifTitle: String = ""
    @State var notifMessage: String = ""
    
    @State private var securityStatus = "Non-tested"
    @State private var statusColor = Color.gray
    
    @State private var showAlert = false
    @State private var alertMessage: String? = nil

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Notifications")) {
                    Button(action: {
                        NotificationManager.shared.sendInstantNotification(
                            sound: notifSound,
                            banner: notifBanner,
                            list: notifList,
                            title: notifTitle,
                            message: notifMessage
                        )
                    }) {
                        HStack {
                            Image(systemName: "bell.badge.fill")
                            Text("Send notification")
                                .font(.headline)
                        }
                    }
                    Toggle(" Sound", systemImage: "speaker.wave.2" ,isOn: $notifSound)
                    Toggle(" Banner", systemImage: "app.badge" ,isOn: $notifBanner)
                    Toggle(" List", systemImage: "list.bullet" ,isOn: $notifList)

                    HStack {
                        Image(systemName: "pencil.line")
                            .foregroundStyle(.blue)
                        Text("Title:")
                        TextField("Required", text: $notifTitle)
                    }

                    HStack {
                        Image(systemName: "text.bubble")
                            .foregroundStyle(.blue)
                        Text("Body:")
                        TextField("Hi !", text: $notifMessage)
                    }
                }
                
                Section(header: Text("Security")) {
                    Button(action: {
                        testBiometrics()
                    }) {
                        HStack {
                            Image(systemName: "faceid")
                                .font(.title3)
                            Text("Test Face ID / Password")
                                .font(.headline)
                        }
                    }
                    
                    HStack {
                        Text("Status:")
                        Spacer()
                        Text(securityStatus)
                            .foregroundColor(statusColor)
                            .bold()
                    }
                }
                
                Section(header: Text("Alerts")) {
                    Button(action: {
                        alertMessage = "Hi :D hyd ?"
                        showAlert = true
                    }) {
                        HStack {
                            Text("Test Native Alert")
                                .font(.headline)
                        }
                    }
                }
                
                Section(header: Text("Location")) {
                    Button(action: {
                        LocationManager.shared.openCurrentLocationInMaps()
                    }) {
                        HStack {
                            Image(systemName: "map.fill")
                                .foregroundColor(.blue)
                            Text("Open Current Location in Maps")
                                .font(.headline)
                        }
                    }
                }
                
                Section(header: Text("About")) {
                    Text("Version: \(x)")
                    Link("Github Profile", destination: URL(string: github)!)
                        .font(.headline)
                        .foregroundStyle(.blue)
                }
            }
            .navigationTitle("Settings")
            .onChange(of: notifBanner) { oldValue, newValue in
                if newValue == true {
                    notifList = true
                }
            }
            .alert(
                "Test Alert",
                isPresented: $showAlert,
                presenting: alertMessage
            ) { data in
                Button("OK", role: .cancel) { }
            } message: { data in
                Text(data)
            }
        }
    }
    
    func testBiometrics() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "Veuillez vous authentifier pour tester la sécurité."

            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self.securityStatus = "Nice :)"
                        self.statusColor = .green
                    } else {
                        self.securityStatus = "Not nice :("
                        self.statusColor = .red
                    }
                }
            }
        } else {
            self.securityStatus = "Non disponible"
            self.statusColor = .orange
        }
    }
}

#Preview {
    SettingsView()
}
