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
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var comicTitle: UILabel!
    @IBOutlet weak var comicNum: UILabel!
    
    var coordinator: MainCoordinator
    var viewModel: ComicViewModel
    
    var cancelable: AnyCancellable?
    var comic: Comic? { didSet {
        refreshViews()
    }}
    var favouriteComic: FavouriteComic? { didSet {
        reloadFavourites()
    }}
    var isLiked: Bool? { didSet {
        refreshFavouriteButton()
    }}
    
    init(coordinator: MainCoordinator, viewModel: ComicViewModel) {
        self.coordinator = coordinator
        self.viewModel = viewModel
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
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel.loadFromFavourites()
        refreshFavouriteButton()
        refreshButtonState()
    }
    
    func setupViews() {
        Task {
            await viewModel.getLatestComic()
            setupBackground()
            setupNavigationButtons()
            setupAccessibilityIdentifiers()
            setupShareButton()
            setupFavouriteButton()
            refreshViews()
        }
    }
    
    func bindViewModel() {
        if let browseViewModel = viewModel as? BrowseViewModel {
            cancelable = browseViewModel.$comic
                .receive(on: DispatchQueue.main)
                .assign(to: \.comic, on: self)
        } else if let favouritesViewModel = viewModel as? FavouritesViewModel {
            cancelable = favouritesViewModel.$comic
                .receive(on: DispatchQueue.main)
                .assign(to: \.favouriteComic, on: self)
        }
    }
    
    func setupBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.bottomGradientColor,
                                UIColor.middleGradientColor,
                                UIColor.topGradientColor]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        gradientLayer.frame = view.bounds
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        comicImageView.layer.compositingFilter = "multiplyBlendMode"
    }
    
    func setupHeaderLabels() {
        comicTitle.text = viewModel.setComicTitle()
        comicTitle.font = .monospacedSystemFont(ofSize: 28, weight: .black)
        comicNum.text = viewModel.setComicNum()
        comicNum.font = .monospacedDigitSystemFont(ofSize: 18, weight: .bold)
    }
    
    func setupShareButton() {
        shareButton.setImage(UIImage(systemName: "square.and.arrow.up.fill"), for: .normal)
        shareButton.tintColor = UIColor(.black)
    }
    
    func setupFavouriteButton() {
        favouriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        refreshFavouriteButton()
    }
    
    func refreshFavouriteButton() {
        favouriteButton.tintColor = viewModel.checkIfLiked() ? UIColor.favouriteButtonColor : UIColor(.black)
    }
    
    func setupNavigationButtons() {
        let prevNextonfiguration = UIImage.SymbolConfiguration(textStyle: .title2)
        let latestButtonConfiguration = UIImage.SymbolConfiguration(textStyle: .body)
        
        let previousButtonImage = UIImage(systemName: "arrowtriangle.backward.fill", withConfiguration: prevNextonfiguration)
        let latestButtonImage = UIImage(systemName: "diamond.fill", withConfiguration: latestButtonConfiguration)
        let nextButtonImage = UIImage(systemName: "arrowtriangle.forward.fill", withConfiguration: prevNextonfiguration)
        
        refreshButtonState()
        
        previousButton.setImage(previousButtonImage, for: .normal)
        latestButton.setImage(latestButtonImage, for: .normal)
        nextButton.setImage(nextButtonImage, for: .normal)
    }
    
    func refreshButtonState() {
        previousButton.isEnabled = viewModel.getPreviousButtonState()
        latestButton.isEnabled = viewModel.getLatestButtonState()
        nextButton.isEnabled = viewModel.getNextButtonState()

        previousButton.tintColor = .black.withAlphaComponent(viewModel.getPreviousButtonState() ? 1.0 : 0.6)
        latestButton.tintColor = .black.withAlphaComponent(viewModel.getLatestButtonState() ? 1.0 : 0.6)
        nextButton.tintColor = .black.withAlphaComponent(viewModel.getNextButtonState() ? 1.0 : 0.6)
    }
    
    func refreshViews() {
        comicImageView.kf.setImage(with: self.viewModel.comicImageURL())
        setupHeaderLabels()
        refreshFavouriteButton()
        refreshButtonState()
        configureAccessibility()
    }
    
    func reloadFavourites() {
        comicImageView.image = viewModel.comicImage()
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
        configureAccessibility()
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        guard let imageURL = comic?.imgURL else { return }
        coordinator.shareComic(imageURL)
    }
}

extension BrowseVC {
    func setupAccessibilityIdentifiers() {
        comicNum.accessibilityIdentifier = AccessibilityIdentifier.comicNum.rawValue
        nextButton.accessibilityIdentifier = AccessibilityIdentifier.nextButton.rawValue
        previousButton.accessibilityIdentifier = AccessibilityIdentifier.prevButton.rawValue
        latestButton.accessibilityIdentifier = AccessibilityIdentifier.latestButton.rawValue
        comicImageView.accessibilityIdentifier = "\(comic?.num ?? 0)"
    }
    
    func configureAccessibility() {
        guard let comic = comic else { return }
        comicTitle.isAccessibilityElement = true
        comicTitle.accessibilityLabel = "Comic title: \(comic.title)"
        
        comicNum.isAccessibilityElement = true
        comicNum.accessibilityLabel = "Comic number: \(comic.num)"
        
        comicImageView.isAccessibilityElement = true
        comicImageView.accessibilityLabel = comic.alt
        
        previousButton.isAccessibilityElement = true
        previousButton.accessibilityLabel = "\(viewModel.getPreviousButtonState() ? "Show previous comic" : "")"
        
        latestButton.isAccessibilityElement = true
        latestButton.accessibilityLabel = "\(viewModel.getLatestButtonState() ? "Show latest comic" : "")"
        
        nextButton.isAccessibilityElement = true
        nextButton.accessibilityLabel = "\(viewModel.getNextButtonState() ? "Show next comic" : "")"
        
        favouriteButton.isAccessibilityElement = true
        favouriteButton.accessibilityLabel = "\(viewModel.checkIfLiked() ? "Favourite" : "Not favourite"), double tap to \(viewModel.checkIfLiked() ? "remove from" : "add to") favourites"
    }
}
