//
//  KindleDatabase.swift
//
//
//  Created by Paul Tavitian on 9/9/2024.
//

import Foundation

typealias KindleDatabase = Dictionary<String, String>

extension KindleDatabase {
    private static let kindleAccountTokensKey: String = "kindle.account.tokens"
    private static let dsnKey: String = "DSN"
    private static let mazamaRandomNumberKey: String = "MazamaRandomNumber"
    private static let serialNumberKey: String = "SerialNumber"
    private static let idStringKey: String = "IDString"
    private static let usernameHashKey: String = "UsernameHash"
    private static let userNameKey: String = "UserName"
    
    private static let kindleCookieItemKey: String = "kindle.cookie.item"
    private static let eulaVersionAcceptedKey: String = "eulaVersionAccepted"
    private static let loginDateKey: String = "login_date"
    private static let kindleTokenItemKey: String = "kindle.token.item"
    private static let loginKey: String = "login"
    private static let kindleKeyItemKey: String = "kindle.key.item"
    private static let kindleNameInfoKey: String = "kindle.name.info"
    private static let kindleDeviceInfoKey: String = "kindle.device.info"
    private static let maxDateKey: String = "max_date"
    private static let sigVerifKey: String = "SIGVERIF"
    private static let buildVersionKey: String = "build_version"
    private static let kindleDirectedIDInfoKey: String = "kindle.directedid.info"
    private static let kindleAccountTypeInfoKey: String = "kindle.accounttype.info"
    private static let flashcardsPluginDataEncryptionKeyKey: String = "krx.flashcardsplugin.data.encryption_key"
    private static let notebookExportPluginDataEncryptionKeyKey: String = "krx.notebookexportplugin.data.encryption_key"
    private static let proxyHttpPasswordKey: String = "proxy.http.password"
    private static let proxyHttpUsernameKey: String = "proxy.http.username"
    
    init(infile: String) throws {
        let url: URL = Util.url(filePath: infile)
        try self.init(url: url)
    }
    
    init(url: URL) throws {
        let data: Data = try .init(contentsOf: url)
        try self.init(data: data)
    }
    
    init(data: Data) throws {
        self = try JSONDecoder().decode(KindleDatabase.self, from: data)
    }
    
    func getKindleAccountToken() -> String? {
        return self[KindleDatabase.kindleAccountTokensKey]
    }
    
    func getDSN() -> String? {
        return self[KindleDatabase.dsnKey]
    }
    
    func getMazamaRandomNumber() -> String? {
        return self[KindleDatabase.mazamaRandomNumberKey]
    }
    
    func getSerialNumber() -> String? {
        return self[KindleDatabase.serialNumberKey]
    }
    
    func getIDString() -> String? {
        return self[KindleDatabase.idStringKey]
    }
    
    func getUsernameHash() -> String? {
        return self[KindleDatabase.usernameHashKey]
    }
    
    func getUserName() -> String? {
        return self[KindleDatabase.userNameKey]
    }
    
    func getKindleAccountTokenOrDefault(defaultValue: String) -> String {
        return getKindleAccountToken() ?? defaultValue
    }
    
    func getDSNOrDefault(defaultValue: String) -> String {
        return getDSN() ?? defaultValue
    }
    
    func getMazamaRandomNumberOrDefault(defaultValue: String) -> String {
        return getMazamaRandomNumber() ?? defaultValue
    }
    
    func getSerialNumberOrDefault(defaultValue: String) -> String {
        return getSerialNumber() ?? defaultValue
    }
    
    func getIDStringOrDefault(defaultValue: String) -> String {
        return getIDString() ?? defaultValue
    }
    
    func getUsernameHashOrDefault(defaultValue: String) -> String {
        return getUsernameHash() ?? defaultValue
    }
    
    func getUserNameOrDefault(defaultValue: String) -> String {
        return getUserName() ?? defaultValue
    }
    
    func getKindleAccountTokenBytes() -> Data? {
        guard let token = getKindleAccountToken() else {
            return nil
        }
        
        Debug.print("Got Kindle Account Token:", token)
        return Util.hexStringToData(getKindleAccountToken())
    }
    
    func getDSNBytes() -> Data? {
        guard let dsn = getDSN() else {
            return nil
        }
        
        Debug.print("Got DSN:", dsn)
        return Util.hexStringToData(getDSN())
    }
    
    func getMazamaRandomNumberBytes() -> Data? {
        guard let mazama = getMazamaRandomNumber() else {
            return nil
        }
        
        Debug.print("Got MazamaRandomNumber:", mazama)
        return Util.hexStringToData(getMazamaRandomNumber())
    }
    
