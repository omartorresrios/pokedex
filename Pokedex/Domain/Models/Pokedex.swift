//
//  Pokedex.swift
//  Pokedex
//
//  Created by Omar Torres on 2/7/25.
//

struct PokedexResponse: Codable {
	let pokemonEntries: [PokemonEntryResponse]

	enum CodingKeys: String, CodingKey {
		case pokemonEntries = "pokemon_entries"
	}
}

struct PokemonEntryResponse: Codable {
	let entryNumber: Int
	let pokemonSpecies: PokemonSpeciesResponse

	enum CodingKeys: String, CodingKey {
		case entryNumber = "entry_number"
		case pokemonSpecies = "pokemon_species"
	}
}

struct PokemonSpeciesResponse: Codable {
	let name: String
	let url: String
}
