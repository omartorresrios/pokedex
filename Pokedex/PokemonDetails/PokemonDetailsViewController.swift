//
//  PokemonDetailsViewController.swift
//  Pokedex
//
//  Created by Omar Torres on 2/7/25.
//

import UIKit
import Combine

final class PokemonDetailsViewController: UIViewController {
	private let pokemonService: PokemonServiceProtocol
	private let pokemonId: Int
	private var cancellables: Set<AnyCancellable> = []
	
	private let pokemonImageView = UIImageView()
	private let pokemonNameLabel = UILabel()
	private let pokemonTypeLabel = UILabel()
	private let pokemonStatsLabel = UILabel()
	private let pokemonMovesLabel = UILabel()
	
	init(pokemonService: PokemonServiceProtocol, pokemonId: Int) {
		self.pokemonService = pokemonService
		self.pokemonId = pokemonId
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
		fetchPokemonDetails()
	}
	
	private func setupUI() {
		view.backgroundColor = .white
		view.addSubview(pokemonImageView)
		view.addSubview(pokemonNameLabel)
		view.addSubview(pokemonTypeLabel)
		view.addSubview(pokemonStatsLabel)
		view.addSubview(pokemonMovesLabel)
		
		pokemonImageView.translatesAutoresizingMaskIntoConstraints = false
		pokemonNameLabel.translatesAutoresizingMaskIntoConstraints = false
		pokemonTypeLabel.translatesAutoresizingMaskIntoConstraints = false
		pokemonStatsLabel.translatesAutoresizingMaskIntoConstraints = false
		pokemonMovesLabel.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			pokemonImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
			pokemonImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			pokemonImageView.widthAnchor.constraint(equalToConstant: 100),
			pokemonImageView.heightAnchor.constraint(equalToConstant: 100),
			
			pokemonNameLabel.topAnchor.constraint(equalTo: pokemonImageView.bottomAnchor, constant: 20),
			pokemonNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			pokemonNameLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
			
			pokemonTypeLabel.topAnchor.constraint(equalTo: pokemonNameLabel.bottomAnchor, constant: 10),
			pokemonTypeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			pokemonTypeLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
			
			pokemonStatsLabel.topAnchor.constraint(equalTo: pokemonTypeLabel.bottomAnchor, constant: 10),
			pokemonStatsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			pokemonStatsLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
			
			pokemonMovesLabel.topAnchor.constraint(equalTo: pokemonStatsLabel.bottomAnchor, constant: 10),
			pokemonMovesLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			pokemonMovesLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
			pokemonMovesLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
		])
		
		pokemonNameLabel.font = .systemFont(ofSize: 24, weight: .bold)
		pokemonTypeLabel.font = .systemFont(ofSize: 18)
		pokemonStatsLabel.font = .systemFont(ofSize: 18)
		pokemonMovesLabel.font = .systemFont(ofSize: 18)
		
		pokemonImageView.contentMode = .scaleAspectFit
	}
	
	private func fetchPokemonDetails() {
		pokemonService.fetchPokemonDetails(for: pokemonId)
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { completion in
				if case .failure(let error) = completion {
					print("Error fetching pokemon details: \(error)")
				}
			}, receiveValue: { [weak self] pokemonDetails in
				self?.configureUI(with: pokemonDetails)
			})
			.store(in: &cancellables)
	}
	
	private func configureUI(with pokemonDetails: PokemonDetails) {
		pokemonNameLabel.text = pokemonDetails.name
		if let types = pokemonDetails.types as? Set<PokemonType> {
			let typeNames = types.compactMap { $0.type?.name }
			pokemonTypeLabel.text = "Types: \(typeNames.joined(separator: ", "))"
		} else {
			pokemonTypeLabel.text = "Types: N/A"
		}
		
		if let stats = pokemonDetails.stats as? Set<PokemonStat> {
			let statDescriptions = stats.compactMap { stat -> String? in
				guard let name = stat.stat?.name else { return nil }
				return "\(name): \(stat.baseStat)"
			}
			pokemonStatsLabel.text = "Stats: \(statDescriptions.joined(separator: ", "))"
		} else {
			pokemonStatsLabel.text = "Stats: N/A"
		}

		if let moves = pokemonDetails.moves as? Set<PokemonMove> {
			let moveNames = moves.compactMap { $0.move?.name }
			pokemonMovesLabel.text = "Moves: \(moveNames.joined(separator: ", "))"
		} else {
			pokemonMovesLabel.text = "Moves: N/A"
		}
	}
}
