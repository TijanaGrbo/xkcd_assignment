//
//  MainCoordinator.swift
//  xkcd_assignment
//
//  Created by Tijana on 01/03/2023.
//

import UIKit

final class MainCoordinator {
    private var navController: UINavigationController
    private let storageProvider: StorageProvider
    
    init(navController: UINavigationController, storageProvider: StorageProvider) {
        self.navController = navController
        self.storageProvider = storageProvider
    }
    
    func start() {
        let browseVM = BrowseViewModel(storageProvider: storageProvider)
        let browseVC = ComicViewerVC(coordinator: self, viewModel: browseVM)
        
        let favouritesVM = FavouritesViewModel(storageProvider: storageProvider)
        let favouritesVC = ComicViewerVC(coordinator: self, viewModel: favouritesVM)
        
        let searchVM = SearchViewModel()
        let searchVC = SearchVC(coordinator: self, searchViewModel: searchVM)
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [browseVC, favouritesVC, searchVC]
        
        let tabBarItemConfig = UIImage.SymbolConfiguration(textStyle: .footnote)
        tabBarController.tabBar.items?[0].title = "Browse".localized()
        tabBarController.tabBar.items?[0].image = UIImage(systemName: "photo.stack.fill", withConfiguration: tabBarItemConfig)
        tabBarController.tabBar.items?[1].title = "Favourites".localized()
        tabBarController.tabBar.items?[1].image = UIImage(systemName: "sparkles.rectangle.stack.fill", withConfiguration: tabBarItemConfig)
        tabBarController.tabBar.items?[2].title = "Search".localized()
        tabBarController.tabBar.items?[2].image = UIImage(systemName: "mail.and.text.magnifyingglass", withConfiguration: tabBarItemConfig)
        
        tabBarController.tabBar.tintColor = UIColor(.black)
        tabBarController.tabBar.unselectedItemTintColor = UIColor(.black).withAlphaComponent(0.4)
        
        navController.pushViewController(tabBarController, animated: true)
    }
    
    func shareComic(_ url: URL) {
        let shareViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        navController.present(shareViewController, animated: true, completion: nil)
    }
    
    func showDetail(title: String, description: String, url: URL?) {
        let vc = ComicDetailVC(title: title,
                               description: description,
                               url: url)
        navController.present(vc, animated: true)
    }

}
