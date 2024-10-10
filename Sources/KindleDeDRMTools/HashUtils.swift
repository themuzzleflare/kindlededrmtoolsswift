//
//  HashUtils.swift
//
//
//  Created by Paul Tavitian on 7/9/2024.
//

import Foundation
import CommonCrypto
import CryptoKit
import CryptoSwift

final class HashUtils {
	private init() {}
	
	/**
	 * Computes the SHA-256 hash of the given data.
	 * - Parameter data: The data to hash.
	 * - Returns: The SHA-256 hash of the data.
	 */
	static func sha256(data: [Data?]) -> Data {
		if !preferCryptoSwift, usePlatformChecks, #available(macOS 10.15, iOS 13.0, *) {
			return cryptokitSha256(data: data)
		} else {
			return cryptoswiftSha256(data: data)
		}
	}
	
	private static func commoncryptoSha256(data: Data) -> Data {
		var digest = Data(count: Int(CC_SHA256_DIGEST_LENGTH))
		_ = digest.withUnsafeMutableBytes { digestBytes in
			data.withUnsafeBytes { dataBytes in
				CC_SHA256(dataBytes.baseAddress, CC_LONG(data.count), digestBytes.bindMemory(to: UInt8.self).baseAddress)
			}
		}
		return digest
	}
	
	@available(macOS 10.15, iOS 13.0, *)
	private static func cryptokitSha256(data: [Data?]) -> Data {
		var hasher: SHA256 = .init()
		
		for bytes in data {
			guard let bytes else {
				continue
			}
			
			hasher.update(data: bytes)
		}
		
		return .init(hasher.finalize())
	}
	
	private static func cryptoswiftSha256(data: [Data?]) -> Data {
		let bytes: [UInt8] = data.compactMap(\.?.bytes).flatMap(\.self)
		return .init(bytes.sha2(.sha256))
	}
	
	static func sha256(data: Data?...) -> Data {
		return sha256(data: data)
	}
	
	/**
	 * Computes the MD5 hash of the given data.
	 * - Parameter data: The data to hash.
	 * - Returns: The MD5 hash of the data.
	 */
	static func md5(data: [Data?]) -> Data {
		if !preferCryptoSwift, usePlatformChecks, #available(macOS 10.15, iOS 13.0, *) {
			return cryptokitMd5(data: data)
		} else {
			return cryptoswiftMd5(data: data)
		}
	}
	
	private static func commoncryptoMd5(data: Data) -> Data {
		var digest = Data(count: Int(CC_MD5_DIGEST_LENGTH))
		_ = digest.withUnsafeMutableBytes { digestBytes in
			data.withUnsafeBytes { dataBytes in
				CC_MD5(dataBytes.baseAddress, CC_LONG(data.count), digestBytes.bindMemory(to: UInt8.self).baseAddress)
			}
		}
		return digest
	}
	
	@available(macOS 10.15, iOS 13.0, *)
	private static func cryptokitMd5(data: [Data?]) -> Data {
		var hasher: Insecure.MD5 = .init()
		
		for bytes in data {
			guard let bytes else {
				continue
			}
			
			hasher.update(data: bytes)
		}
		
		return .init(hasher.finalize())
	}
	
	private static func cryptoswiftMd5(data: [Data?]) -> Data {
		let bytes: [UInt8] = data.compactMap(\.?.bytes).flatMap(\.self)
		return .init(bytes.md5())
	}
	
	static func md5(data: Data?...) -> Data {
		return md5(data: data)
	}
	
	/**
	 * Computes the SHA-1 hash of the given data.
	 * - Parameter data: The data to hash.
	 * - Returns: The SHA-1 hash of the data.
	 */
	static func sha1(data: [Data?]) -> Data {
		if !preferCryptoSwift, usePlatformChecks, #available(macOS 10.15, iOS 13.0, *) {
			return cryptokitSha1(data: data)
		} else {
			return cryptoswiftSha1(data: data)
		}
	}
	
	private static func commoncryptoSha1(data: Data) -> Data {
		var digest = Data(count: Int(CC_SHA1_DIGEST_LENGTH))
		_ = digest.withUnsafeMutableBytes { digestBytes in
			data.withUnsafeBytes { dataBytes in
				CC_SHA1(dataBytes.baseAddress, CC_LONG(data.count), digestBytes.bindMemory(to: UInt8.self).baseAddress)
			}
		}
		return digest
	}
	
	@available(macOS 10.15, iOS 13.0, *)
	private static func cryptokitSha1(data: [Data?]) -> Data {
		var hasher: Insecure.SHA1 = .init()
		
		for bytes in data {
			guard let bytes else {
				continue
			}
			
			hasher.update(data: bytes)
		}
		
		return .init(hasher.finalize())
	}
	
	private static func cryptoswiftSha1(data: [Data?]) -> Data {
		let bytes: [UInt8] = data.compactMap(\.?.bytes).flatMap(\.self)
		return .init(bytes.sha1())
	}
	
	static func sha1(data: Data?...) -> Data {
		return sha1(data: data)
	}
}

// MARK: - Convenience Methods
extension HashUtils {
	static func sha256(_ data: [Data?]) -> Data {
		return sha256(data: data)
	}
	
	static func sha256(_ data: Data?...) -> Data {
		return sha256(data: data)
	}
	
	static func md5(_ data: [Data?]) -> Data {
		return md5(data: data)
	}
	
	static func md5(_ data: Data?...) -> Data {
		return md5(data: data)
	}
	
	static func sha1(_ data: [Data?]) -> Data {
		return sha1(data: data)
	}
	
	static func sha1(_ data: Data?...) -> Data {
		return sha1(data: data)
	}
}
