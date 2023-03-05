//
//  BrowseVC.swift
//  xkcd_assignment
//
//  Created by Tijana on 01/03/2023.
//

import UIKit
import Combine

final class BrowseVC: UIViewController {
    
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
    
    private var cancelable: AnyCancellable?
    private var comic: Comic? { didSet {
        refreshViews()
    }}
    private var favouriteComic: FavouriteComic? { didSet {
        reloadFavourites()
    }}
    private var isLiked: Bool? { didSet {
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
    
    @objc func imageTapped() {
        coordinator.showDetail(title: comic?.title ?? "",
                               description: comic?.alt ?? "")
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

private extension BrowseVC {
    private func setupViews() {
        Task {
            await viewModel.getLatestComic()
            setupBackground()
            setupImage()
            setupNavigationButtons()
            setupAccessibilityIdentifiers()
            setupShareButton()
            setupFavouriteButton()
            refreshViews()
        }
    }
    
    private func bindViewModel() {
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
    
    private func setupBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.bottomGradientColor,
                                UIColor.middleGradientColor,
                                UIColor.topGradientColor]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        gradientLayer.frame = view.bounds
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func setupImage() {
        comicImageView.layer.compositingFilter = "multiplyBlendMode"
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        comicImageView.isUserInteractionEnabled = true
        comicImageView.addGestureRecognizer(tapGesture)

    }
    
    private func setupHeaderLabels() {
        comicTitle.text = viewModel.setComicTitle()
        comicTitle.font = .monospacedSystemFont(ofSize: 28, weight: .black)
        comicTitle.textColor = .black
        comicNum.text = viewModel.setComicNum()
        comicNum.font = .monospacedDigitSystemFont(ofSize: 18, weight: .bold)
        comicNum.textColor = .black
    }
    
    private func setupShareButton() {
        shareButton.setImage(UIImage(systemName: "square.and.arrow.up.fill"), for: .normal)
        shareButton.tintColor = UIColor(.black)
    }
    
    private func setupFavouriteButton() {
        favouriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        refreshFavouriteButton()
    }
    
    private func refreshFavouriteButton() {
        favouriteButton.tintColor = viewModel.checkIfLiked() ? UIColor.favouriteButtonColor : UIColor(.black)
    }
    
    private func setupNavigationButtons() {
        previousButton.setTitle("previous", for: .normal)
        latestButton.setTitle("latest", for: .normal)
        nextButton.setTitle("next", for: .normal)
        
        refreshButtonState()
    }
    
    private func refreshButtonState() {
        previousButton.isEnabled = viewModel.getPreviousButtonState()
        latestButton.isEnabled = viewModel.getLatestButtonState()
        nextButton.isEnabled = viewModel.getNextButtonState()

        previousButton.tintColor = .black.withAlphaComponent(viewModel.getPreviousButtonState() ? 1.0 : 0.6)
        latestButton.tintColor = .black.withAlphaComponent(viewModel.getLatestButtonState() ? 1.0 : 0.6)
        nextButton.tintColor = .black.withAlphaComponent(viewModel.getNextButtonState() ? 1.0 : 0.6)
    }
    
    private func refreshViews() {
        comicImageView.kf.setImage(with: self.viewModel.comicImageURL())
        setupHeaderLabels()
        refreshFavouriteButton()
        refreshButtonState()
        configureAccessibility()
    }
    
    private func reloadFavourites() {
        comicImageView.image = viewModel.comicImage()
        setupHeaderLabels()
        refreshFavouriteButton()
    }
    
    private func setupAccessibilityIdentifiers() {
        comicNum.accessibilityIdentifier = AccessibilityIdentifier.comicNum.rawValue
        nextButton.accessibilityIdentifier = AccessibilityIdentifier.nextButton.rawValue
        previousButton.accessibilityIdentifier = AccessibilityIdentifier.prevButton.rawValue
        latestButton.accessibilityIdentifier = AccessibilityIdentifier.latestButton.rawValue
        comicImageView.accessibilityIdentifier = "\(comic?.num ?? 0)"
    }
    
    private func configureAccessibility() {
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
