//
//  SearchVC.swift
//  xkcd_assignment
//
//  Created by Tijana on 02/03/2023.
//

import UIKit
import Combine

class SearchVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var sliderView: UISlider!
    @IBOutlet weak var comicNumLabel: UITextField!
    @IBOutlet weak var comicImageView: UIImageView!
    @IBOutlet weak var comicNameLabel: UILabel!
    
    let searchViewModel: SearchViewModel
    
    private var debounceTimer: Timer?
    var cancellable: AnyCancellable?
    var comic: Comic? { didSet {
        refreshViews()
    }}
    
    init(searchViewModel: SearchViewModel) {
        self.searchViewModel = searchViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        comicNumLabel.delegate = self
        setupViews()
        bindViewModel()
    }
    
    func setupViews() {
        Task {
            await searchViewModel.getLatestComic()
            refreshViews()
            configureAccessibility()
            setupComicNumLabel()
            setupBackground()
            setupSlider()
        }
    }
    
    func bindViewModel() {
        cancellable = searchViewModel.$comic
            .receive(on: DispatchQueue.main)
            .assign(to: \.comic, on: self)
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
    
    func setupSlider() {
        sliderView.tintColor = .purple
        sliderView.minimumValue = 1
        sliderView.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        sliderView.maximumValue = Float(searchViewModel.latestComicNum ?? 0)
        sliderView.value = sliderView.maximumValue
        sliderValueChanged(sliderView)
    }
    
    func setupComicNumLabel() {
        comicNumLabel.addTarget(self, action: #selector(comicNumValueChanged), for: .allEditingEvents)
        comicNumLabel.text = String(Int(sliderView.value))
        comicNumLabel.textAlignment = .center
        comicNumLabel.font = .monospacedSystemFont(ofSize: 18, weight: .bold)
        comicNumLabel.backgroundColor = .purple.withAlphaComponent(0.2)
        comicNumLabel.textColor = .black
        comicNumValueChanged(comicNumLabel)
    }
    
    func setupNameLabel() {
        comicNameLabel.text = comic?.title
        comicNameLabel.font = .monospacedSystemFont(ofSize: 28, weight: .black)
        comicNameLabel.textColor = .black
    }
    
    func refreshViews() {
        comicImageView.kf.setImage(with: comic?.imgURL)
        setupNameLabel()
    }
}

extension SearchVC {
    func configureAccessibility() {
        guard let comic = comic else { return }
        comicNameLabel.isAccessibilityElement = true
        comicNameLabel.accessibilityLabel = "Comic title: \(comic.title)"
        
        comicNumLabel.isAccessibilityElement = true
        comicNumLabel.accessibilityLabel = "Comic number"
        
        comicImageView.isAccessibilityElement = true
        comicImageView.accessibilityLabel = comic.alt
    }
}

extension SearchVC {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
    
    @objc func sliderValueChanged(_ sender: UISlider) {
        self.comicNumLabel.text = String(Int(sender.value))
        debounceTimer?.invalidate()
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            Task {
                await self.searchViewModel.getComic(withNum: Int(sender.value))
            }
        }
    }
    
    @objc func comicNumValueChanged(_ sender: UITextField) {
        guard let stringToConvert = sender.text else { return }
        self.sliderView.value = Float(stringToConvert) ?? 0
        debounceTimer?.invalidate()
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            Task {
                await self.searchViewModel.getComic(withNum: Int(stringToConvert) ?? 0)
            }
        }
    }
}
