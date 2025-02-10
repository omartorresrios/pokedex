//
//  Helpers.swift
//  Pokedex
//
//  Created by Omar Torres on 2/9/25.
//

import Foundation

extension PokemonSpecies {
	func update(from response: PokemonSpeciesResponse) {
		self.name = response.name
		self.url = response.url
	}
}

enum FetchError: Error, LocalizedError {
	case dataFetchError
	
	var errorDescription: String? {
		switch self {
		case .dataFetchError:
			return "Failed to fetch data."
		}
	}
}
