//
//  LoadingIndicator.swift
//  Top Albums
//
//  Created by Michael Redig on 5/8/20.
//  Copyright © 2020 Red_Egg Productions. All rights reserved.
//

import UIKit

protocol LoadingIndicatorDisplaying: UIViewController {
	var loadingIndicatorContainerView: UIView? { get set }

	func showLoadingIndicator()
	func dismissLoadingIndicator()
}

extension LoadingIndicatorDisplaying {

	func showLoadingIndicator() {
		guard loadingIndicatorContainerView == nil else { return }
		let containerView = UIView(frame: view.bounds)
		view.addSubview(containerView)
		loadingIndicatorContainerView = containerView
		containerView.backgroundColor = UIColor.label.withAlphaComponent(0.2)
		containerView.alpha = 0

		UIView.animate(withDuration: 0.125) {
			containerView.alpha = 1
		}

		let activityIndicator = UIActivityIndicatorView(style: .large)
		activityIndicator.translatesAutoresizingMaskIntoConstraints = false
		containerView.addSubview(activityIndicator)

		NSLayoutConstraint.activate([
			activityIndicator.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
			activityIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
		])
		activityIndicator.startAnimating()
	}

	func dismissLoadingIndicator() {
		DispatchQueue.main.async {
			self.loadingIndicatorContainerView?.removeFromSuperview()
			self.loadingIndicatorContainerView = nil
		}
	}
}
