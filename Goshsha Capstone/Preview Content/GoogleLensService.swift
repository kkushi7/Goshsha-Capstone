//
//  GoogleLensService.swift
//  Goshsha Capstone
//
//  Created by Amber Chang on 2/19/25.
//

import UIKit

class GoogleLensService {
    static func searchWithGoogleLens(completion: @escaping (Result<Any, Error>) -> Void) {

        let apiKey = "7358a7044289d5d8336e0957355613fdeb75f3fc46bad3d1da729ee8a6f5853f"
        let apiUrl = "https://serpapi.com/search"
        let parameters = [
            "engine": "google_lens",
            "url": "https://i5.walmartimages.com/seo/Maybelline-SuperStay-Vinyl-Ink-Liquid-Lipstick-Lippy_11e2777a-590d-4449-821d-37f26d4ad76a.b1ef7a10917c271642b879e14657b1f1.png",
            "api_key": apiKey
        ]

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
