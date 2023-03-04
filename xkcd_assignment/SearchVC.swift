//
//  SearchVC.swift
//  xkcd_assignment
//
//  Created by Tijana on 02/03/2023.
//

import UIKit
import Combine

class SearchVC: UIViewController {
    
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
        setupViews()
        bindViewModel()
    }
    
    func setupViews() {
        Task {
            await searchViewModel.getLatestComic()
            refreshViews()
            setupSlider()
            setupTitle()
        }
    }
    
    func bindViewModel() {
        cancellable = searchViewModel.$comic
            .receive(on: DispatchQueue.main)
            .assign(to: \.comic, on: self)
    }
    
    func setupSlider() {
        sliderView.minimumValue = 0
        sliderView.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        sliderView.maximumValue = Float(searchViewModel.latestComicNum ?? 0)
        sliderView.value = sliderView.maximumValue
        sliderValueChanged(sliderView)
    }
    
    func setupTitle() {
        comicNameLabel.text = comic?.title
    }
    
    func refreshViews() {
        comicImageView.kf.setImage(with: comic?.imgURL)
        setupTitle()
    }
    
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
}
