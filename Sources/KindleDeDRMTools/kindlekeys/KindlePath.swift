//
//  KindlePath.swift
//  KindleDeDRMTools
//
//  Created by Paul Tavitian on 7/10/2024.
//

#if os(macOS) || os(Windows)
import Foundation
import OrderedCollections

struct KindlePath: Hashable {
	let type: KindleDatabaseType
	let path: String
	
	private init(type: KindleDatabaseType, path: String) {
		self.type = type
		self.path = path
	}
	
	static func getKindlePaths(homeDir: String) -> OrderedSet<KindlePath> {
#if os(macOS)
		return [
			// .kinf2018 file in new location (App Store Kindle for Mac)
			.init(.K4MACKINF2018, homeDir + "/Library/Containers/com.amazon.Kindle/Data/Library/Application Support/Kindle/storage/.kinf2018"),
			// .kinf2018 files
			.init(.K4MACKINF2018, homeDir + "/Library/Application Support/Kindle/storage/.kinf2018"),
			// .kinf2011 file in new location (App Store Kindle for Mac)
			.init(.K4MACKINF2011, homeDir + "/Library/Containers/com.amazon.Kindle/Data/Library/Application Support/Kindle/storage/.kinf2011"),
			// .kinf2011 files from 1.10
			.init(.K4MACKINF2011, homeDir + "/Library/Application Support/Kindle/storage/.kinf2011"),
			// .rainier-2.1.1-kinf files from 1.6
			.init(.K4MACRAINIER, homeDir + "/Library/Application Support/Kindle/storage/.rainier-2.1.1-kinf"),
			// .kindle-info files from 1.4
			.init(.K4MACKINDLEINFO, homeDir + "/Library/Application Support/Kindle/storage/.kindle-info"),
			// .kindle-info file from 1.2.2
			.init(.K4MACKINDLEINFO, homeDir + "/Library/Application Support/Amazon/Kindle/storage/.kindle-info"),
			// .kindle-info file from 1.0 beta 1 (27214)
			.init(.K4MACKINDLEINFO, homeDir + "/Library/Application Support/Amazon/Kindle for Mac/storage/.kindle-info"),
		]
#elseif os(Windows)
		return [
			// (K4PC 1.25.1 and later) .kinf2018 file
			.init(.K4PC125KINF2018, homeDir + "\\Amazon\\Kindle\\storage\\.kinf2018"),
			// (K4PC 1.9.0 and later) .kinf2011 file
			.init(.K4PC19KINF2011, homeDir + "\\Amazon\\Kindle\\storage\\.kinf2011"),
			// (K4PC 1.6.0 and later) rainier.2.1.1.kinf file
			.init(.K4PC1618KINF, homeDir + "\\Amazon\\Kindle\\storage\\rainier.2.1.1.kinf"),
			// (K4PC 1.5.0 and later) rainier.2.1.1.kinf file
			.init(.K4PC15KINF, homeDir + "\\Amazon\\Kindle For PC\\storage\\rainier.2.1.1.kinf"),
			// original (earlier than K4PC 1.5.0) kindle-info files
			.init(.K4PCKINDLEINFO, homeDir + "\\Amazon\\Kindle For PC\\{AMAwzsaPaaZAzmZzZQzgZCAkZ3AjA_AY}\\kindle.info")
		]
#endif
	}
}

// MARK: - CustomStringConvertible
extension KindlePath: CustomStringConvertible {
	var description: String {
		return "\(type.description) file: \(path)"
	}
}

// MARK: - Convenience Initialisers
extension KindlePath {
	private init(_ type: KindleDatabaseType, _ path: String) {
		self.init(type: type, path: path)
	}
}
#endif
