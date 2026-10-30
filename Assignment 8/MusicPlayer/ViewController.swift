//
//  ViewController.swift
//  MusicPlayer
//
//  Created by Akerke Zhanykul on 29.10.2026.
//

import UIKit
import AVFoundation

final class ViewController: UIViewController, AVAudioPlayerDelegate {

    //Outlets
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var shuffleButton: UIButton!

    //State
    private let tracks = TrackLibrary.tracks
    private var currentIndex = 0
    private var isPlaying = false
    private var player: AVAudioPlayer?

    private var isShuffleOn = false
    private var history: [Int] = []
    private var progressTimer: Timer?

    //Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        DispatchQueue.global(qos: .userInitiated).async {
            try? AVAudioSession.sharedInstance().setActive(true)
        }
        loadTrack(at: 0)
        refreshUI()
        startProgressTimer()
    }

    deinit {
        progressTimer?.invalidate()
    }
    @IBAction func sliderChanged(_ sender: UISlider) {
        player?.currentTime = TimeInterval(sender.value)
    }

    @IBAction func shuffleTapped(_ sender: UIButton) {
        isShuffleOn.toggle()
        history.removeAll()
        refreshUI()
    }

    //Actions
    @IBAction func playPauseTapped(_ sender: UIButton) {
        guard let player = player else {
            print("Player is not created: file is not loaded")
            return
        }
        if isPlaying {
            player.pause()
            isPlaying = false
        } else {
            isPlaying = player.play()
        }
        refreshUI()
    }

    @IBAction func nextTapped(_ sender: UIButton) {
        goToNext()
    }

    @IBAction func previousTapped(_ sender: UIButton) {
        if isShuffleOn, let last = history.popLast() {
            switchTrack(to: last)
        } else {
            switchTrack(to: (currentIndex - 1 + tracks.count) % tracks.count)
        }
    }

    //Track order
    private func nextIndex() -> Int {
        if isShuffleOn && tracks.count > 1 {
            var index = currentIndex
            while index == currentIndex {
                index = Int.random(in: 0..<tracks.count)
            }
            return index
        }
        return (currentIndex + 1) % tracks.count
    }

    private func goToNext() {
        history.append(currentIndex)
        if history.count > 50 { history.removeFirst() }
        switchTrack(to: nextIndex())
    }

    //Playback
    private func loadTrack(at index: Int) {
        currentIndex = index
        player?.stop()
        player = nil
        let track = tracks[index]
        let name = (track.fileName as NSString).deletingPathExtension
        let ext = (track.fileName as NSString).pathExtension

        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            print("File is not found in bundle: \(track.fileName)")
            configureProgress(for: nil)
            return
        }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.prepareToPlay()
        } catch {
            print("Can't open \(track.fileName): \(error)")
        }
        configureProgress(for: player)         }

    private func switchTrack(to index: Int) {
        let wasPlaying = isPlaying
        loadTrack(at: index)
        if wasPlaying, let player = player {
            isPlaying = player.play()
        } else {
            isPlaying = false
        }
        refreshUI()
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = true
        goToNext()
    }

    //Progress
    private func configureProgress(for player: AVAudioPlayer?) {
        progressSlider.minimumValue = 0
        progressSlider.maximumValue = Float(player?.duration ?? 0)
        progressSlider.value = 0
    }

    private func startProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
            self?.updateProgress()
        }
    }

    private func updateProgress() {
        guard let player = player, !progressSlider.isTracking else { return }
        progressSlider.value = Float(player.currentTime)
    }

    //UI
    private func refreshUI() {
        let track = tracks[currentIndex]
        coverImageView.image = UIImage(named: track.coverImageName)
        titleLabel.text = track.title
        artistLabel.text = track.artist

        let config = UIImage.SymbolConfiguration(pointSize: 32)
        let symbol = isPlaying ? "pause.fill" : "play.fill"
        playPauseButton.setImage(UIImage(systemName: symbol, withConfiguration: config), for: .normal)

        shuffleButton.tintColor = isShuffleOn ? .systemBlue : .systemGray
    }
}
