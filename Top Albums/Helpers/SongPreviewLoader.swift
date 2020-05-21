//
//  SongPreviewLoader.swift
//  Top Albums
//
//  Created by Michael Redig on 5/11/20.
//  Copyright © 2020 Red_Egg Productions. All rights reserved.
//

import Foundation
import NetworkHandler

protocol SongPreviewLoader {

	func fetchPreviewList(for album: MusicResultViewModel, completion: @escaping (Result<[SongResult], NetworkError>) -> Void)
	@discardableResult func fetchPreview(for song: SongResultViewModel, completion: @escaping (Result<Data, NetworkError>) -> Void) -> NetworkLoadingTask

}
