//
//  BinaryIonParser.swift
//
//
//  Created by Paul Tavitian on 11/9/2024.
//

import Foundation

final class BinaryIonParser {
    private let stream: DataInputStream
    private let initPos: Int
    private var annotations: [Int] = .init()
    private var catalog: [IonCatalogItem] = .init()
    private var symbols: SymbolTable = .init()
    private var eof: Bool = false
    private var state: ParserState = .beforeTid
    private var localRemaining: Int = -1
    private var needHasNext: Bool = true
    private var isInStruct: Bool = false
    private var valueTid: Int = -1
    private var valueFieldId: Int = -1
    private var parentTid: Int = 0
    private var valueLen: Int = 0
    private var valueIsNull: Bool = false
    private var valueIsTrue: Bool = false
    private var value: Any? = nil
    private var didImports: Bool = false
    private var containerStack: [ContainerRec] = .init()
    
    init(stream: DataInputStream) {
        self.stream = stream
        initPos = stream.tell()
        reset()
    }
    
    func reset() {
        needHasNext = true
        localRemaining = -1
        eof = false
        isInStruct = false
        containerStack = .init()
        stream.seek(position: initPos)
    }
    
    func hasNext() throws -> Bool {
        while needHasNext && !eof {
            try hasNextRaw()
            
            if containerStack.isEmpty && !valueIsNull {
                if valueTid == IonUtils.TID_SYMBOL {
                    if value as? Int == IonUtils.SID_ION_1_0 {
                        needHasNext = true
                    }
                } else if valueTid == IonUtils.TID_STRUCT {
                    for a in annotations {
                        if a == IonUtils.SID_ION_SYMBOL_TABLE {
                            try parseSymbolTable()
                            needHasNext = true
                            break
                        }
                    }
                }
            }
        }
        
        return !eof
    }
    
    private func hasNextRaw() throws {
        clearValue()
        
        while valueTid == -1 && !eof {
            needHasNext = false
            
            if state == .beforeField {
                if valueFieldId != IonUtils.SID_UNKNOWN {
                    throw BinaryIonParserError.unexpectedFieldId(id: valueFieldId)
                }
                
                valueFieldId = readFieldId()
                
                if valueFieldId != IonUtils.SID_UNKNOWN {
                    state = .beforeTid
                } else {
                    eof = true
                }
            } else if state == .beforeTid {
                state = .beforeValue
                valueTid = try readTypeId()
                
                if valueTid == -1 {
                    state = .eof
                    eof = true
                    break
                }
                
                if valueTid == IonUtils.TID_TYPEDECL {
                    if valueLen == 0 {
                        try checkVersionMarker()
                    } else {
                        try loadAnnotations()
                    }
                }
            } else if state == .beforeValue {
                try skip(valueLen)
                state = .afterValue
            } else if state == .afterValue {
                if isInStruct {
                    state = .beforeField
                } else {
                    state = .beforeTid
                }
            } else {
                if state != .eof {
                    throw BinaryIonParserError.unexpectedState(state: state)
                }
            }
        }
    }
}

// MARK: - Read
extension BinaryIonParser {
    private func read(count: Int = 1) throws -> Data {
        if localRemaining != -1 {
            localRemaining -= count
            
            if localRemaining < 0 {
                throw BinaryIonParserError.eofEncountered
            }
        }
        
        let result: Data = stream.readNBytes(count)
        
        if result.count == 0 {
            throw BinaryIonParserError.unexpectedEndOfStream
        }
        
        return result
    }
    
    private func clearValue() {
        valueTid = -1
        value = nil
        valueIsNull = false
        valueFieldId = IonUtils.SID_UNKNOWN
        annotations.removeAll()
    }
    
    private func skip(count: Int) throws {
        if localRemaining != -1 {
            localRemaining -= count
            
            if localRemaining < 0 {
                throw BinaryIonParserError.eofEncountered
            }
        }
        
        stream.skip(count)
    }
    
    private func readFieldId() -> Int {
        if localRemaining != -1 && localRemaining < 1 {
            return -1
        }
        
        do {
            return try readVarUInt()
        } catch {
            return -1
        }
    }
    
