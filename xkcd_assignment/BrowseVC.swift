//
//  BrowseVC.swift
//  xkcd_assignment
//
//  Created by Tijana on 01/03/2023.
//

import UIKit

class BrowseVC: UIViewController {
    
    @IBOutlet weak var comicImageView: UIImageView!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var latestButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    var coordinator: MainCoordinator
    var browseViewModel: BrowseViewModel
    
    init(coordinator: MainCoordinator, viewModel: BrowseViewModel) {
        self.coordinator = coordinator
        self.browseViewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    func setupViews() {
        Task {
            await browseViewModel.getLatestComic()
            DispatchQueue.main.async {
                self.comicImageView.kf.setImage(with: self.browseViewModel.comic?.imgURL)
            }
        }
    }
    
    @IBAction func previousButtonTapped(_ sender: Any) {
        Task {
            await browseViewModel.getPreviousComic()
        }
    }
    
    @IBAction func latestButtonTapped(_ sender: Any) {
        Task {
            await browseViewModel.getLatestComic()
        }
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        Task {
            await browseViewModel.getNextComic()
        }
    }
}
