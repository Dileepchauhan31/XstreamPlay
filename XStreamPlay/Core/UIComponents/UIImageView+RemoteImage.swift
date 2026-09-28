//
//  UIImageView+RemoteImage.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 28/09/26.
//

import UIKit
import Kingfisher

/// The only place the app talks to Kingfisher.
///
/// Cells call `setRemoteImage(from:)` instead of `kf.setImage(...)`. If the
/// image library is ever replaced, this is the one file that changes.
extension UIImageView {

    /// Loads `url` into the image view with a short fade.
    ///
    /// - Parameter completion: `true` when an image was shown, `false` on a
    ///   real failure or a `nil` URL. Not called when the load was cancelled or
    ///   replaced by a newer one (cell reuse), since the cell has moved on.
    func setRemoteImage(
        from url: URL?,
        fadeDuration: TimeInterval = 0.25,
        completion: ((Bool) -> Void)? = nil
    ) {
        guard let url else {
            cancelRemoteImageLoad()
            image = nil
            completion?(false)
            return
        }

        kf.setImage(
            with: url,
            placeholder: nil,
            options: [.transition(.fade(fadeDuration))],
            completionHandler: { result in
                switch result {
                case .success:
                    completion?(true)
                case .failure(let error) where error.isTaskCancelled || error.isNotCurrentTask:
                    return
                case .failure:
                    completion?(false)
                }
            }
        )
    }

    /// Call from `prepareForReuse()`. Without this, a slow download for the
    /// previous item can land in a recycled cell and show the wrong poster.
    func cancelRemoteImageLoad() {
        kf.cancelDownloadTask()
    }
}
