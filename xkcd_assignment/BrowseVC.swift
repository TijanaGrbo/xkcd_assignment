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
        refreshFavouriteButton()
        refreshButtonState()
    }
    
    func setupViews() {
        Task {
            await browseViewModel.getLatestComic()
            setupHeaderLabels()
            setupNavigationButtons()
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
        favouriteButton.tintColor = UIColor(viewModel.checkIfLiked() ? .red : .black)
    }
    
    func setupNavigationButtons() {
        let prevNextonfiguration = UIImage.SymbolConfiguration(textStyle: .title2)
        let latestButtonConfiguration = UIImage.SymbolConfiguration(textStyle: .body)
        
        let previousButtonImage = UIImage(systemName: "arrowtriangle.backward.fill", withConfiguration: prevNextonfiguration)
        let latestButtonImage = UIImage(systemName: "diamond.fill", withConfiguration: latestButtonConfiguration)
        let nextButtonImage = UIImage(systemName: "arrowtriangle.forward.fill", withConfiguration: prevNextonfiguration)
        
        previousButton.isEnabled = viewModel.getPreviousButtonState()
        latestButton.isEnabled = viewModel.getLatestButtonState()
        nextButton.isEnabled = viewModel.getNextButtonState()
        
        #warning("forEach")
        previousButton.setTitle("", for: .normal)
        latestButton.setTitle("", for: .normal)
        nextButton.setTitle("", for: .normal)
        
        #warning("forEach")
        previousButton.tintColor = .black.withAlphaComponent(viewModel.getPreviousButtonState() ? 1.0 : 0.5)
        latestButton.tintColor = .black.withAlphaComponent(viewModel.getLatestButtonState() ? 1.0 : 0.5)
        nextButton.tintColor = .black.withAlphaComponent(viewModel.getNextButtonState() ? 1.0 : 0.5)
        
        previousButton.setImage(previousButtonImage, for: .normal)
        latestButton.setImage(latestButtonImage, for: .normal)
        nextButton.setImage(nextButtonImage, for: .normal)
    }
    
    func refreshButtonState() {
        previousButton.isEnabled = viewModel.getPreviousButtonState()
        latestButton.isEnabled = viewModel.getLatestButtonState()
        nextButton.isEnabled = viewModel.getNextButtonState()
        
        #warning("forEach")
        previousButton.tintColor = .black.withAlphaComponent(viewModel.getPreviousButtonState() ? 1.0 : 0.6)
        latestButton.tintColor = .black.withAlphaComponent(viewModel.getLatestButtonState() ? 1.0 : 0.6)
        nextButton.tintColor = .black.withAlphaComponent(viewModel.getNextButtonState() ? 1.0 : 0.6)
    }
    
    func refreshViews() {
        comicImageView.kf.setImage(with: self.browseViewModel.comic?.imgURL)
        setupHeaderLabels()
        refreshFavouriteButton()
        refreshButtonState()
        setupHeaderLabels()
        refreshFavouriteButton()
    }
    
    @IBAction func previousButtonTapped(_ sender: Any) {
        Task {
            await viewModel.getPreviousComic()
            refreshButtonState()
        }
    }
    
    @IBAction func latestButtonTapped(_ sender: Any) {
        Task {
            await viewModel.getLatestComic()
            refreshButtonState()
        }
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        Task {
            await viewModel.getNextComic()
            refreshButtonState()
        }
    }
    
    @IBAction func favouriteButtonTapped(_ sender: Any) {
        guard let comicImage = comicImageView.image else { return }
        viewModel.favouriteButtonTapped(comicImage: comicImage)
        refreshFavouriteButton()
    }
}
