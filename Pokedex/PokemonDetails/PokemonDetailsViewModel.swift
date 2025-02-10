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
}