    func getSerialNumberBytes() -> Data? {
        guard let serialnum = getSerialNumber() else {
            return nil
        }
        
        Debug.print("Got SerialNumber:", serialnum)
        return Util.hexStringToData(getSerialNumber())
    }
    
    func getIDStringBytes() -> Data? {
        guard let idString = getIDString() else {
            return nil
        }
        
        Debug.print("Got IDString:", idString)
        return Util.hexStringToData(getIDString())
    }
    
    func getUsernameHashBytes() -> Data? {
        guard let hash = getUsernameHash() else {
            return nil
        }
        
        Debug.print("Got UsernameHash:", hash)
        return Util.hexStringToData(getUsernameHash())
    }
    
    func getUserNameBytes() -> Data? {
        guard let username = getUserName() else {
            return nil
        }
        
        Debug.print("Got UserName:", username)
        return Util.hexStringToData(getUserName())
    }
    
    func getKindleAccountTokenBytesOrDefault(defaultValue: Data) -> Data {
        return getKindleAccountTokenBytes() ?? defaultValue
    }
    
    func getDSNBytesOrDefault(defaultValue: Data) -> Data {
        return getDSNBytes() ?? defaultValue
    }
    
    func getMazamaRandomNumberBytesOrDefault(defaultValue: Data) -> Data {
        return getMazamaRandomNumberBytes() ?? defaultValue
    }
    
    func getSerialNumberBytesOrDefault(defaultValue: Data) -> Data {
        return getSerialNumberBytes() ?? defaultValue
    }
    
    func getIDStringBytesOrDefault(defaultValue: Data) -> Data {
        return getIDStringBytes() ?? defaultValue
    }
    
    func getUsernameHashBytesOrDefault(defaultValue: Data) -> Data {
        return getUsernameHashBytes() ?? defaultValue
    }
    
    func getUserNameBytesOrDefault(defaultValue: Data) -> Data {
        return getUserNameBytes() ?? defaultValue
    }
    
    func genKindleAccountToken() -> Data {
        return getKindleAccountTokenBytesOrDefault(defaultValue: .init(count: 0))
    }
    
    func genIdString() -> Data {
        return getSerialNumberBytesOrDefault(defaultValue: getIDStringBytes()!)
    }
    
    func genEncodedIdString() throws -> Data {
        return KindleKeyUtils.encodeHash(data: genIdString(), charMap: CharMaps.charMap1)
    }
    
    func genEncodedUsername() throws -> Data {
        return getUsernameHashBytesOrDefault(defaultValue: KindleKeyUtils.encodeHash(data: getUserNameBytes(), charMap: CharMaps.charMap1))
    }
    
    func genDSN() throws -> Data {
        let derivedDSN: Data = getDSNBytesOrDefault(defaultValue: try genAltDSN())
        Debug.print("Derived DSN:", derivedDSN.formattedForOutput)
        return derivedDSN
    }
    
    private func genAltDSN() throws -> Data {
        return try KindleKeyUtils.encode(data: HashUtils.sha1(getMazamaRandomNumberBytes(), genEncodedIdString(), genEncodedUsername()), charMap: CharMaps.charMap1)
    }
}

// MARK: - Contains
extension KindleDatabase {
    func containsKindleAccountToken() -> Bool {
        return keys.contains(KindleDatabase.kindleAccountTokensKey)
    }
    
    func containsDSN() -> Bool {
        return keys.contains(KindleDatabase.dsnKey)
    }
    
    func containsMazamaRandomNumber() -> Bool {
        return keys.contains(KindleDatabase.mazamaRandomNumberKey)
    }
    
    func containsSerialNumber() -> Bool {
        return keys.contains(KindleDatabase.serialNumberKey)
    }
    
    func containsIDString() -> Bool {
        return keys.contains(KindleDatabase.idStringKey)
    }
    
    func containsUsernameHash() -> Bool {
        return keys.contains(KindleDatabase.usernameHashKey)
    }
    
    func containsUserName() -> Bool {
        return keys.contains(KindleDatabase.userNameKey)
    }
}

// MARK: - Convenience Initialisers/Methods
extension KindleDatabase {
    init(_ infile: String) throws {
        try self.init(infile: infile)
    }
    
    init(_ url: URL) throws {
        try self.init(url: url)
    }
    
    init(_ data: Data) throws {
        try self.init(data: data)
    }
}
