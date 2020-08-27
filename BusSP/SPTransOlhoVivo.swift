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
            print("autenticar")
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
            print("buscarLinhas")
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
    
    class func posicaoDosVeiculos(_ codigoLinha: Int, onComplete: @escaping (BusPosition) -> Void, onError: @escaping (BusError) -> Void) {
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

//class SPTransOlhoVivo {
//
//    enum BusLoadResponse: Error {
//        case success(bus: [Bus])
//        case error(description: String)
//    }
//
//    enum BusResPosition: Error {
//        case success(busPos: BusPosition)
//        case error(description: String)
//    }
//
//    enum RouteLineResponse: Error {
//        case success(routeLine: [RouteLine])
//        case error(description: String)
//    }
//
//    let urlBase = "http://api.olhovivo.sptrans.com.br/v2.1"
//    let token = "722f35c2069770f36029f51cbe9165e944539083572e467b5c22d9fa38124625"
//
//    func autenticar(completion: @escaping (Bool?, Error?) -> Void) {
//        if let url = URL(string: "\(urlBase)/Login/Autenticar?token=\(token)") {
//            let request = NSMutableURLRequest(url: url)
//            request.httpMethod = "POST"
//            let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
//                if error == nil {
//                    completion(true, nil)
//                } else {
//                    completion(false, nil)
//                }
//            }
//            task.resume()
//        } else {
//            completion(false, nil)
//            print("Error 2")
//        }
//    }
//
//    func buscarDetalheLinha(termosBusca: String, completion: @escaping (BusLoadResponse) -> Void) {
//        let baseURL: String = "\(urlBase)/Linha/Buscar?termosBusca=\(termosBusca)"
//        guard let url = URL(string: baseURL) else {
//            completion(BusLoadResponse.error(description: "URL não iniciado!"))
//            return
//        }
//
//        let dataTask = URLSession.shared.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
//            if error == nil {
//                guard let response = response as? HTTPURLResponse else {return}
//                if response.statusCode == 200 {
//                    guard let data = data else {return}
//                    do {
//                        let buses = try JSONDecoder().decode([Bus].self, from: data)
//                        completion(BusLoadResponse.success(bus: buses))
//                    } catch {
//                        print(error.localizedDescription)
//                    }
//                } else {
//                    print("Algum status inválido pelo servidor!!")
//                }
//            } else {
//                print(error!)
//            }
//        }
//        dataTask.resume()
//    }
//
//    func posicaoVeiculosPorLinhas(_ codigoLinha: Int, completion: @escaping (BusResPosition) -> Void) {
//        let baseURL: String = "\(urlBase)/Posicao/Linha?codigoLinha=\(codigoLinha)"
//        guard let url = URL(string: baseURL) else {
//            completion(BusResPosition.error(description: "URL não iniciado!"))
//            return
//        }
//
//        let dataTask = URLSession.shared.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
//            if error == nil {
//                guard let response = response as? HTTPURLResponse else {return}
//                if response.statusCode == 200 {
//                    guard let data = data else {return}
//                    do {
//                        let busPos = try JSONDecoder().decode(BusPosition.self, from: data)
//                        completion(BusResPosition.success(busPos: busPos))
//                    } catch {
//                        debugPrint(error)
//                    }
//                } else {
//                    print("Algum status inválido pelo servidor!!")
//                }
//            } else {
//                print(error!)
//            }
//        }
//        dataTask.resume()
//    }
//
//}
