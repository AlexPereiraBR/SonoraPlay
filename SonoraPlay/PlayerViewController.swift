//
//  PlayerViewController.swift
//  SonoraPlay
//
//  Created by Aleksandr Shchukin on 15/05/25.
//

import Foundation
import UIKit

final class PlayerViewController: UIViewController {
    var presenter: PlayerViewToPresenterProtocol?
    
    private let titleLabel = UILabel()
    private let artistLabel = UILabel()
    private let coverImageView = UIImageView()
    private let playPauseButton = UIButton(type: .system)
    private let nextButton = UIButton(type: .system)
    private let previousButton = UIButton(type: .system)
    
    private var isPlaying = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter?.viewDidLoad()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        coverImageView.contentMode = .scaleAspectFit
        titleLabel.font = .boldSystemFont(ofSize: 20)
        titleLabel.textAlignment = .center
        artistLabel.font = .systemFont(ofSize: 16)
        artistLabel.textAlignment = .center
        
        playPauseButton.setTitle("Play", for: .normal)
        playPauseButton.addTarget(self, action: #selector(playPauseTapped), for: .touchUpInside)
        
        nextButton.setTitle("Next", for: .normal)
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        
        previousButton.setTitle("Prev", for: .normal)
        previousButton.addTarget(self, action: #selector(previousTapped), for: .touchUpInside)
        
        let stack = UIStackView(arrangedSubviews: [previousButton, playPauseButton, nextButton])
        stack.axis = .horizontal
        stack.spacing = 20
        stack.alignment = .center
        stack.distribution = .equalSpacing
        
        let mainStack = UIStackView(arrangedSubviews: [coverImageView, titleLabel, artistLabel, stack])
        mainStack.axis = .vertical
        mainStack.spacing = 20
        mainStack.alignment = .center
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(mainStack)
        
        NSLayoutConstraint.active([
            mainStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            coverImageView.heightAnchor.constraint(equalToConstant: 200),
            coverImageView.widthAnchor.constraint(equalToConstant: 200)
        ])
        
    }
    
    @objc private func playPauseTapped() {
        isPlaying ? presenter?.didTapPause() : presenter?.didTapPlay()
    }
    
    @objc private func nextTapped() {
        presenter?.didTapNext()
    }
    
    @objc private func previousTapped() {
        presenter?.didTapPrevious()
    }
    
}

// MARK: - Presenter to View

extension PlayerViewController: PlayerPresenterToViewProtocol {
    
    func showTrack(title: String, artist: String, coverImageName: String) {
        titleLabel.text = title
        artistLabel.text = artist
        coverImageView.image = UIImage(named: coverImageName)
    }
    
    func updatePlayButton(isPlaying: Bool) {
        self.isPlaying = isPlaying
        playPauseButton.setTitle(isPlaying ? "Pause" : "Play", for: .normal)
    }
}
