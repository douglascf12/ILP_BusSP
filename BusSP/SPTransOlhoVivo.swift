//
//  SPTransOlhoVivo.swift
//  BusSP
//
//  Created by Douglas Cardoso Ferreira on 16/07/20.
//  Copyright © 2020 Douglas Cardoso. All rights reserved.
//

import Foundation
import MapKit

enum BusError {
    case url
    case taskError(error: Error)
    case noResponse
    case noData
    case responseStatusCode(code: Int)
    case invalidJSON
}

class SPTransOlhoVivo {

    private static let basePath = "http://api.olhovivo.sptrans.com.br/v2.1"
    private static let token = "722f35c2069770f36029f51cbe9165e944539083572e467b5c22d9fa38124625"

    private static let configuration: URLSessionConfiguration = {
        let config = URLSessionConfiguration.default
        config.allowsCellularAccess = true // permitir acesso por rede de dados móveis
        config.httpAdditionalHeaders = ["Content-Type": "application/json"]
        config.timeoutIntervalForRequest = 30.0
        config.httpMaximumConnectionsPerHost = 5
        return config
    }()

    private static let session = URLSession(configuration: configuration)

    class func autenticar(onComplete: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(basePath)/Login/Autenticar?token=\(token)") else {
            onComplete(false)
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            if error == nil {
                guard let response = response as? HTTPURLResponse, response.statusCode == 200, let _ = data else {
                    onComplete(false)
                    return
                }
                onComplete(true)
            } else {
                onComplete(false)
            }
        }
        dataTask.resume()
    }

    class func buscarLinhas(_ termosBusca: String, onComplete: @escaping ([Bus]) -> Void, onError: @escaping (BusError) -> Void) {
        guard let url = URL(string: "\(basePath)/Linha/Buscar?termosBusca=\(termosBusca)") else {
            onError(.url)
            return
        }
        let dataTask = session.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
            if error == nil {
                guard let response = response as? HTTPURLResponse else {
                    onError(.noResponse)
                    return
                }
                if response.statusCode == 200 {
                    guard let data = data else {return}
                    do {
                        let buses = try JSONDecoder().decode([Bus].self, from: data)
                        onComplete(buses)
                    } catch {
                        print(error.localizedDescription)
                        onError(.invalidJSON)
                    }
                } else {
                    print("Algum status inválido pelo servidor!!")
                    onError(.responseStatusCode(code: response.statusCode))
                }
            } else {
                onError(.taskError(error: error!))
            }
        }
        dataTask.resume()
    }
    
    class func posicaoDosVeiculos(_ codigoLinha: String, onComplete: @escaping (BusPosition) -> Void, onError: @escaping (BusError) -> Void) {
        guard let url = URL(string: "\(basePath)/Posicao/Linha?codigoLinha=\(codigoLinha)") else {
            onError(.url)
            return
        }
        let dataTask = session.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
            if error == nil {
                guard let response = response as? HTTPURLResponse else {
                    onError(.noResponse)
                    return
                }
                if response.statusCode == 200 {
                    guard let data = data else {return}
                    do {
                        let busPositions = try JSONDecoder().decode(BusPosition.self, from: data)
                        onComplete(busPositions)
                    } catch {
                        print(error.localizedDescription)
                        onError(.invalidJSON)
                    }
                } else {
                    print("Algum status inválido pelo servidor!!")
                    onError(.responseStatusCode(code: response.statusCode))
                }
            } else {
                onError(.taskError(error: error!))
            }
        }
        dataTask.resume()
    }

}
