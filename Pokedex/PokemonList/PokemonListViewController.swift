//
//  PokemonListViewController.swift
//  Pokedex
//
//  Created by Omar Torres on 2/7/25.
//

import UIKit

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
