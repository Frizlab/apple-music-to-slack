import Foundation

import ArgumentParser
import Logging
import TOMLDecoder
import XDG



@main
struct Main : AsyncParsableCommand {
	
	static let configuration = CommandConfiguration(
		commandName: "apple-music-to-slack"
	)
	
	@Flag(inversion: .prefixedNo)
	var verbose: Bool = false
	
	@Flag(inversion: .prefixedNo, help: "Use a random emoji from a list of pre-defined ones. If set to false, the :notes: emoji will be used.")
	var useRandomEmoji: Bool = false
	
	@Option
	var slackToken: String?
	
	func run() async throws {
		let logger = logger(verbose ? .debug : .notice)
		
		/* Retrieve the Slack token first. */
		let slackToken = try slackToken ?? ProcessInfo.processInfo.environment["AMTS_SLACK_TOKEN"] ?? { () -> String? in
			let directories = try BaseDirectories(prefixAll: "apple-music-to-slack")
			guard let confFile = try directories.findConfigFile("settings.toml"), let confURL = URL(filePath: confFile) else {
				return nil
			}
			let confData = try Data(contentsOf: confURL)
			let conf = try TOMLDecoder().decode(Conf.self, from: confData)
			return conf.slackToken
		}()
		guard let slackToken else {
			throw SimpleError(message: "Cannot find the Slack token. You should either provide it as an argument or set the environment variable AMTS_SLACK_TOKEN, or finally create a settings.toml file in the config directory or the program.")
		}
		
		/* Next, retrieve the current track info. */
		let currentTrackInfo = try CurrentTrackInfo.get(logger: logger)
		logger.debug("Sending music track info.", metadata: ["info": "\(currentTrackInfo)"])
		guard case let .playing(songInfo) = currentTrackInfo else {
			return logger.info("No music playing; skipping Slack profile update.", metadata: ["current-track-info": "\(currentTrackInfo)"])
		}
		
		/* Finally, send the track info to Slack as a profile update. */
		let content = ProfileUpdateContent(
			statusText: "\(songInfo.artist) — \(songInfo.album) — \(songInfo.name)",
			statusEmoji: (useRandomEmoji ? MusicEmoji.allCases.randomElement()! : .notes).rawValue,
			statusExpiration: nil
		)
		var urlRequest = URLRequest(url: URL(string: "https://slack.com/api/users.profile.set")!)
		urlRequest.httpMethod = "POST"
		urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
		urlRequest.addValue("Bearer \(slackToken)", forHTTPHeaderField: "Authorization")
		urlRequest.httpBody = try JSONEncoder().encode(content)
		let (data, urlResponse) = try await URLSession.shared.data(for: urlRequest)
		guard let httpResponse = urlResponse as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
			throw SimpleError(message: "Cannot send the profile update to Slack.")
		}
		let response = try JSONDecoder().decode(ProfileUpdateResponse.self, from: data)
		guard response.ok else {
			throw SimpleError(message: "Error sending profile update to Slack. Error message: \(response.error ?? "<No Error in Response>")")
		}
	}
	
	private struct ProfileUpdateContent : Encodable {
		
		var statusText: String?
		var statusEmoji: String?
		var statusExpiration: Date?
		
		func encode(to encoder: any Encoder) throws {
			var container = encoder.container(keyedBy: RootCodingKey.self)
			var subContainer = container.nestedContainer(keyedBy: StatusCodingKeys.self, forKey: .profile)
			try subContainer.encodeIfPresent(statusText, forKey: .statusText)
			try subContainer.encodeIfPresent(statusEmoji, forKey: .statusEmoji)
			try subContainer.encodeIfPresent(statusExpiration?.timeIntervalSince1970, forKey: .statusExpiration)
		}
		
		enum RootCodingKey : String, CodingKey {
			case profile
		}
		
		enum StatusCodingKeys : String, CodingKey {
			case statusText = "status_text"
			case statusEmoji = "status_emoji"
			case statusExpiration = "status_expiration"
		}
		
	}
	
	private struct ProfileUpdateResponse : Decodable {
		
		var ok: Bool
		var error: String?
		
	}
	
}
