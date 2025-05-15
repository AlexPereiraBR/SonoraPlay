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
}

// MARK: - Presenter to View

protocol PlayerPresenterToViewProtocol: AnyObject {
    func showTrack(title: String, artist: String, artwork: UIImage?)
    func updatePlayButton(isPlaying: Bool)
}

// MARK: - Presenter to Interactor

protocol PlayerPresenterToInteractorProtocol: AnyObject {
    func loadInitialTrack()
    func play()
    func pause()
    func next()
    func previous()
}

// MARK: - Interactor to Presenter

protocol PlayerInteractorToPresenterProtocol: AnyObject {
    func didLoad(track: LocalTrack)
    func didChangePlaybackState(isPlaying: Bool)
}

// MARK: Presenter to Router

protocol PlayerPresenterToRouterProtocol: AnyObject {
    static func createModule() -> UIViewController
}
