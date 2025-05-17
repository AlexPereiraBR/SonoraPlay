//
//  PlayerProtocols.swift
//  SonoraPlay
//
//  Created by Aleksandr Shchukin on 15/05/25.
//

import Foundation
import UIKit

// MARK: - View to Presenter

protocol PlayerViewToPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didTapPlay()
    func didTapPause()
    func didTapNext()
    func didTapPrevious()
    func seekTo(position: TimeInterval)
    func getPlaybackProgress() -> (currentTime: TimeInterval, duration: TimeInterval)
    func setVolume(_ volume: Float)
    func didTapCyclePlaybackMode()
  
}

// MARK: - Presenter to View

protocol PlayerPresenterToViewProtocol: AnyObject {
    func showTrack(title: String, artist: String, artwork: UIImage?)
    func updatePlayButton(isPlaying: Bool)
    func updatePlaybackModeIcon(to mode: PlaybackMode)
    
}

// MARK: - Presenter to Interactor

protocol PlayerPresenterToInteractorProtocol: AnyObject {
    func loadInitialTrack()
    func play()
    func pause()
    func next()
    func previous()
    func seek(to time: TimeInterval)
    func getCurrentTime() -> TimeInterval
    func getDuration() -> TimeInterval
    func setVolume(_ volume: Float)
    func cyclePlaybackMode()
}

// MARK: - Interactor to Presenter

protocol PlayerInteractorToPresenterProtocol: AnyObject {
    func didLoad(track: LocalTrack)
    func didChangePlaybackState(isPlaying: Bool)
    func didChangePlaybackMode(mode: PlaybackMode)
}

// MARK: - Presenter to Router

protocol PlayerPresenterToRouterProtocol: AnyObject {
    static func createModule() -> UIViewController
}
