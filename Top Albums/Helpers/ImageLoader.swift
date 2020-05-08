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
	func fetchImage(for musicResult: MusicResult, attemptHighRes: Bool, completion: @escaping (Result<Data, NetworkError>) -> Void) -> ImageLoadOperation?
}

protocol ImageLoadOperation {
	func cancel()
}

extension URLSessionDataTask: ImageLoadOperation {}
