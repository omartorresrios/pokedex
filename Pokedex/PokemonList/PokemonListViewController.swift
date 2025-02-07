//
//  PokemonListViewController.swift
//  Pokedex
//
//  Created by Omar Torres on 2/7/25.
//

import UIKit

final class PokemonListViewController: UITableViewController {
	let pokemonService = PokemonService()
	var pokemonEntries: [PokemonEntry] = []

	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.register(PokemonCell.self, forCellReuseIdentifier: "PokemonCell")
		fetchPokedex()
	}

	func fetchPokedex() {
		pokemonService.fetchPokedex { [weak self] pokedex in
			if let pokedex = pokedex {
				self?.pokemonEntries = pokedex.pokemonEntries
				DispatchQueue.main.async {
					self?.tableView.reloadData()
				}
			}
		}
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return pokemonEntries.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "PokemonCell", for: indexPath) as! PokemonCell
		let pokemonEntry = pokemonEntries[indexPath.row]
		 cell.configure(with: pokemonEntry)
		return cell
	}
}
