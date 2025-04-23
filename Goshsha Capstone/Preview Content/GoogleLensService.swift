//
//  GoogleLensService.swift
//  Goshsha Capstone
//
//  Created by Amber Chang on 2/19/25.
//

import UIKit
import Foundation

class GoogleLensService {
    static func searchWithGoogleLens(url: String, completion: @escaping (Result<Any, Error>) -> Void) {

        let apiKey = "7358a7044289d5d8336e0957355613fdeb75f3fc46bad3d1da729ee8a6f5853f"
        let apiUrl = "https://serpapi.com/search"
        
        let imageUrl = url
//        let correctedUrl = imageUrl.removingPercentEncoding ?? imageUrl
        let parameters = [
            "engine": "google_lens",
            "url": imageUrl,
            "api_key": apiKey
        ]

        var urlComponents = URLComponents(string: apiUrl)!
        urlComponents.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }

        guard let url = urlComponents.url else{
            completion(.failure(NSError(domain: "Invalid Url", code: -1)))
            return
        }

        // query
        let urlWithParams = apiUrl + "?" + parameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        
        // request
        guard let url = URL(string: urlWithParams) else {
            completion(.failure(NSError(domain: "URLError", code: -1, userInfo: [NSLocalizedDescriptionKey: "invalid URL."])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(NSError(domain: "HTTPError", code: 0, userInfo: [NSLocalizedDescriptionKey: "request failed."])))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "no data", code: -1, userInfo: nil)))
                return
            }

            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                completion(.success(jsonResponse))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }

}
