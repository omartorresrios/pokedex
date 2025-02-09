//
//  PokemonDetailsViewModel.swift
//  Pokedex
//
//  Created by Omar Torres on 2/9/25.
//

import Combine

final class PokemonDetailsViewModel {
	private let pokemonService: PokemonServiceProtocol
	
	init(pokemonService: PokemonServiceProtocol) {
		self.pokemonService = pokemonService
	}
	
	func fetchPokemonDetails(for pokemonId: String) -> AnyPublisher<PokemonDetailsResponse, Error> {
		pokemonService.fetchPokemonDetails(for: pokemonId)
	}
	
	func fetchLocalPokemonDetails(with id: String, 
								  completion: @escaping FetchPokemonDetailsCompletion) {
		pokemonService.fetchLocalPokemonDetails(with: id, completion: completion)
	}
}
