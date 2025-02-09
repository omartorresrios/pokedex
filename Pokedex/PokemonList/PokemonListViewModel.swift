//
//  PokemonListViewModel.swift
//  Pokedex
//
//  Created by Omar Torres on 2/9/25.
//

import Foundation
import Combine

final class PokemonListViewModel: NSObject {
	private let pokemonService: PokemonServiceProtocol
	
	init(pokemonService: PokemonServiceProtocol) {
		self.pokemonService = pokemonService
	}
	
	func fetchPokedex() -> AnyPublisher<PokedexResponse, Error> {
		pokemonService.fetchPokedex()
	}
	
	func fetchLocalPokedex(completion: @escaping fetchPokedexCompletion) {
		pokemonService.fetchLocalPokedex(completion: completion)
	}
	
	func fetchSearchRequest(_ searchText: String,
							completion: @escaping FetchSearhCompletion) {
		pokemonService.fetchSearchRequest(searchText, completion: completion)
	}
}
