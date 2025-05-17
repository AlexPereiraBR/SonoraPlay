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
    
    private let progressSlider = UISlider()
    private let currentTimeLabel = UILabel()
    private let durationLabel = UILabel()
    private var isSeeking = false
    private var progressTimer: Timer?
    
    private var isPlaying = false
    
    private let volumeSlider = UISlider()
    
    private let playbackModeButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter?.viewDidLoad()
        startProgressTimer()
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
        
        NSLayoutConstraint.activate([
            mainStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            coverImageView.heightAnchor.constraint(equalToConstant: 200),
            coverImageView.widthAnchor.constraint(equalToConstant: 200)
        ])
        
        view.addSubview(progressSlider)
        view.addSubview(currentTimeLabel)
        view.addSubview(durationLabel)
        
        progressSlider.minimumTrackTintColor = .label
        progressSlider.maximumTrackTintColor = .systemGray4
        progressSlider.thumbTintColor = .label
        
        progressSlider.addTarget(self, action: #selector(sliderTouchBegan(_:)), for: .touchDown)
        progressSlider.addTarget(self, action: #selector(sliderTouchEnded(_:)), for: [.touchUpInside, .touchUpOutside])
        progressSlider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        
        currentTimeLabel.font = .monospacedDigitSystemFont(ofSize: 20, weight: .regular)
        durationLabel.font = .monospacedDigitSystemFont(ofSize: 20, weight: .regular)
        
        currentTimeLabel.text = "00:00"
        durationLabel.text = "00:00"
        
        currentTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        progressSlider.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            progressSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            progressSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            progressSlider.topAnchor.constraint(equalTo: mainStack.bottomAnchor, constant: 32),
            
            currentTimeLabel.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 4),
            currentTimeLabel.leadingAnchor.constraint(equalTo: progressSlider.leadingAnchor),
            
            durationLabel.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 4),
            durationLabel.trailingAnchor.constraint(equalTo: progressSlider.trailingAnchor)
        ])
        
        //Volume slider
        volumeSlider.minimumValue = 0.0
        volumeSlider.maximumValue = 1.0
        volumeSlider.value = 0.5 // или player?.volume, если есть
        volumeSlider.addTarget(self, action: #selector(volumeChanged(_:)), for: .valueChanged)
        
        view.addSubview(volumeSlider)
        volumeSlider.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            volumeSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            volumeSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            volumeSlider.topAnchor.constraint(equalTo: durationLabel.bottomAnchor, constant: 24)
            ])
        
        
        playbackModeButton.titleLabel?.font = UIFont.systemFont(ofSize: 38)
        playbackModeButton.setTitle("🔁", for: .normal)
        playbackModeButton.addTarget(self, action: #selector(didTapPlaybackMode), for: .touchUpInside)
        view.addSubview(playbackModeButton)
        
        playbackModeButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            playbackModeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playbackModeButton.topAnchor.constraint(equalTo: volumeSlider.bottomAnchor, constant: 24),
            playbackModeButton.heightAnchor.constraint(equalToConstant: 62),
            playbackModeButton.widthAnchor.constraint(equalToConstant: 62)
        ])
        

        // Установи констрейнты где нужно
    }
    
    @objc private func didTapPlaybackMode() {
        presenter?.didTapCyclePlaybackMode()
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
    
    @objc private func sliderTouchBegan(_ sender: UISlider) {
        isSeeking = true
    }
    
    @objc private func sliderTouchEnded(_ sender: UISlider) {
        isSeeking = false
        var time = TimeInterval(sender.value)
        presenter?.seekTo(position: time)
        updateProgress()
    }
    
    @objc private func sliderValueChanged(_ sender: UISlider) {
        currentTimeLabel.text = formatTime(TimeInterval(sender.value))
    }
    
    @objc private func volumeChanged(_ sender: UISlider) {
        presenter?.setVolume(sender.value)
    }
    
    private func startProgressTimer() {
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.updateProgress()
        }
    }
    
    private func updateProgress() {
        guard !isSeeking, let progress = presenter?.getPlaybackProgress() else { return }
        
        progressSlider.maximumValue = Float(progress.duration)
        progressSlider.value = Float(progress.currentTime)
        currentTimeLabel.text = formatTime(progress.currentTime)
        durationLabel.text = formatTime(progress.duration)
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    
    
    
}

// MARK: - Presenter to View

extension PlayerViewController: PlayerPresenterToViewProtocol {
    
    func updatePlaybackModeIcon(to mode: PlaybackMode) {
        switch mode {
        case .normal:
            playbackModeButton.setTitle("▶︎", for: .normal)
        case .repeatOne:
            playbackModeButton.setTitle("🔂", for: .normal)
        case .repeatAll:
            playbackModeButton.setTitle("🔁", for: .normal)
        case .shuffle:
            playbackModeButton.setTitle("🔀", for: .normal)
        }
    }
        
        
        func showTrack(title: String, artist: String, artwork: UIImage?) {
            titleLabel.text = title
            artistLabel.text = artist
            coverImageView.image = artwork ?? UIImage(named: "defaultCover") // подстраховка
        }
        
        func updatePlayButton(isPlaying: Bool) {
            self.isPlaying = isPlaying
            playPauseButton.setTitle(isPlaying ? "Pause" : "Play", for: .normal)
        }
    }
    

