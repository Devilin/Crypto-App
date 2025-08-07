//
//  CoinDetailDataService.swift
//  Cryptocurrency
//
//  Created by Deimante Valunaite on 18/11/2023.
//

import Foundation

// Add this at the top of the file (after imports, before the class)
private struct HistoricalDataResponse: Codable {
    let prices: [[Double]]  // [[timestamp, price], ...]
}

class CoinDetailDataService {
    
    let coin: Coin
    
    init(coin: Coin) {
        self.coin = coin
    }
    
    func getCoinDetails() async throws -> [CoinDetailModel] {
        let urlString = "https://api.coingecko.com/api/v3/coins/\(coin.id)?localization=true&tickers=false&market_data=false&community_data=false&developer_data=false&sparkline=true"
        guard let url = URL(string: urlString) else { return [] }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let details = try JSONDecoder().decode([CoinDetailModel].self, from: data)
            return details
        } catch {
            print("DEBUG: Error \(error.localizedDescription)")
            return []
        }
    }
}

extension CoinDetailDataService {
    func getCoinDetailsWithResult(completion: @escaping(Result<[CoinDetailModel], CoinAPIError>) -> Void) {
        let urlString = "https://api.coingecko.com/api/v3/coins/\(coin.id)?localization=true&tickers=false&market_data=false&community_data=false&developer_data=false&sparkline=true"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(.unknownedError(error: error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.requestFailed(description: "Request failed")))
                return
            }
            
            guard httpResponse.statusCode == 200 else {
                completion(.failure(.invalidStatusCode(statusCode: httpResponse.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.invalidData))
                return
            }
            
            do {
                let details = try JSONDecoder().decode([CoinDetailModel].self, from: data)
                completion(.success(details))
            } catch {
                print("DEBUG: Failed to decode with error \(error)")
                completion(.failure(.jsonParsingFailure))
            }
        }.resume()
    }

    func fetchHistoricalData(days: Int) async throws -> [Double] {
        let urlString = "https://api.coingecko.com/api/v3/coins/\(coin.id)/market_chart?vs_currency=usd&days=\(days)"
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }

        let (data, response) = try await URLSession.shared.data(from: url)
        // Optional: check status code for better errors
        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
            let body = String(data: data, encoding: .utf8) ?? "<non-utf8>"
            print("DEBUG: HTTP \(http.statusCode). Body: \(body.prefix(500))")
            throw URLError(.badServerResponse)
        }

        do {
            // First, try Codable
            let result = try JSONDecoder().decode(HistoricalDataResponse.self, from: data)
            return result.prices.compactMap { $0.count > 1 ? $0[1] : nil }
        } catch {
            // Fallback: parse with JSONSerialization and be lenient
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let prices = json["prices"] as? [[Any]] {
                let values: [Double] = prices.compactMap { arr in
                    guard arr.count > 1 else { return nil }
                    if let d = arr[1] as? Double { return d }
                    if let n = arr[1] as? NSNumber { return n.doubleValue }
                    if let s = arr[1] as? String { return Double(s) }
                    return nil
                }
                return values
            }

            let body = String(data: data, encoding: .utf8) ?? "<non-utf8>"
            print("DEBUG: Decode failed: \(error). Body: \(body.prefix(500))")
            throw error
        }
    }

}
