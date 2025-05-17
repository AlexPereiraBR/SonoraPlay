//
//  PlayerInteractor.swift
//  SonoraPlay
//
//  Created by Aleksandr Shchukin on 15/05/25.
//

import Foundation
import AVFoundation
import UIKit

final class PlayerInteractor: PlayerPresenterToInteractorProtocol  {
    
    weak var presenter: PlayerInteractorToPresenterProtocol?
    private var player: AVAudioPlayer?
    private var currentTrackIndex = 0
    
    private var tracks: [LocalTrack] = []
    private var isPlayerPrepared = false
    
    func loadInitialTrack() {
        copySampleTracksIfNeeded()
        tracks = loadTracksFromDocuments()
        guard !tracks.isEmpty else {
            print("❌ Нет треков в Documents")
                    return
        }
        
        let track = tracks[currentTrackIndex]
        presenter?.didLoad(track: track)
        preparePlayer(for: track)
    }
    
    func play() {
        if !isPlayerPrepared {
            let track = tracks[currentTrackIndex]
            preparePlayer(for: track)
            isPlayerPrepared = true
        }
        player?.play()
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
        isPlayerPrepared = true
        player?.play()
        presenter?.didChangePlaybackState(isPlaying: true)
    }
    
    private func preparePlayer(for track: LocalTrack) {
        
        player = try? AVAudioPlayer(contentsOf: track.fileURL)
        player?.prepareToPlay()
    }
    
    func loadTracksFromDocuments() -> [LocalTrack] {
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return [] }
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            let mp3Files = fileURLs.filter { $0.pathExtension.lowercased() == "mp3" }
            
            return mp3Files.compactMap { extractTrackMetadata(from: $0) }
        } catch {
            print("Ошибка при чтении Documents: \(error)")
                    return []
        }
    }
    
    private func extractTrackMetadata(from url: URL) -> LocalTrack? {
        let asset = AVURLAsset(url: url)
        let metadata = asset.metadata

        let title = AVMetadataItem.metadataItems(
            from: metadata,
            withKey: AVMetadataKey.commonKeyTitle,
            keySpace: AVMetadataKeySpace.common
        ).first?.value as? String ?? url.deletingPathExtension().lastPathComponent

        let artist = AVMetadataItem.metadataItems(
            from: metadata,
            withKey: AVMetadataKey.commonKeyArtist,
            keySpace: AVMetadataKeySpace.common
        ).first?.value as? String ?? "Unknown Artist"

        var artwork: UIImage? = nil
        if let artworkData = AVMetadataItem.metadataItems(
            from: metadata,
            withKey: AVMetadataKey.commonKeyArtwork,
            keySpace: AVMetadataKeySpace.common
        ).first?.dataValue {
            artwork = UIImage(data: artworkData)
        }

        return LocalTrack(title: title, artist: artist, fileURL: url, artwork: artwork)
    }
    
    private func copySampleTracksIfNeeded() {
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        let sampleTracks = [
            "rammstein - ich will",
            "rammstein - links234",
            "rammstein - mutter",
            "rammstein - sonne"
        ]
        
        for trackName in sampleTracks {
            guard let bundleURL = Bundle.main.url(forResource: trackName, withExtension: "mp3") else { continue }
            
            let destinationURL = documentsURL.appendingPathComponent("\(trackName).mp3")
            
            if !fileManager.fileExists(atPath: destinationURL.path) {
                do {
                    try fileManager.copyItem(at: bundleURL, to: destinationURL)
                    print("✅ Скопирован: \(trackName).mp3")
                } catch {
                    print("Ошибка при копировании \(trackName): \(error)")
                }
            }
            
        }
        
    }
    
    // MARK: - PlayerPresenterToInteractorProtocol methods for seeking and time retrieval
    func seek(to time: TimeInterval) {
        player?.currentTime = time
    }

    func getCurrentTime() -> TimeInterval {
        return player?.currentTime ?? 0
    }

    func getDuration() -> TimeInterval {
        return player?.duration ?? 1 // Avoid division by zero
    }
}
