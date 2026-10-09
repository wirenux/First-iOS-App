import SwiftUI
import UserNotifications
import CoreLocation
import MapKit

func requestNotificationPermission() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
        if granted {
            print("Notification Granted")
        } else if let error = error {
            print("Error notification : \(error.localizedDescription)")
        }
    }
}

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    
    private var currentSoundSetting = true
    private var currentBannerSetting = true
    private var currentListSetting = true
    private var currentTitle: String = ""
    private var currentMessage: String = ""
    
    override private init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    func sendInstantNotification(sound: Bool, banner: Bool, list: Bool, title: String, message: String) {
        self.currentSoundSetting = sound
        self.currentBannerSetting = banner
        self.currentListSetting = list
        self.currentTitle = title
        self.currentMessage = message

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            guard granted else { return }
            
            let content = UNMutableNotificationContent()
            content.title = self.currentTitle
            content.body = self.currentMessage

            if sound {
                content.sound = .default
            }

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        var options: UNNotificationPresentationOptions = []

        if currentBannerSetting { options.insert(.banner) }
        if currentListSetting   { options.insert(.list) }
        if currentSoundSetting  { options.insert(.sound) }

        completionHandler(options)
    }
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    
    private let manager = CLLocationManager()
    private var isAwaitingLocation = false
    
    override private init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func openCurrentLocationInMaps() {
        isAwaitingLocation = true
        
        // 1. Vérifie le statut d'autorisation
        let status = manager.authorizationStatus
        if status == .notDetermined {
            manager.requestWhenInUseAuthorization()
        } else if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.requestLocation()
        } else {
            print("loc refused in the iphone settings")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first, isAwaitingLocation else { return }
        isAwaitingLocation = false // Évite les ouvertures multiples
        
        let coordinate = location.coordinate
        
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "Current position"
        
        
        let launchOptions = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: coordinate)]
        mapItem.openInMaps(launchOptions: launchOptions)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("geoloc error : \(error.localizedDescription)")
    }
    
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse && isAwaitingLocation {
            manager.requestLocation()
        }
    }
}

struct MainContentView: View {
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {

                    Image("ProfilePhoto")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 130, height: 130)
                        .clipShape(Circle())
                        .overlay {
                            Circle()
                                .stroke(
                                    Color.accentColor.opacity(0.5),
                                    lineWidth: 3
                                )
                        }
                        .shadow(
                            color: .black.opacity(0.15),
                            radius: 12,
                            y: 6
                        )
                        .padding(.top, 30)

                    VStack(spacing: 8) {
                        Text("Hi, I'm @wirneux 👋")
                            .font(.largeTitle.bold())
                            .multilineTextAlignment(.center)

                        Text("Welcome to my first iOS App :D !")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Label("About Me", systemImage: "person.text.rectangle")
                            .font(.title2.bold())

                        Text("""
                        I'm @wirenux, and this is my first iOS app.

                        I mostly do desktop app or CLI but why not test iOS app :D

                        Thanks for reading :D !
                        """)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .lineSpacing(5)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .background(
                        Color(uiColor: .secondarySystemBackground)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                    Link(
                        destination: URL(
                            string: "https://wirenux.com"
                        )!
                    ) {
                        HStack(spacing: 10) {
                            Image(systemName: "globe")
                            Text("Discover My Portfolio")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                        }
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(18)
                        .background(Color.accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }

                    VStack(spacing: 10) {
                        Image(systemName: "iphone.gen3")
                            .font(.system(size: 32))
                            .foregroundStyle(.tint)

                        Text("My First iOS App")
                            .font(.headline)

                        Text("Built with SwiftUI, curiosity, and a desire to learn.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)

                    Text("Made by @wirenux")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .padding(.bottom, 20)
                }
                .padding(.horizontal, 22)
            }
            .background(Color(uiColor: .systemBackground))
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house.fill") {
                MainContentView()
            }
            
            Tab("Settings", systemImage: "gear") {
                SettingsView()
                    .navigationTitle("Settings")
                    .navigationBarTitleDisplayMode(.automatic)
            }
        }
        .onAppear {
            _ = NotificationManager.shared
        }
    }
}

#Preview {
    ContentView()
}
