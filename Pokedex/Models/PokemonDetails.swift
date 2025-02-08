//
//  PokemonDetails.swift
//  Pokedex
//
//  Created by Omar Torres on 2/7/25.
//

struct PokemonDetailsResponse: Codable {
	let id: Int
	let name: String
	let types: [PokemonTypeResponse]
	let stats: [PokemonStatResponse]
	let sprites: PokemonSpritesResponse
	let moves: [PokemonMoveResponse]
}

struct PokemonTypeResponse: Codable {
	let type: PokemonTypeDetail
	
	struct PokemonTypeDetail: Codable {
		let name: String
	}
}

struct PokemonStatResponse: Codable {
	let stat: PokemonStatDetailsResponse
	let baseStat: Int
	
	enum CodingKeys: String, CodingKey {
		case stat
		case baseStat = "base_stat"
	}
}

struct PokemonStatDetailsResponse: Codable {
	let name: String
}

struct PokemonSpritesResponse: Codable {
	let frontDefault: String?
	
	enum CodingKeys: String, CodingKey {
		case frontDefault = "front_default"
	}
}

struct PokemonMoveResponse: Codable {
	let move: PokemonMoveDetailsResponse
}

struct PokemonMoveDetailsResponse: Codable {
	let name: String
}
