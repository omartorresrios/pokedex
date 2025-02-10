//
//  PokemonDetailsViewModel.swift
//  Pokedex
//
//  Created by Omar Torres on 2/9/25.
//

import Combine

final class PokemonDetailsViewModel {
	private let service: PokemonDetailsServiceProtocol
	
	init(service: PokemonDetailsServiceProtocol) {
		self.service = service
	}
	
	func fetchPokemonDetails(for pokemonId: String) -> AnyPublisher<PokemonDetailsResponse, Error> {
		service.fetchPokemonDetails(for: pokemonId)
	}
	
	func fetchLocalPokemonDetails(with id: String, 
								  completion: @escaping FetchPokemonDetailsCompletion) {
		service.fetchLocalPokemonDetails(with: id, completion: completion)
	}
	
	func uniqueBulletedItems<T>(from collection: Set<T>?,
										keyPath: KeyPath<T, String?>,
										transform: ((T) -> String?)? = nil) -> String {
		guard let collection = collection else {
			return "N/A"
		}
		
		let uniqueItems = Array(Set(collection.compactMap { item in
			if let transform = transform {
				return transform(item)
			} else {
				return item[keyPath: keyPath]
			}
		}))
		
		return uniqueItems.map { "• \(String($0))" }.joined(separator: "\n")
	}
}
