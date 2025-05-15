//
//  PlayerInteractor.swift
//  SonoraPlay
//
//  Created by Aleksandr Shchukin on 15/05/25.
//

import Foundation
import AVFoundation

final class PlayerInteractor: PlayerPresenterToInteractorProtocol  {
    
    weak var presenter: PlayerInteractorToPresenterProtocol?
    private var player: AVAudioPlayer?
    private var currentTrackIndex = 0
    
    private let tracks: [Track] = [
        Track(title: "First Song", artist: "Artist A", coverImageName: "cover1", fileName: "track1"),
        Track(title: "Second Song", artist: "Artist B", coverImageName: "cover 2", fileName: "track2")
    ]
    
    func loadInitialTrack() {
        let track = tracks[currentTrackIndex]
        presenter?.didLoad(track: track)
        preparePlayer(for: track)
    }
    
    func play() {
        player?.pause()
        presenter?.didChangePlaybackState(isPlaying: true)
    }
    
    func pause() {
        player?.pause()
        presenter?.didChangePlaybackState(isPlaying: false)
    }
    
    func next() {
        currentTrackIndex = (currentTrackIndex + 1) % tracks.count
        let track = tracks[currentTrackIndex]
        presenter?.didLoad(track: track)
        preparePlayer(for: track)
        player?.play()
        presenter?.didChangePlaybackState(isPlaying: true)
    }
    
    func previous() {
        currentTrackIndex = (currentTrackIndex - 1 + tracks.count) % tracks.count
        let track = tracks[currentTrackIndex]
        presenter?.didLoad(track: track)
        preparePlayer(for: track)
        player?.play()
        presenter?.didChangePlaybackState(isPlaying: true)
    }
    
    private func preparePlayer(for track: Track) {
        guard let url = Bundle.main.url(forResource: track.fileName, withExtension: "mp3") else { return }
        player = try? AVAudioPlayer(contentsOf: url)
        player?.prepareToPlay()
    }
    
}
