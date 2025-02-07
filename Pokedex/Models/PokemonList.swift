//
//  PokemonList.swift
//  Pokedex
//
//  Created by Omar Torres on 2/7/25.
//

struct PokemonList: Codable {
	let count: Int
	let next: String?
	let previous: String?
	let results: [Pokemon]
}
