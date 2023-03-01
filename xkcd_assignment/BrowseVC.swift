//
//  BrowseVC.swift
//  xkcd_assignment
//
//  Created by Tijana on 01/03/2023.
//

import UIKit

class BrowseVC: UIViewController {
    
    @IBOutlet weak var comicImageView: UIImageView!
    
    var coordinator: MainCoordinator
    
    init(coordinator: MainCoordinator, viewModel: BrowseViewModel) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
