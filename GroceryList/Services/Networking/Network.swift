//
//  Network.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 11.11.2022.
//

import Foundation
import Gzip

class Networking {
    
    func fetchUserBalance(completion: @escaping(PostsResponse?) -> Void) {
        let locale = Locale.current.languageCode
        let currentLocale = locale == "ru" ? "ru" : "en"
        let urlString = "https://tracker.finanse.space/archive/\(currentLocale)_products.json.gz"
        fetchData(urlString: urlString, responce: completion)
    }
    
    private func fetchData<T: Decodable> (urlString: String, responce: @escaping (T?) -> Void) {
        requestData(urlString: urlString) { result in
            switch result {
            case .success(let data):
                let decoded = self.decodeJSON(type: T.self, from: data)
                responce(decoded)
            case .failure(let error):
                print("Error received reuestiong data: \(error.localizedDescription)")
                responce(nil)
            }
        }
    }
    
    private func decodeJSON<T: Decodable>(type: T.Type, from data: Data?) -> T? {
        let decoder = JSONDecoder()
        guard let data = data else { return nil }
        do {
            let objects = try decoder.decode(type.self, from: data)
            return objects
        } catch let jsonError {
            print(jsonError)
            return nil
        }
    }
    
    private func requestData(urlString: String, complition: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    complition(.failure(error))
                }
                guard let data = data else { return }
                let optimizedData: Data = try! data.gunzipped()
                print( try! JSONSerialization.jsonObject(with: optimizedData, options:.mutableContainers) )
                print(optimizedData)
                
                complition(.success(data))
            }
        }
        .resume()
    }
}

struct PostsResponse: Codable {
    let error: Bool
    let messages: [String]
}
