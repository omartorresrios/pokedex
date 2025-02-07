//
//  PokemonListViewController.swift
//  Pokedex
//
//  Created by Omar Torres on 2/7/25.
//

import UIKit

struct PokemonList: Codable {
	let count: Int
	let next: String?
	let previous: String?
	let results: [Pokemon]
}

struct Pokemon: Codable {
	let name: String
	let url: String
}

final class PokemonListViewController: UITableViewController {
	let pokemonService = PokemonService()
	var pokemons: [Pokemon] = []

	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.register(PokemonCell.self, forCellReuseIdentifier: "PokemonCell")
		fetchPokemons()
	}

	func fetchPokemons() {
		pokemonService.fetchPokemons { [weak self] results in
			self?.pokemons = results
			DispatchQueue.main.async {
				self?.tableView.reloadData()
			}
		}
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return pokemons.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "PokemonCell", for: indexPath) as! PokemonCell
		
		let pokemon = pokemons[indexPath.row]
		cell.configure(with: pokemon)
		
		return cell
	}
}

final class PokemonService {
	
	func fetchPokemons(completion: @escaping ([Pokemon]) -> Void) {
		guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=151") else { return }
		
		URLSession.shared.dataTask(with: url) { data, response, error in
			if let error = error {
				print("Error fetching pokemons: \(error)")
				return
			}
			
			guard let data = data else { return }
			
			do {
				let pokemons = try JSONDecoder().decode(PokemonList.self, from: data)
				completion(pokemons.results)
			} catch {
				print("Error parsing pokemons: \(error)")
			}
		}.resume()
	}
}
