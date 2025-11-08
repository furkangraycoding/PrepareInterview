//
//  TranslationService.swift
//  InterviewPrep
//
//  Created on 2024
//

import Foundation

class TranslationService: ObservableObject {
    static let shared = TranslationService()
    
    // Cache for translations to avoid repeated API calls
    // Key format: "tr_en_<text>" or "en_tr_<text>"
    private var translationCache: [String: String] = [:]
    
    /// Get cache statistics for debugging
    var cacheSize: Int {
        return translationCache.count
    }
    
    // Google Translate API Key - Set this in your environment or Info.plist
    // For free tier, you can use: https://translate.googleapis.com/translate_a/single?client=gtx&sl=tr&tl=en&dt=t&q=
    private let apiKey: String? = nil // Set your API key here or use environment variable
    
    private init() {}
    
    /// Translates text from Turkish to English using Google Translate
    func translateToEnglish(_ text: String) async -> String {
        // Normalize text for cache key (trim whitespace)
        let normalizedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // If text is already in English or empty, return as is
        if normalizedText.isEmpty {
            return text
        }
        
        // Check cache first with normalized key
        let cacheKey = "tr_en_\(normalizedText)"
        if let cached = translationCache[cacheKey] {
            print("✅ Cache HIT for: '\(normalizedText.prefix(30))...'")
            return cached
        }
        
        print("🔄 Cache MISS - Translating: '\(normalizedText.prefix(30))...'")
        
        // Use Google Translate free API endpoint
        // Properly encode the normalized text for URL
        guard let encodedText = normalizedText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("Translation error: Failed to encode text")
            return text
        }
        
        let urlString = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=tr&tl=en&dt=t&q=\(encodedText)"
        
        guard let url = URL(string: urlString) else {
            print("Translation error: Invalid URL")
            return text
        }
        
        do {
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.timeoutInterval = 10
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                print("Translation error: HTTP error")
                return text
            }
            
            // Parse the Google Translate response
            // Response format: [[["translated text", null, null, ...], ...], "detected_language", ...]
            // Try multiple parsing strategies for robustness
            
            // Strategy 1: Standard nested array format
            if let json = try? JSONSerialization.jsonObject(with: data) as? [Any] {
                // Safely check if first element is an array
                if json.count > 0, let firstElement = json.first {
                    if let firstArray = firstElement as? [Any] {
                        var translatedText = ""
                        for item in firstArray {
                            // Safely check if item is an array
                            if let translationArray = item as? [Any] {
                                // Get the first string element from each translation array
                                for element in translationArray {
                                    if let text = element as? String, !text.isEmpty {
                                        translatedText += text
                                        break // Only take the first non-empty string
                                    }
                                }
                            }
                        }
                        
                        translatedText = translatedText.trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        if !translatedText.isEmpty && translatedText != normalizedText {
                            // Cache the translation immediately
                            translationCache[cacheKey] = translatedText
                            print("✅ Translation successful & CACHED: '\(normalizedText.prefix(30))...' -> '\(translatedText.prefix(30))...'")
                            return translatedText
                        }
                    }
                }
            }
            
            // Strategy 2: Try direct string extraction (safer recursive approach)
            if let json = try? JSONSerialization.jsonObject(with: data) as? [Any] {
                var translatedText = ""
                func extractStrings(from array: [Any]) {
                    for item in array {
                        // Check type before processing
                        if let string = item as? String, !string.isEmpty {
                            // Skip detected language codes and other metadata
                            if string.count > 2 && !["tr", "en", "auto"].contains(string.lowercased()) {
                                translatedText += string
                            }
                        } else if let nestedArray = item as? [Any] {
                            // Only recurse if it's actually an array
                            extractStrings(from: nestedArray)
                        }
                        // Ignore other types (Number, Bool, etc.)
                    }
                }
                extractStrings(from: json)
                
                translatedText = translatedText.trimmingCharacters(in: .whitespacesAndNewlines)
                
                if !translatedText.isEmpty && translatedText != normalizedText {
                    // Cache the translation immediately
                    translationCache[cacheKey] = translatedText
                    print("✅ Translation successful (strategy 2) & CACHED: '\(normalizedText.prefix(30))...' -> '\(translatedText.prefix(30))...'")
                    return translatedText
                }
            }
            
