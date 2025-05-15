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
}

// MARK: - Interactor Output

extension PlayerPresenter: PlayerInteractorToPresenterProtocol {
    
    func didLoad(track: LocalTrack) {
        view?.showTrack(title: track.title, artist: track.artist, artwork: track.artwork)
    }
    
    func didChangePlaybackState(isPlaying: Bool) {
        view?.updatePlayButton(isPlaying: isPlaying)
    }
}
