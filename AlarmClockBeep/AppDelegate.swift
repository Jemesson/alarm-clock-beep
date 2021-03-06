//
//  AppDelegate.swift
//  AlarmClockBeep
//
//  Created by Jemesson Lima on 22/04/21.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    lazy var persistentContainer: NSPersistentContainer = {
        let identifier = NSPersistentContainer(name: "AlarmClockBeep")

        identifier.loadPersistentStores(completionHandler: { (_ , error) in
            if let error = error as NSError? {
                fatalError("Error: (\(error), \(error.userInfo))")
            }
        })

        return identifier
    }()

    func saveContext () {
        let context = persistentContainer.viewContext

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let error = error as NSError
                fatalError("Error: (\(error), \(error.userInfo))")
            }
        }
    }
}
