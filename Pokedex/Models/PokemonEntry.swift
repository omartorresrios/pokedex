//
//  PokemonEntry.swift
//  Pokedex
//
//  Created by Omar Torres on 2/7/25.
//

struct PokemonEntry: Codable {
	let entryNumber: Int
	let pokemonSpecies: PokemonSpecies

	enum CodingKeys: String, CodingKey {
		case entryNumber = "entry_number"
		case pokemonSpecies = "pokemon_species"
	}
}