            // If all strategies fail, log and return original
            print("Translation error: Could not parse response")
            if let rawString = String(data: data, encoding: .utf8) {
                print("Raw response (first 500 chars): \(String(rawString.prefix(500)))")
            }
            return text
        } catch {
            print("Translation error: \(error.localizedDescription)")
            return text
        }
    }
    
    /// Translates text from English to Turkish
    func translateToTurkish(_ text: String) async -> String {
        // Normalize text for cache key (trim whitespace)
        let normalizedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // If text is empty, return as is
        if normalizedText.isEmpty {
            return text
        }
        
        // Check cache first with normalized key
        let cacheKey = "en_tr_\(normalizedText)"
        if let cached = translationCache[cacheKey] {
            print("✅ Cache HIT for: '\(normalizedText.prefix(30))...'")
            return cached
        }
        
        print("🔄 Cache MISS - Translating: '\(normalizedText.prefix(30))...'")
        
        guard let encodedText = normalizedText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("Translation error: Failed to encode text")
            return text
        }
        
        let urlString = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=tr&dt=t&q=\(encodedText)"
        
        guard let url = URL(string: urlString) else {
            print("Translation error: Invalid URL")
            return text
        }
        
        do {
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.timeoutInterval = 10
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                print("Translation error: HTTP error")
                return text
            }
            
            // Parse the Google Translate response (same strategy as translateToEnglish)
            if let json = try? JSONSerialization.jsonObject(with: data) as? [Any] {
                // Safely check if first element is an array
                if json.count > 0, let firstElement = json.first {
                    if let firstArray = firstElement as? [Any] {
                        var translatedText = ""
                        for item in firstArray {
                            // Safely check if item is an array
                            if let translationArray = item as? [Any] {
                                for element in translationArray {
                                    if let text = element as? String, !text.isEmpty {
                                        translatedText += text
                                        break
                                    }
                                }
                            }
                        }
                        
                        translatedText = translatedText.trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        if !translatedText.isEmpty && translatedText != normalizedText {
                            // Cache the translation immediately
                            translationCache[cacheKey] = translatedText
                            print("✅ Translation successful & CACHED: '\(normalizedText.prefix(30))...' -> '\(translatedText.prefix(30))...'")
                            return translatedText
                        }
                    }
                }
            }
            
            // Strategy 2: Recursive string extraction (safer approach)
            if let json = try? JSONSerialization.jsonObject(with: data) as? [Any] {
                var translatedText = ""
                func extractStrings(from array: [Any]) {
                    for item in array {
                        // Check type before processing
                        if let string = item as? String, !string.isEmpty {
                            if string.count > 2 && !["tr", "en", "auto"].contains(string.lowercased()) {
                                translatedText += string
                            }
                        } else if let nestedArray = item as? [Any] {
                            // Only recurse if it's actually an array
                            extractStrings(from: nestedArray)
                        }
                        // Ignore other types (Number, Bool, etc.)
                    }
                }
                extractStrings(from: json)
                
                translatedText = translatedText.trimmingCharacters(in: .whitespacesAndNewlines)
                
                if !translatedText.isEmpty && translatedText != normalizedText {
                    // Cache the translation immediately
                    translationCache[cacheKey] = translatedText
                    print("✅ Translation successful (strategy 2) & CACHED: '\(normalizedText.prefix(30))...' -> '\(translatedText.prefix(30))...'")
                    return translatedText
                }
            }
            
            print("Translation error: Could not parse response")
            if let rawString = String(data: data, encoding: .utf8) {
                print("Raw response (first 500 chars): \(String(rawString.prefix(500)))")
            }
            return text
        } catch {
            print("Translation error: \(error.localizedDescription)")
            return text
        }
    }
    
    /// Clears the translation cache
    func clearCache() {
        translationCache.removeAll()
    }
}

