//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Marko Jovanov on 25.8.21.
//  Copyright © 2019 The App Brewery. All rights reserved.
//
import Foundation

//MARK: - Protocol CoinManagerDelegate
protocol CoinManagerDelegate {
    func didUpdatePrice(price: String, currency: String)
    func didFailWithError(error: Error)
}

//MARK: - CoinManager
struct CoinManager {
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC/"
    let apiKey = "97F83F64-7241-4D55-8070-9753C4115D47"
    var delegate: CoinManagerDelegate?
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    func  getCoinPrice(for currency: String) {
        let finalUrl = "\(baseURL)\(currency)?apikey=\(apiKey)"
        if let url = URL(string: finalUrl) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let currentBitcoin = self.parseJson(safeData) {
                        let priceString = String(format: "%.2f", currentBitcoin)
                        self.delegate?.didUpdatePrice(price: priceString, currency: currency)
                    }
                }
            }
            task.resume()
        }
    }
    func parseJson(_ data: Data) -> Double? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CoinModel.self, from: data)
            let lastPrice = decodedData.rate
            return lastPrice
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
        
    }

    
}
