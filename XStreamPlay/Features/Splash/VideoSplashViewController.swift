//
//  VideoSplashViewController.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 20/01/26.
//

import UIKit
import AVFoundation

class VideoSplashViewController: UIViewController {

    private var player: AVPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        playVideo()
    }

    private func playVideo() {
        guard let path = Bundle.main.path(forResource: "splashVideo", ofType: "mp4") else {
            // Defer so the window is attached before the root is swapped.
            DispatchQueue.main.async { [weak self] in self?.goToMainScreen() }
            return
        }

        let url = URL(fileURLWithPath: path)
        player = AVPlayer(url: url)

        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = view.bounds
        playerLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(playerLayer)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(videoDidFinish),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem
        )
        player?.isMuted = true
//        player?.playImmediately(atRate: 1.5)
        player?.play()
    }

    @objc private func videoDidFinish() {
        // AVFoundation may post this notification off the main thread.
        DispatchQueue.main.async { [weak self] in self?.goToMainScreen() }
    }

    private func goToMainScreen() {
        let homeVC: HomeViewController = Storyboard.main.instance.instantiate()

        let navController = UINavigationController(rootViewController: homeVC)
        navController.modalTransitionStyle = .crossDissolve
        navController.modalPresentationStyle = .fullScreen

        // `UIApplication.shared.windows` is deprecated from iOS 15 and returns
        // the wrong window once more than one scene exists. Resolve the window
        // that actually hosts this screen instead.
        guard let window = view.window ?? Self.activeKeyWindow else { return }
        window.rootViewController = navController
        window.makeKeyAndVisible()
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
    }

    /// Scene-aware lookup of the key window (iOS 13+, no deprecated APIs).
    private static var activeKeyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)
        ?? UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}
