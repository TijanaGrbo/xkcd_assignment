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
        let browseVM = BrowseViewModel(storageProvider: storageProvider)
        let browseVC = BrowseVC(coordinator: self, viewModel: browseVM)
        
        let favouritesVM = BrowseViewModel(storageProvider: storageProvider)
        let fabouritesVC = BrowseVC(coordinator: self, viewModel: favouritesVM)
        
        let searchVM = SearchViewModel()
        let searchVC = SearchVC(searchViewModel: searchVM)
        
        let tabBar = TabBarVC()
        tabBar.viewControllers = [browseVC, fabouritesVC, searchVC]
        tabBar.tabBar.items?[0].title = "Browse"
        tabBar.tabBar.items?[1].title = "Favourites"
        tabBar.tabBar.items?[2].title = "Search"
        
        navController.pushViewController(tabBar, animated: true)
    }
}
