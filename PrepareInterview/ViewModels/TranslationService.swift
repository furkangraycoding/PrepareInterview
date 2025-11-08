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
    private var translationCache: [String: String] = [:]
    
    private init() {}
    
    /// Translates text from Turkish to English using MyMemory API (more reliable)
    func translateToEnglish(_ text: String) async -> String {
        // Check cache first
        let cacheKey = "tr_en_\(text)"
        if let cached = translationCache[cacheKey] {
            print("✅ Using cached translation for: \(text.prefix(30))...")
            return cached
        }
        
        // If text is empty, return as is
        if text.isEmpty {
            return text
        }
        
        print("🔄 Translating to English: \(text.prefix(30))...")
        
        // Clean and prepare text
        let cleanText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Use MyMemory Translation API (free, no key required, 5000 chars/day limit)
        guard let encodedText = cleanText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("❌ Failed to encode text")
            return text
        }
        
        // MyMemory API endpoint
        let urlString = "https://api.mymemory.translated.net/get?q=\(encodedText)&langpair=tr|en"
        
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            return text
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // Check response
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Response status: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode != 200 {
                    print("❌ HTTP Error: \(httpResponse.statusCode)")
                    return text
                }
            }
            
            // Parse MyMemory API response
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                print("📦 JSON Response: \(json)")
                
                if let responseData = json["responseData"] as? [String: Any],
                   let translatedText = responseData["translatedText"] as? String,
                   !translatedText.isEmpty {
                    
                    // Cache the translation
                    translationCache[cacheKey] = translatedText
                    print("✅ Translation successful: \(translatedText.prefix(30))...")
                    return translatedText
                } else {
                    print("❌ No translation in response")
                    print("📄 Full response: \(json)")
                }
            } else {
                print("❌ Failed to parse JSON")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📄 Raw response: \(jsonString)")
                }
            }
        } catch {
            print("❌ Translation error: \(error.localizedDescription)")
        }
        
        // Return original text if translation fails
        print("⚠️ Returning original text")
        return text
    }
    
    /// Translates text from English to Turkish
    func translateToTurkish(_ text: String) async -> String {
        let cacheKey = "en_tr_\(text)"
        if let cached = translationCache[cacheKey] {
            print("✅ Using cached translation for: \(text.prefix(30))...")
            return cached
        }
        
        if text.isEmpty {
            return text
        }
        
        print("🔄 Translating to Turkish: \(text.prefix(30))...")
        
        let cleanText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let encodedText = cleanText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("❌ Failed to encode text")
            return text
        }
        
        let urlString = "https://api.mymemory.translated.net/get?q=\(encodedText)&langpair=en|tr"
        
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            return text
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Response status: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode != 200 {
                    print("❌ HTTP Error: \(httpResponse.statusCode)")
                    return text
                }
            }
            
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                print("📦 JSON Response: \(json)")
                
                if let responseData = json["responseData"] as? [String: Any],
                   let translatedText = responseData["translatedText"] as? String,
                   !translatedText.isEmpty {
                    
                    translationCache[cacheKey] = translatedText
                    print("✅ Translation successful: \(translatedText.prefix(30))...")
                    return translatedText
                } else {
                    print("❌ No translation in response")
                }
            } else {
                print("❌ Failed to parse JSON")
            }
        } catch {
            print("❌ Translation error: \(error.localizedDescription)")
        }
        
        print("⚠️ Returning original text")
        return text
    }
    
    /// Clears the translation cache
    func clearCache() {
        translationCache.removeAll()
        print("🗑️ Translation cache cleared")
    }
}
