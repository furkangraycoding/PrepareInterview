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
    // Key format: "tr_en_<text>" or "en_tr_<text>" or "tr_es_<text>" etc.
    // Each language pair has its own cache entries
    private var translationCache: [String: String] = [:]
    private let cacheKey = "TranslationCache"
    
    /// Get cache statistics for debugging
    var cacheSize: Int {
        return translationCache.count
    }
    
    // Google Translate API Key - Set this in your environment or Info.plist
    // For free tier, you can use: https://translate.googleapis.com/translate_a/single?client=gtx&sl=tr&tl=en&dt=t&q=
    private let apiKey: String? = nil // Set your API key here or use environment variable
    
    private init() {
        loadCacheFromDisk()
    }
    
    /// Load cache from UserDefaults (persistent storage)
    private func loadCacheFromDisk() {
        if let data = UserDefaults.standard.data(forKey: cacheKey),
           let decoded = try? JSONDecoder().decode([String: String].self, from: data) {
            translationCache = decoded
            print("📦 Loaded \(decoded.count) translations from disk cache")
        }
    }
    
    /// Save cache to UserDefaults (persistent storage)
    private func saveCacheToDisk() {
        if let encoded = try? JSONEncoder().encode(translationCache) {
            UserDefaults.standard.set(encoded, forKey: cacheKey)
            print("💾 Saved \(translationCache.count) translations to disk cache")
        }
    }
    
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
                            saveCacheToDisk()
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
                    saveCacheToDisk()
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
                            saveCacheToDisk()
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
                    saveCacheToDisk()
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
    
    /// General translation function - translates from source language to target language
    func translate(_ text: String, from sourceLanguage: AppLanguage, to targetLanguage: AppLanguage) async -> String {
        // If same language, return as is
        if sourceLanguage == targetLanguage {
            return text
        }
        
        // Normalize text for cache key
        let normalizedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if normalizedText.isEmpty {
            return text
        }
        
        // Check cache first
        let cacheKey = "\(sourceLanguage.rawValue)_\(targetLanguage.rawValue)_\(normalizedText)"
        if let cached = translationCache[cacheKey] {
            print("✅ Cache HIT for: '\(normalizedText.prefix(30))...'")
            return cached
        }
        
        print("🔄 Cache MISS - Translating: '\(normalizedText.prefix(30))...'")
        
        guard let encodedText = normalizedText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("Translation error: Failed to encode text")
            return text
        }
        
        let urlString = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=\(sourceLanguage.googleTranslateCode)&tl=\(targetLanguage.googleTranslateCode)&dt=t&q=\(encodedText)"
        
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
            if let json = try? JSONSerialization.jsonObject(with: data) as? [Any] {
                if json.count > 0, let firstElement = json.first {
                    if let firstArray = firstElement as? [Any] {
                        var translatedText = ""
                        for item in firstArray {
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
                            translationCache[cacheKey] = translatedText
                            saveCacheToDisk()
                            print("✅ Translation successful & CACHED: '\(normalizedText.prefix(30))...' -> '\(translatedText.prefix(30))...'")
                            return translatedText
                        }
                    }
                }
            }
            
            // Strategy 2: Recursive string extraction (more careful)
            if let json = try? JSONSerialization.jsonObject(with: data) as? [Any] {
                var translatedText = ""
                var foundStrings: [String] = []
                
                func extractStrings(from array: [Any], depth: Int = 0) {
                    // Limit depth to avoid parsing too deep
                    guard depth < 10 else { return }
                    
                    for item in array {
                        if let string = item as? String, !string.isEmpty {
                            let lowercased = string.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                            
                            // Skip language codes, cache keys, file extensions, and hash patterns
                            if lowercased.count <= 2 && ["tr", "en", "es", "fr", "ru", "zh", "auto", "null"].contains(lowercased) {
                                continue
                            }
                            
                            // Skip cache key patterns
                            if lowercased.contains("tr_") && lowercased.contains("_") && lowercased.count < 10 {
                                continue
                            }
                            
                            // Skip file extensions
                            if lowercased.hasSuffix(".md") || lowercased.hasSuffix(".txt") || lowercased.hasSuffix(".json") {
                                continue
                            }
                            
                            // Skip hash patterns (32+ character hex strings)
                            if lowercased.range(of: #"^[a-f0-9]{32,}$"#, options: .regularExpression) != nil {
                                continue
                            }
                            
                            // Skip date patterns
                            if lowercased.range(of: #"^\d{4}q\d$"#, options: .regularExpression) != nil {
                                continue
                            }
                            
                            // Only add meaningful strings (more than 2 characters, not just numbers)
                            if string.count > 2 {
                                foundStrings.append(string)
                            }
                        } else if let nestedArray = item as? [Any] {
                            extractStrings(from: nestedArray, depth: depth + 1)
                        }
                    }
                }
                
                extractStrings(from: json)
                
                // Take the first meaningful string (usually the translation)
                // Avoid duplicates by checking if we've seen similar content
                if let firstMeaningful = foundStrings.first {
                    translatedText = firstMeaningful.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    // If the translation seems to contain duplicates, try to clean it
                    if translatedText.count > normalizedText.count * 2 {
                        // Might be duplicated, try to extract unique parts
                        let words = translatedText.split(separator: " ").map { String($0) }
                        var uniqueWords: [String] = []
                        var seen: Set<String> = []
                        
                        for word in words {
                            if !seen.contains(word.lowercased()) {
                                uniqueWords.append(word)
                                seen.insert(word.lowercased())
                            }
                        }
                        
                        translatedText = uniqueWords.joined(separator: " ")
                    }
                }
                
                translatedText = translatedText.trimmingCharacters(in: .whitespacesAndNewlines)
                
                // Only return if we got a meaningful translation
                if !translatedText.isEmpty && translatedText != normalizedText && translatedText.count > normalizedText.count / 2 {
                    translationCache[cacheKey] = translatedText
                    saveCacheToDisk()
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
    
    /// Translates text from Turkish to target language
    func translateFromTurkish(_ text: String, to targetLanguage: AppLanguage) async -> String {
        return await translate(text, from: .turkish, to: targetLanguage)
    }
    
    /// Get cached translation if available
    func getCachedTranslation(_ cacheKey: String) -> String? {
        return translationCache[cacheKey]
    }
    
    /// Clears the translation cache (both memory and disk)
    func clearCache() {
        translationCache.removeAll()
        UserDefaults.standard.removeObject(forKey: cacheKey)
        print("🗑️ Translation cache cleared")
    }
    
    /// Get cache statistics by language pair
    func getCacheStats() -> [String: Int] {
        var stats: [String: Int] = [:]
        for key in translationCache.keys {
            // Extract language pair from key (e.g., "tr_en_" from "tr_en_text")
            if let range = key.range(of: #"^[a-z]{2}_[a-z]{2}_"#, options: .regularExpression) {
                let langPair = String(key[range].dropLast()) // Remove trailing underscore
                stats[langPair, default: 0] += 1
            }
        }
        return stats
    }
}

