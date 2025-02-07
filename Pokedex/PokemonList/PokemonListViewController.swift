//
//  PokemonListViewController.swift
//  Pokedex
//
//  Created by Omar Torres on 2/7/25.
//

import UIKit
import Combine

final class PokemonListViewController: UITableViewController {
	private let pokemonService: PokemonServiceProtocol = PokemonService()
	private var pokemonEntries: [PokemonEntry] = []
	private var pokemonImages: [Int: UIImage] = [:]
	private var cancellables: Set<AnyCancellable> = []
	private let pokemonCell = "PokemonCell"
	private let searchBar = UISearchBar()
	private var filteredPokemonEntries: [PokemonEntry] = []
	private var isSearching = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupTableView()
		setupSearchBar()
		fetchPokedex()
	}
	
	private func setupTableView() {
		tableView.register(PokemonCell.self, forCellReuseIdentifier: pokemonCell)
	}

	private func setupSearchBar() {
		searchBar.delegate = self
		searchBar.placeholder = "Search Pokémon"
		searchBar.sizeToFit()
		searchBar.autocapitalizationType = .none
		tableView.tableHeaderView = searchBar
	}
	
	private func fetchPokedex() {
		pokemonService.fetchPokedex()
			.sink(receiveCompletion: { completion in
				if case .failure(let error) = completion {
					print("Error fetching pokedex: \(error)")
				}
			}, receiveValue: { [weak self] pokedex in
				self?.pokemonEntries = pokedex.pokemonEntries
				self?.fetchImages(for: pokedex.pokemonEntries)
			})
			.store(in: &cancellables)
	}

	private func fetchImages(for entries: [PokemonEntry]) {
		for pokemonEntry in entries {
			let pokemonId = pokemonEntry.entryNumber

			pokemonService.fetchPokemonImage(for: pokemonId)
				.receive(on: DispatchQueue.main)
				.sink(receiveCompletion: { completion in
					if case .failure(let error) = completion {
						print("Error fetching image for \(pokemonId): \(error)")
					}
				}, receiveValue: { [weak self] image in
					self?.pokemonImages[pokemonId] = image
					self?.tableView.reloadData()
				})
				.store(in: &cancellables)
		}
	}

	private func filterPokemons(searchText: String) {
		if searchText.isEmpty {
			isSearching = false
			filteredPokemonEntries = []
			tableView.reloadData()
			return
		}

		isSearching = true
		filteredPokemonEntries = pokemonEntries.filter { entry in
			entry.pokemonSpecies.name.localizedCaseInsensitiveContains(searchText)
		}
		tableView.reloadData()
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return isSearching ? filteredPokemonEntries.count : pokemonEntries.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: pokemonCell, for: indexPath) as! PokemonCell
		let pokemonEntry = isSearching ? filteredPokemonEntries[indexPath.row] : pokemonEntries[indexPath.row]
		let pokemonId = pokemonEntry.entryNumber
		cell.configure(with: pokemonEntry, image: pokemonImages[pokemonId])
		return cell
	}
}

extension PokemonListViewController: UISearchBarDelegate {
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		filterPokemons(searchText: searchText)
	}

	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		filterPokemons(searchText: "")
	}

	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		searchBar.endEditing(true)
	}
}
