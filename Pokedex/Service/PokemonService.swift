//
//  PokemonService.swift
//  Pokedex
//
//  Created by Omar Torres on 2/7/25.
//

import Combine
import UIKit

protocol PokemonServiceProtocol {
	func fetchPokedex() -> AnyPublisher<Pokedex, Error>
	func fetchPokemonImage(for pokemonId: Int) -> AnyPublisher<UIImage, Error>
	func fetchPokemonDetails(for pokemonId: Int) -> AnyPublisher<PokemonDetails, Error>
}

class PokemonService: PokemonServiceProtocol {
	func fetchPokedex() -> AnyPublisher<Pokedex, Error> {
		guard let url = URL(string: "https://pokeapi.co/api/v2/pokedex/1/") else {
			return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
		}
		
		return URLSession.shared.dataTaskPublisher(for: url)
			.map(\.data)
			.decode(type: Pokedex.self, decoder: JSONDecoder())
			.eraseToAnyPublisher()
	}

	func fetchPokemonImage(for pokemonId: Int) -> AnyPublisher<UIImage, Error> {
		let imageUrl = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(pokemonId).png"
		
		guard let url = URL(string: imageUrl) else {
			return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
		}
		
		return URLSession.shared.dataTaskPublisher(for: url)
			.map(\.data)
			.tryMap { data in
				guard let image = UIImage(data: data) else {
					throw URLError(.badServerResponse)
				}
				return image
			}
			.eraseToAnyPublisher()
	}
	
	func fetchPokemonDetails(for pokemonId: Int) -> AnyPublisher<PokemonDetails, Error> {
		guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon/\(pokemonId)") else {
			return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
		}
		
		return URLSession.shared.dataTaskPublisher(for: url)
			.map(\.data)
			.decode(type: PokemonDetails.self, decoder: JSONDecoder())
			.eraseToAnyPublisher()
	}
}
