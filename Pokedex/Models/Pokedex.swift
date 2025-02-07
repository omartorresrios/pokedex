//
//  Pokedex.swift
//  Pokedex
//
//  Created by Omar Torres on 2/7/25.
//

struct Pokedex: Codable {
	let pokemonEntries: [PokemonEntry]

	enum CodingKeys: String, CodingKey {
		case pokemonEntries = "pokemon_entries"
	}
}
