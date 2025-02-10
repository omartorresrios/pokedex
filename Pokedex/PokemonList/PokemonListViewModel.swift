//
//  PokemonListViewModel.swift
//  Pokedex
//
//  Created by Omar Torres on 2/9/25.
//

import Foundation
import Combine

final class PokemonListViewModel: NSObject {
	private let service: PokemonListServiceProtocol
	
	init(service: PokemonListServiceProtocol) {
		self.service = service
	}
	
	func fetchPokedex() -> AnyPublisher<PokedexResponse, Error> {
		service.fetchPokedex()
	}
	
	func fetchLocalPokedex(completion: @escaping fetchPokedexCompletion) {
		service.fetchLocalPokedex(completion: completion)
	}
	
	func fetchSearchRequest(_ searchText: String,
							completion: @escaping FetchSearhCompletion) {
		service.fetchSearchRequest(searchText, completion: completion)
	}
}
