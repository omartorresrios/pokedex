//
//  PokemonService.swift
//  Pokedex
//
//  Created by Omar Torres on 2/7/25.
//

import Foundation

final class PokemonService {
	
	func fetchPokedex(completion: @escaping (Pokedex?) -> Void) {
		guard let url = URL(string: "https://pokeapi.co/api/v2/pokedex/1/") else { return }

		URLSession.shared.dataTask(with: url) { data, response, error in
			if let error = error {
				print("Error fetching pokedex: \(error)")
				completion(nil)
				return
			}

			guard let data = data else {
				completion(nil)
				return
			}

			do {
				let pokedex = try JSONDecoder().decode(Pokedex.self, from: data)
				completion(pokedex)
			} catch {
				print("Error parsing pokedex: \(error)")
				completion(nil)
			}
		}.resume()
	}
}