    private func readTypeId() throws -> Int {
        if localRemaining != -1 {
            if localRemaining < 1 {
                return -1
            }
            
            localRemaining -= 1
        }
        
        let b: Data = stream.readNBytes(1)
        
        if b.count < 1 {
            return -1
        }
        
        let bInt: Int = Util.ord(b)
        
        let result: Int = bInt >> 4
        var ln: Int = bInt & 0xF
        
        if ln == IonUtils.LEN_IS_VAR_LEN {
            ln = try readVarUInt()
        } else if ln == IonUtils.LEN_IS_NULL {
            ln = 0
            state = .afterValue
        } else if result == IonUtils.TID_NULL {
            // Must have LEN_IS_NULL
            throw BinaryIonParserError.unexpectedNullTid
        } else if result == IonUtils.TID_BOOLEAN {
            if ln > 1 {
                throw BinaryIonParserError.invalidBooleanLength(length: ln)
            }
            
            valueIsTrue = ln == 1
            ln = 0
            state = .afterValue
        } else if result == IonUtils.TID_STRUCT {
            if ln == 1 {
                ln = try readVarUInt()
            }
        }
        
        valueLen = ln
        
        return result
    }
    
    private func readVarUInt() throws -> Int {
        var b: Int = Util.ord(data: try read())
        
        var result: Int = b & 0x7F
        
        var i: Int = 0
        
        while (b & 0x80) == 0 && i < 4 {
            b = Util.ord(data: try read())
            result = (result << 7) | (b & 0x7F)
            i += 1
        }
        
        if i >= 4 && (b & 0x80) == 0 {
            throw BinaryIonParserError.intOverflow
        }
        
        return result
    }
    
    private func readVarInt() throws -> Int {
        var b: Int = Util.ord(try read())
        
        let negative: Bool = (b & 0x40) != 0
        var result: Int = b & 0x3F
        
        var i: Int = 0
        
        while (b & 0x80) == 0 && i < 4 {
            b = Util.ord(try read())
            result = (result << 7) | (b & 0x7F)
            i += 1
        }
        
        if i >= 4 && (b & 0x80) == 0 {
            throw BinaryIonParserError.intOverflow
        }
        
        if negative {
            return -result
        }
        
        return result
    }
}

// MARK: - Control
extension BinaryIonParser {
    @discardableResult
    func next() throws -> Int {
        if try hasNext() {
            needHasNext = true
            return valueTid
        } else {
            return -1
        }
    }
    
    func stepIn() throws {
        if (valueTid != IonUtils.TID_STRUCT && valueTid != IonUtils.TID_LIST && valueTid != IonUtils.TID_SEXP) || eof {
            throw BinaryIonParserError.stepInAssertionsFailed
        }
        
        if (valueIsNull && state != .afterValue) || (!valueIsNull && state != .beforeValue) {
            throw BinaryIonParserError.stepInAssertionsFailed
        }
        
        var nextRem: Int = localRemaining
        
        if nextRem != -1 {
            nextRem -= valueLen
            
            if nextRem < 0 {
                nextRem = 0
            }
        }
        
        push(parentTid, stream.tell() + valueLen, nextRem)
        
        isInStruct = valueTid == IonUtils.TID_STRUCT
        
        if isInStruct {
            state = .beforeField
        } else {
            state = .beforeTid
        }
        
        localRemaining = valueLen
        parentTid = valueTid
        clearValue()
        needHasNext = true
    }
    
    func stepOut() throws {
        let rec: ContainerRec = containerStack.removeLast()
        
        eof = false
        parentTid = rec.tid
        
        if parentTid == IonUtils.TID_STRUCT {
            isInStruct = true
            state = .beforeField
        } else {
            isInStruct = false
            state = .beforeTid
        }
        
        needHasNext = true
        
        clearValue()
        
        let curPos: Int = stream.tell()
        
        if rec.nextPos > curPos {
            try skip(rec.nextPos - curPos)
        } else {
            if rec.nextPos != curPos {
                throw BinaryIonParserError.streamPositionMismatch
            }
        }
        
        localRemaining = rec.remaining
    }
}

// MARK: - Type Values
extension BinaryIonParser {
    private func prepareValue() throws {
        if value == nil {
            try loadScalarValue()
        }
    }
    
