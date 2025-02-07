//
//  PokemonService.swift
//  Pokedex
//
//  Created by Omar Torres on 2/7/25.
//

import Foundation

final class PokemonService {
	
	func fetchPokemons(completion: @escaping ([Pokemon]) -> Void) {
		guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=151") else { return }
		
		URLSession.shared.dataTask(with: url) { data, response, error in
			if let error = error {
				print("Error fetching pokemons: \(error)")
				return
			}
			
			guard let data = data else { return }
			
			do {
				let pokemons = try JSONDecoder().decode(PokemonList.self, from: data)
				completion(pokemons.results)
			} catch {
				print("Error parsing pokemons: \(error)")
			}
		}.resume()
	}
}
