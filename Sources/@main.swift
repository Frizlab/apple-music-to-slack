import Foundation

import ArgumentParser
import Logging



@main
struct Main : AsyncParsableCommand {
	
	static let configuration = CommandConfiguration(
		commandName: "apple-music-to-slack"
	)
	
	@Flag(inversion: .prefixedNo)
	var verbose: Bool = false
	
	func run() async throws {
		let logger = logger(verbose ? .debug : .notice)
		let currentTrackInfo = try CurrentTrackInfo.get(logger: logger)
		logger.debug("Music track info.", metadata: ["info": "\(currentTrackInfo)"])
	}
	
}