    private func loadScalarValue() throws {
        if valueTid != IonUtils.TID_NULL && valueTid != IonUtils.TID_BOOLEAN && valueTid != IonUtils.TID_POSINT &&
            valueTid != IonUtils.TID_NEGINT && valueTid != IonUtils.TID_FLOAT && valueTid != IonUtils.TID_DECIMAL &&
            valueTid != IonUtils.TID_TIMESTAMP && valueTid != IonUtils.TID_SYMBOL && valueTid != IonUtils.TID_STRING {
            return
        }
        
        if valueIsNull {
            value = nil
            return
        }
        
        if valueTid == IonUtils.TID_STRING {
            let stringBytes: Data = try read(valueLen)
            value = String(data: stringBytes, encoding: .utf8)
        } else if valueTid == IonUtils.TID_POSINT || valueTid == IonUtils.TID_NEGINT || valueTid == IonUtils.TID_SYMBOL {
            if valueLen == 0 {
                value = 0
            } else {
                if valueLen > 4 {
                    throw BinaryIonParserError.intTooLong(len: valueLen)
                }
                
                var v: Int = 0
                
                var i: Int = valueLen - 1
                
                while i >= 0 {
                    v |= Util.ord(try read()) << (i * 8)
                    i -= 1
                }
                
                if valueTid == IonUtils.TID_NEGINT {
                    value = -v
                } else {
                    value = v
                }
            }
        } else if valueTid == IonUtils.TID_DECIMAL {
            value = try readDecimal()
        }
        
        state = .afterValue
    }
    
    private func intValue() throws -> Int {
        if valueTid != IonUtils.TID_POSINT && valueTid != IonUtils.TID_NEGINT {
            throw BinaryIonParserError.notInt
        }
        
        try prepareValue()
        
        // Assuming value is stored as an Integer after being processed by loadScalarValue
        if let intValue = value as? Int {
            return intValue
        } else {
            throw BinaryIonParserError.expectedInt(found: .init(describing: type(of: value)))
        }
    }
    
    func stringValue() throws -> String {
        if valueTid != IonUtils.TID_STRING {
            throw BinaryIonParserError.notString
        }
        
        if valueIsNull {
            return ""
        }
        
        try prepareValue()
        
        if let string = value as? String {
            return string
        } else {
            throw BinaryIonParserError.expectedString(found: .init(describing: type(of: value)))
        }
    }
    
    private func symbolValue() throws -> String {
        if valueTid != IonUtils.TID_SYMBOL {
            throw BinaryIonParserError.notSymbol
        }
        
        try prepareValue()
        
        if let symbolId = value as? Int {
            var result: String = try symbols.findById(symbolId)
            
            if result.isEmpty {
                result = "SYMBOL#\(symbolId.description)"
            }
            
            return result
        } else {
            throw BinaryIonParserError.expectedIntForSymbol(found: .init(describing: type(of: value)))
        }
    }
    
    func lobValue() throws -> Data? {
        if valueTid != IonUtils.TID_CLOB && valueTid != IonUtils.TID_BLOB {
            throw BinaryIonParserError.notLobType(found: try getFieldName())
        }
        
        if valueIsNull {
            return nil
        }
        
        let result: Data = try read(valueLen)
        
        state = .afterValue
        
        return result
    }
    
    private func readDecimal() throws -> Double {
        if valueLen == 0 {
            return 0
        }
        
        let rem: Int = localRemaining - valueLen
        localRemaining = valueLen
        
        let exponent: Int = try readVarInt()
        
        if localRemaining <= 0 {
            throw BinaryIonParserError.onlyExponentInReadDecimal
        }
        
        if localRemaining > 8 {
            throw BinaryIonParserError.decimalOverflow
        }
        
        var signed: Bool = false
        
        var b: [Int] = Util.ordList(try read(localRemaining))
        
        if (b[0] & 0x80) != 0 {
            b[0] &= 0x7F
            signed = true
        }
        
        // Convert variably sized network order integer into 64-bit little-endian
        var j: Int = 0
        var vb: [Int] = .init(repeating: 0, count: 8)
        
        for i in stride(from: b.count, to: 0, by: -1) {
            vb[i] = b[j]
            j += 1
        }
        
        let buffer: Data = .init(vb.map({.init(bitPattern: .init($0))}))
        let v: Int64 = .init(buffer.withUnsafeBytes { $0.load(as: UInt64.self).littleEndian })
        var result: Double = .init(v) * pow(10, .init(exponent))
        
        if signed {
            result = -result
        }
        
        localRemaining = rem
        
        return result
    }
    
    func getFieldName() throws -> String {
        if valueFieldId == IonUtils.SID_UNKNOWN {
            return ""
        }
        
        return try symbols.findById(valueFieldId)
    }
    
    private func getFieldNameSymbol() throws -> SymbolToken {
        return try .init(getFieldName(), valueFieldId)
    }
    
    func getTypeName() throws -> String {
        if annotations.isEmpty {
            return ""
        }
        
        return try symbols.findById(annotations[0])
    }
}

