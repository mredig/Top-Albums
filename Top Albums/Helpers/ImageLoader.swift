//
//  ImageLoader.swift
//  Top Albums
//
//  Created by Michael Redig on 5/7/20.
//  Copyright © 2020 Red_Egg Productions. All rights reserved.
//

import Foundation
import NetworkHandler

protocol ImageLoader {
	func fetchImage(for musicResultVM: MusicResultViewModel, attemptHighRes: Bool, completion: @escaping (Result<Data, NetworkError>) -> Void) -> NetworkLoadingTask?
}
