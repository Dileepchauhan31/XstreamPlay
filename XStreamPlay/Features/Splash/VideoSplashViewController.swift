//
//  VideoSplashViewController.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 20/01/26.
//

import UIKit

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
            goToMainScreen()
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
        goToMainScreen()
    }

    private func goToMainScreen() {
        let homeVC: HomeViewController = Storyboard.main.instance.instantiate()

        let navController = UINavigationController(rootViewController: homeVC)
        navController.modalTransitionStyle = .crossDissolve
        navController.modalPresentationStyle = .fullScreen
        UIApplication.shared.windows.first?.rootViewController = navController
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}
