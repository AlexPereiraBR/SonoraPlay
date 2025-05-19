//
//  PlayerViewController.swift
//  SonoraPlay
//
//  Created by Aleksandr Shchukin on 15/05/25.
//

import Foundation
import UIKit
import SnapKit

final class PlayerViewController: UIViewController {
    
    // MARK: - UI Elements
    
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
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureLabels()
        configureButtons()
        configureProgressSlider()
        configureVolumeSlider()
        configurePlaybackModeButton()
        setupLayout()
        presenter?.viewDidLoad()
        startProgressTimer()
    }
    
    // MARK: - UI Configuration
    
    private func configureLabels() {
        titleLabel.font = .boldSystemFont(ofSize: 20)
        titleLabel.textAlignment = .center
        artistLabel.font = .systemFont(ofSize: 16)
        artistLabel.textAlignment = .center
        currentTimeLabel.font = .monospacedDigitSystemFont(ofSize: 20, weight: .regular)
        durationLabel.font = .monospacedDigitSystemFont(ofSize: 20, weight: .regular)
        currentTimeLabel.text = "00:00"
        durationLabel.text = "00:00"
    }
    
    private func configureButtons() {
        playPauseButton.setTitle("Play", for: .normal)
        playPauseButton.addTarget(self, action: #selector(playPauseTapped), for: .touchUpInside)
        nextButton.setTitle("Next", for: .normal)
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        previousButton.setTitle("Prev", for: .normal)
        previousButton.addTarget(self, action: #selector(previousTapped), for: .touchUpInside)
    }
    
    private func configureProgressSlider() {
        progressSlider.minimumTrackTintColor = .label
        progressSlider.maximumTrackTintColor = .systemGray4
        progressSlider.thumbTintColor = .label
        progressSlider.addTarget(self, action: #selector(sliderTouchBegan(_:)), for: .touchDown)
        progressSlider.addTarget(self, action: #selector(sliderTouchEnded(_:)), for: [.touchUpInside, .touchUpOutside])
        progressSlider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
    }
    
    private func configureVolumeSlider() {
        volumeSlider.minimumValue = 0.0
        volumeSlider.maximumValue = 1.0
        volumeSlider.value = 0.5
        volumeSlider.addTarget(self, action: #selector(volumeChanged(_:)), for: .valueChanged)
    }
    
    private func configurePlaybackModeButton() {
        playbackModeButton.titleLabel?.font = UIFont.systemFont(ofSize: 38)
        playbackModeButton.setTitle("🔁", for: .normal)
        playbackModeButton.addTarget(self, action: #selector(didTapPlaybackMode), for: .touchUpInside)
    }
    
    // MARK: - Layout
    
    private func setupLayout() {
        let controlsStack = UIStackView(arrangedSubviews: [previousButton, playPauseButton, nextButton])
        controlsStack.axis = .horizontal
        controlsStack.spacing = 20
        controlsStack.alignment = .center
        controlsStack.distribution = .equalSpacing

        let mainStack = UIStackView(arrangedSubviews: [coverImageView, titleLabel, artistLabel, controlsStack])
        mainStack.axis = .vertical
        mainStack.spacing = 20
        mainStack.alignment = .center

        view.addSubview(mainStack)
        view.addSubview(progressSlider)
        view.addSubview(currentTimeLabel)
        view.addSubview(durationLabel)
        view.addSubview(volumeSlider)
        view.addSubview(playbackModeButton)

        mainStack.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
        coverImageView.snp.makeConstraints { make in
            make.size.equalTo(200)
        }

        progressSlider.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.top.equalTo(mainStack.snp.bottom).offset(32)
        }

        currentTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(progressSlider.snp.bottom).offset(4)
            make.leading.equalTo(progressSlider.snp.leading)
        }

        durationLabel.snp.makeConstraints { make in
            make.top.equalTo(progressSlider.snp.bottom).offset(4)
            make.trailing.equalTo(progressSlider.snp.trailing)
        }

        volumeSlider.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.top.equalTo(durationLabel.snp.bottom).offset(24)
        }

        playbackModeButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(volumeSlider.snp.bottom).offset(24)
            make.size.equalTo(62)
        }
    }
    
    // MARK: - Actions
    
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
    
    // MARK: - Helpers
    
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
    
