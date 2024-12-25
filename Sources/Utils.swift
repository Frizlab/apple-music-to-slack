import Foundation

import CLTLogger
import Logging


private let logger = {
	LoggingSystem.bootstrap{ _ in CLTLogger() }
	return Logger(label: "apple-music-to-slack")
}()

internal func logger(_ logLevel: Logger.Level = .notice) -> Logger {
	var ret = logger
	ret.logLevel = logLevel
	return ret
}
