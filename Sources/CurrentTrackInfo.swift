import Foundation
import ScriptingBridge

import Logging



enum CurrentTrackInfo : Sendable {
	
	struct TrackInfo : Sendable {
		
		var name: String
		var artist: String
		var album: String
		
		static func get(from app: MusicApplication, logger: Logger? = nil) throws -> TrackInfo {
			guard let track = app.currentTrack else {
				throw SimpleError(message: "Cannot get Music’s current track.")
			}
			return .init(
				name: track.name ?? "<Unknown Name>",
				artist: track.artist ?? "<Unknown Artist>",
				album: track.album ?? "<Unknown Album>"
			)
		}
		
	}
	
	case playing(TrackInfo)
	case paused(TrackInfo)
	case stopped(appRunning: Bool)
	
	static func get(logger: Logger? = nil) throws -> CurrentTrackInfo {
		guard let musicApp = SBApplication(bundleIdentifier: "com.apple.Music") as MusicApplication? else {
			throw SimpleError(message: "Cannot communicate with the Music app.")
		}
		guard musicApp.isRunning else {
			return .stopped(appRunning: false)
		}
		guard let playerState = musicApp.playerState else {
			throw SimpleError(message: "Cannot get Music’s player state.")
		}
		
		switch playerState {
			case .stopped:
				return .stopped(appRunning: true)
				
			case .playing, .fastForwarding, .rewinding:
				return try .playing(.get(from: musicApp, logger: logger))
				
			case .paused:
				return try .paused(.get(from: musicApp, logger: logger))
		}
	}
	
}
