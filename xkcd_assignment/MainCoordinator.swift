//
//  MainCoordinator.swift
//  xkcd_assignment
//
//  Created by Tijana on 01/03/2023.
//

import UIKit

class MainCoordinator {
    var navController: UINavigationController
    let storageProvider: StorageProvider
    
    init(navController: UINavigationController, storageProvider: StorageProvider) {
        self.navController = navController
        self.storageProvider = storageProvider
    }
    
    func start() {
        let vm = BrowseViewModel()
        let vc = BrowseVC(coordinator: self, viewModel: vm)
        navController.pushViewController(vc, animated: true)
    }
}
