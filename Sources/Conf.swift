import Foundation



struct Conf : Decodable {
	
	var slackToken: String?
	
	enum CodingKeys : String, CodingKey {
		case slackToken = "slack_token"
	}
	
}
