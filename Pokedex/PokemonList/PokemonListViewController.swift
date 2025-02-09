//
//  PokemonListViewController.swift
//  Pokedex
//
//  Created by Omar Torres on 2/7/25.
//

import UIKit
import Combine

final class PokemonListViewController: UITableViewController {
	private let viewModel: PokemonListViewModel
	private var pokemonEntries: [PokemonEntry] = []
	private var pokemonImages: [Int: UIImage] = [:]
	private var cancellables: Set<AnyCancellable> = []
	private let pokemonCell = "PokemonCell"
	private let searchBar = UISearchBar()
	private var filteredPokemonEntries: [PokemonEntry] = []
	private var isSearching = false
	
	init(viewModel: PokemonListViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupTableView()
		setupSearchBar()
		fetchRemotePokedex()
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
	
	private func fetchRemotePokedex() {
		viewModel.fetchPokedex()
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { [weak self] completion in
				if case .failure(let error) = completion {
					print("Error fetching pokedex: \(error)")
					self?.fetchLocalPokedex()
				}
			}, receiveValue: { [weak self] pokedex in
				self?.fetchLocalPokedex()
			})
			.store(in: &cancellables)
	}
	
	private func fetchLocalPokedex() {
		viewModel.fetchLocalPokedex { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let entries):
				self.pokemonEntries = entries
				DispatchQueue.main.async {
					self.tableView.reloadData()
				}
			case .failure(let error):
				print("show some error message: \(error)")
			}
		}
	}

	private func filterPokemons(searchText: String) {
		if searchText.isEmpty {
			isSearching = false
			fetchLocalPokedex()
			return
		}

		isSearching = true
		viewModel.fetchSearchRequest(searchText) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let entries):
				filteredPokemonEntries = entries
				DispatchQueue.main.async {
					self.tableView.reloadData()
				}
			case .failure(let error):
				print("show some error message: \(error)")
			}
		}
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return isSearching ? filteredPokemonEntries.count : pokemonEntries.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: pokemonCell, for: indexPath) as! PokemonCell
		let pokemonEntry = isSearching ? filteredPokemonEntries[indexPath.row] : pokemonEntries[indexPath.row]
		cell.configure(with: pokemonEntry)
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let pokemonEntry = isSearching ? filteredPokemonEntries[indexPath.row] : pokemonEntries[indexPath.row]
		// TO-DO: Create a router to handle navigation and inject service component.
//		let pokemonId = pokemonEntry.entryNumber
//		let detailsViewController = PokemonDetailsViewController(pokemonId: pokemonId)
//		navigationController?.pushViewController(detailsViewController, animated: true)
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
