//
//  ContentView.swift
//  Test
//
//  Created by Louis Lesniak on 09/10/2026.
//

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
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
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
            .badge("1")
        }
        .onAppear {
            _ = NotificationManager.shared
        }
    }
}

#Preview {
    ContentView()
}
