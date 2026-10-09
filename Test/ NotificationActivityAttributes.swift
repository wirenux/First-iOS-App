import Foundation
import ActivityKit

struct NotificationActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Données dynamiques (qui peuvent changer en temps réel)
        var currentStatus: String
        var progress: Double // Valeur entre 0.0 et 1.0
    }

    // Données statiques (qui ne changent jamais après le lancement)
    var activityName: String
}
