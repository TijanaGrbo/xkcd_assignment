//
//  BrowseVC.swift
//  xkcd_assignment
//
//  Created by Tijana on 01/03/2023.
//

import UIKit
import Combine

final class ComicViewerVC: UIViewController {
    
    @IBOutlet weak var comicImageView: UIImageView!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var latestButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var comicTitle: UILabel!
    @IBOutlet weak var comicNum: UILabel!
    @IBOutlet weak var noContentLabel: UILabel!
    
    var coordinator: MainCoordinator
    var viewModel: ComicViewModel
    
    private var cancelable: AnyCancellable?
    private var comic: Comic? { didSet {
        refreshViews()
    }}
    private var favouriteComic: FavouriteComic? { didSet {
        reloadFavourites()
    }}
    private var isFavourite: Bool? { didSet {
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
        setupBackground()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if let gradientLayer = view.layer.sublayers?.first(where: { $0 is CAGradientLayer }) as? CAGradientLayer {
            gradientLayer.frame = CGRect(origin: CGPoint.zero, size: size)
        }
    }
    
    @IBAction func previousButtonTapped(_ sender: Any) {
        navigateToPrevious()
    }
    
    @IBAction func latestButtonTapped(_ sender: Any) {
        navigateToLatest()
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        navigateToNext()
    }
    
    @IBAction func favouriteButtonTapped(_ sender: Any) {
        guard let comicImage = comicImageView.image else { return }
        viewModel.favouriteButtonTapped(comicImage: comicImage)
        refreshFavouriteButton()
        configureAccessibility()
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        guard let imageURL = viewModel.getSharableLink() else { return }
        coordinator.shareComic(imageURL)
    }
}

// private action helpers
private extension ComicViewerVC {
    func navigateToPrevious() {
        Task {
            await viewModel.getPreviousComic()
            refreshButtonState()
        }
    }
    
    func navigateToLatest() {
        Task {
            await viewModel.getLatestComic()
            refreshButtonState()
        }
    }
    
    func navigateToNext() {
        Task {
            await viewModel.getNextComic()
            refreshButtonState()
        }
    }
}

// private setup/reload helpers
private extension ComicViewerVC {
    func setupViews() {
        Task {
            await viewModel.getLatestComic()
            setupBackground()
            setupVisibility()
            setupImage()
            setupNoContentLabel()
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
    }
    
    func setupVisibility() {
        let visibility: Float = viewModel.hasComic() ? 1 : 0
        let labelVisibility: Bool = viewModel.hasComic()
        shareButton.layer.opacity = visibility
        favouriteButton.layer.opacity = visibility
        previousButton.layer.opacity = visibility
        latestButton.layer.opacity = visibility
        nextButton.layer.opacity = visibility
        noContentLabel.layer.isHidden = labelVisibility
    }
    
    func setupImage() {
        comicImageView.layer.compositingFilter = "multiplyBlendMode"
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture))
        swipeLeftGesture.direction = .left
        comicImageView.isMultipleTouchEnabled = true
        comicImageView.isUserInteractionEnabled = true
        comicImageView.addGestureRecognizer(tapGesture)
        comicImageView.addGestureRecognizer(swipeRightGesture)
        comicImageView.addGestureRecognizer(swipeLeftGesture)
        comicImageView.addGestureRecognizer(pinchGesture)
    }
    
    func setupHeaderLabels() {
        comicTitle.text = viewModel.getComicTitle()
        comicTitle.font = .monospacedSystemFont(ofSize: 28, weight: .black)
        comicTitle.textColor = .black
        comicNum.text = viewModel.getComicNum()
        comicNum.font = .monospacedDigitSystemFont(ofSize: 18, weight: .bold)
        comicNum.textColor = .black
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
        favouriteButton.tintColor = viewModel.checkIfFavourite() ? UIColor.favouriteButtonColor : UIColor(.black)
        setupVisibility()
    }
    
    func setupNavigationButtons() {
        previousButton.setTitle("previous".localized(), for: .normal)
        latestButton.setTitle("latest".localized(), for: .normal)
        nextButton.setTitle("next".localized(), for: .normal)
        
        refreshButtonState()
    }
    
    func setupNoContentLabel() {
        noContentLabel.text = "You have no favourite comics".localized()
        noContentLabel.font = .monospacedSystemFont(ofSize: 18, weight: .black)
        noContentLabel.textColor = .noContentTextColor
    }
    
    func refreshButtonState() {
        setupVisibility()
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
        favouriteButton.accessibilityLabel = "\(viewModel.checkIfFavourite() ? "Favourite" : "Not favourite"), double tap to \(viewModel.checkIfFavourite() ? "remove from" : "add to") favourites"
    }
    
    @objc func imageTapped() {
        coordinator.showDetail(title: viewModel.getComicTitle(),
                               description: viewModel.getComicDescription(),
                               url: viewModel.getExplanationUrl())
    }
    
    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            navigateToNext()
        } else if gesture.direction == .right {
            navigateToPrevious()
        }
    }
    
    @objc func handlePinchGesture(_ gestureRecognizer: UIPinchGestureRecognizer) {
        guard let view = gestureRecognizer.view else { return }
        
        switch gestureRecognizer.state {
        case .began, .changed:
            view.transform = view.transform.scaledBy(x: gestureRecognizer.scale, y: gestureRecognizer.scale)
            gestureRecognizer.scale = 1
        case .ended:
            animateBackToOriginalScale(view)
        default:
            break
        }
    }
    
    private func animateBackToOriginalScale(_ view: UIView) {
        UIView.animate(withDuration: 0.3) {
            view.transform = .identity
        }
    }

}
