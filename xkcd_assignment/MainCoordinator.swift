//
//  MainCoordinator.swift
//  xkcd_assignment
//
//  Created by Tijana on 01/03/2023.
//

import UIKit

class MainCoordinator {
    var navController: UINavigationController
    
    init(navController: UINavigationController) {
        self.navController = navController
    }
    
    func start() {
        let vm = BrowseViewModel()
        let vc = BrowseVC(coordinator: self)
        navController.pushViewController(vc, animated: true)
    }
}
