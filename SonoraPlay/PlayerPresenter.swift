//
//  PlayerPresenter.swift
//  SonoraPlay
//
//  Created by Aleksandr Shchukin on 15/05/25.
//

import Foundation

final class PlayerPresenter: PlayerViewToPresenterProtocol {
    
    weak var view: PlayerPresenterToViewProtocol?
    var interactor: PlayerPresenterToInteractorProtocol?
    var router: PlayerPresenterToRouterProtocol?
    
    func viewDidLoad() {
        interactor?.loadInitialTrack()
    }
    
    func didTapPlay() {
        interactor?.play()
    }
    
    func didTapPause() {
        interactor?.pause()
    }
    
    func didTapNext() {
        interactor?.next()
    }
    
    func didTapPrevious() {
        interactor?.previous()
    }
    
    func didTapCyclePlaybackMode() {
        interactor?.cyclePlaybackMode()
    }
    
    func seekTo(position: TimeInterval) {
        interactor?.seek(to: position)
    }
    
    func setVolume(_ value: Float) {
        interactor?.setVolume(value)
    }
    
    func getPlaybackProgress() -> (currentTime: TimeInterval, duration: TimeInterval) {
        let current = interactor?.getCurrentTime() ?? 0
        let duration = interactor?.getDuration() ?? 1
        return (current, duration)
    }
}

// MARK: - Interactor Output

extension PlayerPresenter: PlayerInteractorToPresenterProtocol {
    
    func didLoad(track: LocalTrack) {
        view?.showTrack(title: track.title, artist: track.artist, artwork: track.artwork)
    }
    
    func didChangePlaybackState(isPlaying: Bool) {
        view?.updatePlayButton(isPlaying: isPlaying)
    }
    
    func didChangePlaybackMode(mode: PlaybackMode) {
        view?.updatePlaybackModeIcon(to: mode)
    }
}
