//
//  BrowseVC.swift
//  xkcd_assignment
//
//  Created by Tijana on 01/03/2023.
//

import UIKit
import Combine

class BrowseVC: UIViewController {
    
    @IBOutlet weak var comicImageView: UIImageView!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var latestButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var comicTitle: UILabel!
    @IBOutlet weak var comicNum: UILabel!
    
    var coordinator: MainCoordinator
    var browseViewModel: BrowseViewModel
    
    var cancelable: AnyCancellable?
    var comic: Comic? { didSet {
        refreshViews()
    }}
    var isLiked: Bool? { didSet {
        setupFavouriteButton()
    }}
    
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
        bindViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("appear")
    }
    
    func setupViews() {
        Task {
            await browseViewModel.getLatestComic()
            setupHeaderLabels()
            setupFavouriteButton()
            refreshViews()
        }
    }
    
    func bindViewModel() {
        cancelable = browseViewModel.$comic
            .receive(on: DispatchQueue.main)
            .assign(to: \.comic, on: self)
    func setupHeaderLabels() {
        comicTitle.text = viewModel.setComicTitle()
        comicNum.text = viewModel.setComicNum()
    }
    
    func setupFavouriteButton() {
        favouriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        favouriteButton.setTitle("", for: .normal)
        refreshFavouriteButton()
    }
    
    func refreshFavouriteButton() {
        favouriteButton.tintColor = UIColor(browseViewModel.checkIfLiked() ? .red : .blue)
    }
    
    func refreshViews() {
        comicImageView.kf.setImage(with: self.browseViewModel.comic?.imgURL)
        setupHeaderLabels()
        setupHeaderLabels()
        refreshFavouriteButton()
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
    
    @IBAction func favouriteButtonTapped(_ sender: Any) {
        guard let comicImage = comicImageView.image else { return }
        browseViewModel.favouriteButtonTapped(comicImage: comicImage)
        refreshFavouriteButton()
    }
}
