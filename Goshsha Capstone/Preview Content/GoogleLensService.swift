//
//  GoogleLensService.swift
//  Goshsha Capstone
//
//  Created by Yu-Shin Chang and Kushi Kumbagowdanaon on 2/19/25.
//

import Foundation

class GoogleLensService {
    // reppace with your own api key obtained from the SerpApi.com
    private static let apiKey = ""
    private static let apiBaseURL = "https://serpapi.com/search"

    static func searchWithGoogleLens(imageURL: String, completion: @escaping (Result<Any, Error>) -> Void) {
        var urlComponents = URLComponents(string: apiBaseURL)
        urlComponents?.queryItems = [
            URLQueryItem(name: "engine", value: "google_lens"),
            URLQueryItem(name: "url", value: imageURL),
            URLQueryItem(name: "api_key", value: apiKey)
        ]

        guard let finalURL = urlComponents?.url else {
            completion(.failure(NSError(domain: "InvalidURL", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to build URL."])))
            return
        }

        var request = URLRequest(url: finalURL)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                completion(.failure(NSError(domain: "HTTPError", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Unexpected response."])))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "DataError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received."])))
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                completion(.success(json))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
