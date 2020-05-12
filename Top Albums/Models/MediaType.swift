//
//  MediaType.swift
//  Top Albums
//
//  Created by Michael Redig on 5/8/20.
//  Copyright © 2020 Red_Egg Productions. All rights reserved.
//

import Foundation

enum MediaType: Equatable {

	case appleMusic(type: AppleMusicType)
	case iTunesMusic(type: iTunesMusicFeedType)

	enum AppleMusicType: String, CaseIterable {
		case comingSoon = "coming-soon"
		case hotTracks = "hot-tracks"
		case newReleases = "new-releases"
		case topAlbums = "top-albums"
		case topSongs = "top-songs"
		case topSongsss = "top-songsss"
	}

	enum iTunesMusicFeedType: String, CaseIterable {
		case hotTracks = "hot-tracks"
		case newMusic = "new-music"
		case recentReleases = "recent-releases"
		case topAlbums = "top-albums"
		case topSongs = "top-songs"
	}
}

// reference to feeds available for potential future expansion
//https://rss.itunes.apple.com/api/v1/us/apple-music	/hot-tracks/all/100/explicit.json
//https://rss.itunes.apple.com/api/v1/us/itunes-music	/hot-tracks/all/100/explicit.json
//https://rss.itunes.apple.com/api/v1/us/ios-apps		/new-apps-we-love/all/100/explicit.json
//https://rss.itunes.apple.com/api/v1/us/audiobooks		/top-audiobooks/all/100/explicit.json
//https://rss.itunes.apple.com/api/v1/us/books			/top-free/all/100/explicit.json
//https://rss.itunes.apple.com/api/v1/us/tv-shows		/top-tv-episodes/all/100/explicit.json
//https://rss.itunes.apple.com/api/v1/us/movies			/top-movies/all/100/explicit.json
