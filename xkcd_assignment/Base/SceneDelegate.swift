//
//  SceneDelegate.swift
//  xkcd_assignment
//
//  Created by Tijana on 01/03/2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var coordinator: MainCoordinator!
    let storageProvider = StorageProvider()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        self.window = UIWindow(windowScene: windowScene)
        let navController = UINavigationController()
        self.coordinator = MainCoordinator(navController: navController, storageProvider: storageProvider)
        self.coordinator.start()
        self.window?.rootViewController = navController
        self.window?.makeKeyAndVisible()
    }
}
