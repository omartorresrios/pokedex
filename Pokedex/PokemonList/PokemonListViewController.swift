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

	override func viewDidLoad() {
		super.viewDidLoad()
		setupTableView()
		fetchPokedex()
	}
	
	private func setupTableView() {
		tableView.register(PokemonCell.self, forCellReuseIdentifier: pokemonCell)
	}

	private func fetchPokedex() {
		pokemonService.fetchPokedex()
			.sink(receiveCompletion: { completion in
				if case .failure(let error) = completion {
					print("Error fetching pokedex: \(error)")
				}
			}, receiveValue: { [weak self] pokedex in
				self?.pokemonEntries = pokedex.pokemonEntries
				self?.fetchImages()
			})
			.store(in: &cancellables)
	}

	private func fetchImages() {
		for pokemonEntry in pokemonEntries {
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

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return pokemonEntries.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: pokemonCell, for: indexPath) as! PokemonCell
		let pokemonEntry = pokemonEntries[indexPath.row]
		let pokemonId = pokemonEntry.entryNumber
		cell.configure(with: pokemonEntry, image: pokemonImages[pokemonId])
		return cell
	}
}
