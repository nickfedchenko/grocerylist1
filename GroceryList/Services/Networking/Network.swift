//
//  Network.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 11.11.2022.
//

import Alamofire
import Gzip
import UIKit

final class NetworkEngine {
    /// метод отправки реквеста с данными
    func performDecodableUploadRequest<T: Decodable>(
        request: RequestGenerator,
        completion: @escaping ((Result<T, AFError>) -> Void)
    ) {
        
        let headers = [
            "Authorization": "Bearer yKuSDC3SQUQNm1kKOA8s7bfd0eQ0WXOTAc8QsfHQ",
            "Content-Type": "multipart/form-data"
        ]
        
        let decoder = createDecoder()
        let mfObject = request.multiformRequestObject
        
        AF.upload(multipartFormData: mfObject.0, to: mfObject.1,
                  method: .post, headers: .init(headers))
        .validate()
        .responseDecodable(
            of: T.self,
            queue: .global(qos: .userInitiated),
            decoder: decoder
        ) { result in
            guard let data = result.value else {
                if let error = result.error {
                    completion(.failure(error))
                }
                return
            }
            completion(.success(data))
        }
    }
    
    func performDecodableRequest<T: Decodable>(
        request: RequestGenerator,
        completion: @escaping ((Result<T, AFError>) -> Void)
    ) {
        let decoder = createDecoder()
        AF.request(request.request)
            .validate()
            .responseData { result in
                guard let data = result.value else {
                    if let error = result.error {
                        completion(.failure(error))
                    }
                    return
                }
                
                if data.isGzipped {
                    DispatchQueue.global().async {
                        guard let decopmressedData = try? data.gunzipped() else { return }
                        guard let unzippedDishes = try? decoder.decode(T.self, from: decopmressedData) else {
                            print("errModel")
                            return
                        }
                        completion(.success(unzippedDishes))
                    }
                    
                } else {
                    guard let dataModel = try? decoder.decode(T.self, from: data) else {
                        print("\(T.self)")
                        data.printJSON()
                        print("errModel")
                        return
                    }
                    completion(.success(dataModel))
                }
            }
    }

    func performDecodableRequestSend<T: Decodable, P: Encodable>(
        request: RequestGenerator,
        params: P,
        completion: @escaping ((Result<T, AFError>) -> Void)
    ) {
        let decoder = createDecoder()
        let headers: HTTPHeaders = [
            "Authorization": "Bearer yKuSDC3SQUQNm1kKOA8s7bfd0eQ0WXOTAc8QsfHQ",
            "Content-Type": "application/json"
        ]
        
        guard let url = request.request.url else { return }
        AF.request(url, method: .post, parameters: params,
                   encoder: JSONParameterEncoder.default, headers: headers, interceptor: nil, requestModifier: nil)
        .validate()
        .responseData { result in
            guard let data = result.value else {
                if let error = result.error {
                    completion(.failure(error))
                }
                return
            }
            
            guard let dataModel = try? decoder.decode(T.self, from: data) else {
                print("\(T.self)")
                data.printJSON()
                print("errModel")
                return
            }
            completion(.success(dataModel))
        }
    }
    
    private func createDecoder() -> JSONDecoder {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(formatter)
        return decoder
    }
}

extension Data {
    func printJSON() {
        if let JSONString = String(data: self, encoding: String.Encoding.utf8) {
            print(JSONString)
        }
    }
}
