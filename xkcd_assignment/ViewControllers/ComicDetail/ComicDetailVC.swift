//
//  ComicDetailVC.swift
//  xkcd_assignment
//
//  Created by Tijana on 04/03/2023.
//

import UIKit

class ComicDetailVC: UIViewController {
    
    @IBOutlet weak var comicDescriptionTitleLabel: UILabel!
    @IBOutlet weak var comicDetailLabel: UILabel!
    @IBOutlet weak var explanationButton: UIButton!
    
    let comicTitle: String
    let detailLabelString: String
    let url: URL?
    
    init(title: String, description: String, url: URL?) {
        self.comicTitle = title
        self.detailLabelString = description
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLabels()
        setupBackground()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if let gradientLayer = view.layer.sublayers?.first(where: { $0 is CAGradientLayer }) as? CAGradientLayer {
            gradientLayer.frame = CGRect(origin: CGPoint.zero, size: size)
        }
    }
    
    func setupLabels() {
        comicDescriptionTitleLabel.text = comicTitle
        comicDetailLabel.text = detailLabelString
        comicDetailLabel.numberOfLines = 0
        comicDetailLabel.textColor = .black
        comicDescriptionTitleLabel.textColor = .black
        
        explanationButton.setTitle("explanation".localized(), for: .normal)
        explanationButton.tintColor = .black
        
        comicDescriptionTitleLabel.font = .monospacedSystemFont(ofSize: 28, weight: .black)
        comicDetailLabel.font = .monospacedDigitSystemFont(ofSize: 16, weight: .semibold)
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
    
    @IBAction func explanationButtonTapped(_ sender: Any) {
        guard let url = url else { return }
        UIApplication.shared.open(url)
    }
    
}