// MARK: - Imports
extension BinaryIonParser {
    private func readImport() throws {
        var version: Int = -1
        var maxId: Int = -1
        var name: String = ""
        
        try stepIn()
        
        var t: Int = try next()
        
        while t != -1 {
            if !valueIsNull && valueFieldId != IonUtils.SID_UNKNOWN {
                if valueFieldId == IonUtils.SID_NAME {
                    name = try stringValue()
                } else if valueFieldId == IonUtils.SID_VERSION {
                    version = try intValue()
                } else if valueFieldId == IonUtils.SID_MAX_ID {
                    maxId = try intValue()
                }
            }
            
            t = try next()
        }
        
        try stepOut()
        
        if name.isEmpty || name == SystemSymbols.ION {
            return
        }
        
        if version < 1 {
            version = 1
        }
        
        let table: IonCatalogItem? = findCatalogItem(name)
        
        if maxId < 0 {
            guard let table, version != table.version else {
                throw BinaryIonParserError.importLacksMaxId(name: name)
            }
            
            maxId = table.symnames.count
        }
        
        if let table {
            symbols.importSymbols(table, min(maxId, table.symnames.count))
            
            if table.symnames.count < maxId {
                symbols.importUnknown("\(name)-unknown", maxId - table.symnames.count)
            }
        } else {
            symbols.importUnknown(name, maxId)
        }
    }
}

// MARK: - Misc
extension BinaryIonParser {
    private func push(typeId: Int, nextPosition: Int, nextRemaining: Int) {
        containerStack.append(.init(nextPosition, typeId, nextRemaining))
    }
    
    func addToCatalog(name: String, version: Int, symbols: [String]) {
        catalog.append(.init(name: name, version: version, symnames: symbols))
    }
    
    private func checkVersionMarker() throws {
        for marker in IonUtils.VERSION_MARKER {
            let data: Data = try read()
            
            if marker != data {
                throw BinaryIonParserError.unknownVersionMarker(data: data)
            }
        }
        
        valueLen = 0
        valueTid = IonUtils.TID_SYMBOL
        value = IonUtils.SID_ION_1_0
        valueIsNull = false
        valueFieldId = IonUtils.SID_UNKNOWN
        state = .afterValue
    }
    
    private func loadAnnotations() throws {
        let ln: Int = try readVarUInt()
        let maxPos: Int64 = .init(stream.tell() + ln)
        
        while stream.tell() < maxPos {
            annotations.append(try readVarUInt())
        }
        
        valueTid = try readTypeId()
    }
    
    private func findCatalogItem(name: String) -> IonCatalogItem? {
        for item in catalog {
            if item.name == name {
                return item
            }
        }
        
        return nil // Return null if no matching item is found
    }
    
    private func gatherImports() throws {
        try stepIn()
        
        var t: Int = try next()
        
        while t != -1 {
            if !valueIsNull && t == IonUtils.TID_STRUCT {
                try readImport()
            }
            
            t = try next()
        }
        
        try stepOut()
    }
    
    private func parseSymbolTable() throws {
        // Advance to the next value (shouldn't do anything meaningful)
        try next()
        
        if valueTid != IonUtils.TID_STRUCT {
            throw BinaryIonParserError.expectedTidStruct(found: valueTid)
        }
        
        if didImports {
            return
        }
        
        try stepIn()
        
        var fieldType: Int = try next()
        
        while fieldType != -1 {
            if !valueIsNull {
                if valueFieldId != IonUtils.SID_IMPORTS {
                    throw BinaryIonParserError.unsupportedSymbolTableFieldId(id: valueFieldId)
                }
                
                if fieldType == IonUtils.TID_LIST {
                    try gatherImports()
                }
            }
            
            fieldType = try next()
        }
        
        try stepOut()
        didImports = true
    }
}

// MARK: - Convenience Initialisers/Methods
extension BinaryIonParser {
    convenience init(_ stream: DataInputStream) {
        self.init(stream: stream)
    }
    
    private func push(_ typeId: Int, _ nextPosition: Int, _ nextRemaining: Int) {
        push(typeId: typeId, nextPosition: nextPosition, nextRemaining: nextRemaining)
    }
    
    private func findCatalogItem(_ name: String) -> IonCatalogItem? {
        return findCatalogItem(name: name)
    }
    
    private func skip(_ count: Int) throws {
        try skip(count: count)
    }
    
    private func read(_ count: Int) throws -> Data {
        return try read(count: count)
    }
}
