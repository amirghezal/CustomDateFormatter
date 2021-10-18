//
//  CustomDateFormatter.swift
//
//  Created by a.ghezal on 18/10/21.
//
import Foundation

public extension DateFormatter {
    
    enum DateFormat {
        case defaultFormat
        // Add here your date formats
        
        fileprivate var dateFormat: String {
            switch self {
            case .defaultFormat: return "yyyy-MM-dd'T'hh:mm:ssZ"
            }
        }
        
        fileprivate var monthSymbols: [String]? {
            switch self {
            case .defaultFormat: return ["Jan",/*...*/"Dec"]
            }
        }
    }
    
    // MARK: Cached formattes
    private static var cachedDateFormatter: [DateFormat: DateFormatter] = [:]
    
    // MARK: Create and cache formatter
    private static func formatter(for format: DateFormat) -> DateFormatter {
        let formatterFactory: () -> DateFormatter = {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "ru_RU")
            dateFormatter.dateFormat = format.dateFormat
            
            if let monthSymbols = format.monthSymbols {
                dateFormatter.monthSymbols = monthSymbols
            }
            
            return dateFormatter
        }
        
        if let formatter = Self.cachedDateFormatter[format] {
            return formatter
        } else {
            let formatter = formatterFactory()
            Self.cachedDateFormatter[format] = formatter
            return formatter
        }
    }
    
    //MARK: For default JSON decoding
    static func decode(using decoder: Decoder) throws -> Date {
        let container = try decoder.singleValueContainer()
        let dateString = try container.decode(String.self)
        
        // MARK: Default formatts
        let formatts: [DateFormat] = [
            .defaultFormat
        ]
        
        let dates = formatts.compactMap { self.formatter(for: $0).date(from: dateString) }
        if let date = dates.first { return date }
        
        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Failed to decode date")
    }
}

//Example of implemantation
/*
let decoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .custom { try DateFormatter.decode(using: $0) }
    
    return decoder
}()
*/
