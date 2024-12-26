// swift-tools-version:6.0
import PackageDescription



let package = Package(
	name: "apple-music-to-slack",
	platforms: [.macOS(.v13)],
	products: [
		.executable(name: "apple-music-to-slack", targets: ["AppleMusicToSlack"]),
	],
	dependencies: [
		.package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.5.0"),
		.package(url: "https://github.com/dduan/TOMLDecoder.git",           from: "0.2.2"),
		.package(url: "https://github.com/Frizlab/swift-xdg.git",           from: "1.0.0"),
		.package(url: "https://github.com/xcode-actions/clt-logger.git",    from: "1.0.0-beta.4"),
	],
	targets: [
		.executableTarget(name: "AppleMusicToSlack", dependencies: [
			.product(name: "ArgumentParser", package: "swift-argument-parser"),
			.product(name: "CLTLogger",      package: "clt-logger"),
			.product(name: "TOMLDecoder",    package: "TOMLDecoder"),
			.product(name: "XDG",            package: "swift-xdg"),
		], path: "Sources", exclude: ["ScriptingBridge/ Readme.md"]),
	]
)
