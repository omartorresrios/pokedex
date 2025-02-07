//
//  PokemonDetails.swift
//  Pokedex
//
//  Created by Omar Torres on 2/7/25.
//

struct PokemonDetails: Codable {
	let id: Int
	let name: String
	let types: [PokemonType]
	let stats: [PokemonStat]
	let sprites: PokemonSprites
	let moves: [PokemonMove]
}

struct PokemonType: Codable {
	let type: PokemonTypeDetail
	
	struct PokemonTypeDetail: Codable {
		let name: String
	}
}

struct PokemonStat: Codable {
	let stat: PokemonStatDetails
	let baseStat: Int
	
	enum CodingKeys: String, CodingKey {
		case stat
		case baseStat = "base_stat"
	}
}

struct PokemonStatDetails: Codable {
	let name: String
}

struct PokemonSprites: Codable {
	let frontDefault: String?
	
	enum CodingKeys: String, CodingKey {
		case frontDefault = "front_default"
	}
}

struct PokemonMove: Codable {
	let move: PokemonMoveDetails
}

struct PokemonMoveDetails: Codable {
	let name: String
}
