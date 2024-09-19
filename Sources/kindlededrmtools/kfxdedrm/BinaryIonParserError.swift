//
//  BinaryIonParserError.swift
//
//
//  Created by Paul Tavitian on 11/9/2024.
//

import Foundation

enum BinaryIonParserError {
    case eofEncountered
    case unexpectedEndOfStream
    case streamReadFailed
    case intOverflow
    case unexpectedNullTid
    case invalidBooleanLength(length: Int)
    case unknownVersionMarker(data: Data)
    case unexpectedFieldId(id: Int)
    case unexpectedState(state: ParserState)
    case stepInAssertionsFailed
    case streamPositionMismatch
    case intTooLong(len: Int)
    case onlyExponentInReadDecimal
    case decimalOverflow
    case expectedInt(found: String)
    case expectedString(found: String)
    case expectedIntForSymbol(found: String)
    case notInt
    case notString
    case notSymbol
    case notLobType(found: String)
    case importLacksMaxId(name: String)
    case unsupportedSymbolTableFieldId(id: Int)
    case expectedTidStruct(found: Int)
}

// MARK: - LocalizedError
extension BinaryIonParserError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .eofEncountered:
            return "EOF encountered"
        case .unexpectedEndOfStream:
            return "Unexpected end of stream."
        case .streamReadFailed:
            return "Failed to read from stream"
        case .intOverflow:
            return "int overflow"
        case .unexpectedNullTid:
            return "Unexpected NULL type ID."
        case let .invalidBooleanLength(length):
            return "Invalid boolean length: \(length.description)"
        case let .unknownVersionMarker(data):
            return "Unknown version marker: \(Util.formatData(data: data))"
        case let .unexpectedFieldId(id):
            return "Unexpected field ID: \(id.description)"
        case let .unexpectedState(state):
            return "Unexpected state: \(state.description)"
        case .stepInAssertionsFailed:
            return "stepIn assertions failed"
        case .streamPositionMismatch:
            return "Mismatch in stream position"
        case let .intTooLong(len):
            return "int too long: \(len.description)"
        case .onlyExponentInReadDecimal:
            return "Only exponent in ReadDecimal"
        case .decimalOverflow:
            return "Decimal overflow"
        case let .expectedInt(found):
            return "Expected an integer value but found: \(found)"
        case let .expectedString(found):
            return "Expected a string value but found: \(found)"
        case let .expectedIntForSymbol(found):
            return "Expected an integer value for symbol ID but found: \(found)"
        case .notInt:
            return "Not an int"
        case .notString:
            return "Not a string"
        case .notSymbol:
            return "Not a symbol"
        case let .notLobType(found):
            return "Not a LOB type: \(found)"
        case let .importLacksMaxId(name):
            return "Import \(name) lacks maxId"
        case let .unsupportedSymbolTableFieldId(id):
            return "Unsupported symbol table field id: \(id.description)"
        case let .expectedTidStruct(found):
            return "Expected a TID_STRUCT but found: \(found.description)"
        }
    }
}
