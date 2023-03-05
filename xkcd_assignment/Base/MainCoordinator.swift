//
//  MainCoordinator.swift
//  xkcd_assignment
//
//  Created by Tijana on 01/03/2023.
//

import UIKit

    var navController: UINavigationController
    let storageProvider: StorageProvider
final class MainCoordinator {
    
    init(navController: UINavigationController, storageProvider: StorageProvider) {
        self.navController = navController
        self.storageProvider = storageProvider
    }
    
    func start() {
        let browseVM = BrowseViewModel(storageProvider: storageProvider)
        let browseVC = BrowseVC(coordinator: self, viewModel: browseVM)
        
        let favouritesVM = FavouritesViewModel(storageProvider: storageProvider)
        let favouritesVC = BrowseVC(coordinator: self, viewModel: favouritesVM)
        
        let searchVM = SearchViewModel()
        let searchVC = SearchVC(searchViewModel: searchVM)
        
        let tabBar = TabBarVC()
        tabBar.viewControllers = [browseVC, favouritesVC, searchVC]
        
        let tabBarItemConfig = UIImage.SymbolConfiguration(textStyle: .footnote)
        tabBar.tabBar.items?[0].title = "Browse"
        tabBar.tabBar.items?[0].image = UIImage(systemName: "circle.fill", withConfiguration: tabBarItemConfig)
        tabBar.tabBar.items?[1].title = "Favourites"
        tabBar.tabBar.items?[1].image = UIImage(systemName: "circle.fill", withConfiguration: tabBarItemConfig)
        tabBar.tabBar.items?[2].title = "Search"
        tabBar.tabBar.items?[2].image = UIImage(systemName: "circle.fill", withConfiguration: tabBarItemConfig)
        
        navController.pushViewController(tabBar, animated: true)
    }
    
    func shareComic(_ url: URL) {
        let shareViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        navController.present(shareViewController, animated: true, completion: nil)
    }
    
    func showDetail(title: String, description: String) {
        let vc = ComicDetailVC(title: title,
                               description: description)
        navController.present(vc, animated: true)
    }

}
