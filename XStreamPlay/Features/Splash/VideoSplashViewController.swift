//
//  VideoSplashViewController.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 20/01/26.
//

import UIKit

import AVFoundation

/// Plays the intro video once, then calls `onFinish`.
///
/// It doesn't know what comes next: `AppCoordinator` decides that. If the
/// video file is missing, it finishes straight away.
final class VideoSplashViewController: UIViewController, StoryboardIdentifiable {

    // MARK: - Dependencies

    private let videoURL: URL?
    private let onFinish: () -> Void

    // MARK: - State

    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var playbackObservers: [NSObjectProtocol] = []
    private var hasFinished = false

    /// Never keep the user on the splash longer than this, even if the video stalls.
    private let maximumDuration: TimeInterval = 8

    // MARK: - Init

    init?(coder: NSCoder, videoURL: URL?, onFinish: @escaping () -> Void) {
        self.videoURL = videoURL
        self.onFinish = onFinish
        super.init(coder: coder)
    }

    @available(*, unavailable, message: "Use AppDIContainer.makeSplashViewController(onFinish:)")
    required init?(coder: NSCoder) {
        fatalError("VideoSplashViewController needs its dependencies. Use AppDIContainer.makeSplashViewController(onFinish:).")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayer()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = view.bounds
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Finishing here, not in viewDidLoad, because the coordinator swaps
        // the window's root; doing that before this screen is on screen is unsafe.
        guard let player else {
            finish()
            return
        }
        player.play()

        let timeout = UInt64(maximumDuration * 1_000_000_000)
        Task { [weak self] in
            try? await Task.sleep(nanoseconds: timeout)
            self?.finish()
        }
    }

    // MARK: - Setup

    private func setupPlayer() {
        guard let videoURL else {
            Log.ui.error("Splash video not found in the app bundle.")
            return
        }

        let player = AVPlayer(url: videoURL)
        player.isMuted = true

        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = view.bounds
        playerLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(playerLayer)

        // Finish when the video ends OR fails, so a broken file can't trap the
        // user here. Delivered on the main queue because `onFinish` changes the window.
        let endNotifications: [Notification.Name] = [
            .AVPlayerItemDidPlayToEndTime,
            .AVPlayerItemFailedToPlayToEndTime
        ]
        playbackObservers = endNotifications.map { name in
            NotificationCenter.default.addObserver(forName: name, object: player.currentItem, queue: .main) { [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.finish()
                }
            }
        }

        self.player = player
        self.playerLayer = playerLayer
    }

    // MARK: - Private

    /// Calls `onFinish` once, even if the video ends and something else also
    /// calls this.
    private func finish() {
        guard !hasFinished else { return }
        hasFinished = true
        playbackObservers.forEach { NotificationCenter.default.removeObserver($0) }
        playbackObservers = []
        player?.pause()
        onFinish()
    }
}
