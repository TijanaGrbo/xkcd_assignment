//
//  TabBarVC.swift
//  xkcd_assignment
//
//  Created by Tijana on 02/03/2023.
//

import UIKit

class TabBarVC: UITabBarController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = UIColor(.primary)
        tabBar.unselectedItemTintColor = UIColor(.primary).withAlphaComponent(0.4)
    }
}
