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

struct PokemonEntry: Codable {
	let entryNumber: Int
	let pokemonSpecies: PokemonSpecies

	enum CodingKeys: String, CodingKey {
		case entryNumber = "entry_number"
		case pokemonSpecies = "pokemon_species"
	}
}

struct PokemonSpecies: Codable {
	let name: String
	let url: String
}
