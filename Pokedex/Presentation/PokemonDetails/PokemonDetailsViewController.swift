//
//  PokemonDetailsViewController.swift
//  Pokedex
//
//  Created by Omar Torres on 2/7/25.
//

import UIKit
import Combine

final class PokemonDetailsViewController: UIViewController {
	private let viewModel: PokemonDetailsViewModel
	private let router: Router
	private let pokemonId: String
	private let pokemonImagePath: String?
	
	private let scrollView = UIScrollView()
	private let pokemonImageView = UIImageView()
	private let pokemonNameLabel = UILabel()
	private let pokemonTypeLabel = UILabel()
	private let pokemonStatsLabel = UILabel()
	private let pokemonMovesLabel = UILabel()
	
	private var typeStackView = UIStackView()
	private var statsStackView = UIStackView()
	private var movesStackView = UIStackView()
	
	private var cancellables: Set<AnyCancellable> = []
	
	init(viewModel: PokemonDetailsViewModel,
		 router: Router,
		 pokemonId: String,
		 pokemonImagePath: String?) {
		self.viewModel = viewModel
		self.router = router
		self.pokemonId = pokemonId
		self.pokemonImagePath = pokemonImagePath
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
		fetchRemotePokemonDetails()
	}
	
	private func setupUI() {
		view.backgroundColor = .white
		let contentView = UIView()
		contentView.translatesAutoresizingMaskIntoConstraints = false
		setupScrollView(with: contentView)
		translateAutoresizingMasks()
		setupContentView(contentView)
		setupStyles()
	}
	
	private func setupScrollView(with contentView: UIView) {
		view.addSubview(scrollView)
		NSLayoutConstraint.activate([
			scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
			scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
		])
		scrollView.addSubview(contentView)
	}
	
	private func translateAutoresizingMasks() {
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		pokemonImageView.translatesAutoresizingMaskIntoConstraints = false
		pokemonNameLabel.translatesAutoresizingMaskIntoConstraints = false
		pokemonTypeLabel.translatesAutoresizingMaskIntoConstraints = false
		pokemonStatsLabel.translatesAutoresizingMaskIntoConstraints = false
		pokemonMovesLabel.translatesAutoresizingMaskIntoConstraints = false
	}
	
	private func setupContentView(_ contentView: UIView) {
		NSLayoutConstraint.activate([
			contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
			contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
			contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
			contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
			contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
		])
		
		let imageAndNameStackView = vstack(views: [pokemonImageView, pokemonNameLabel],
										   spacing: 5,
										   alignment: .center)
		contentView.addSubview(imageAndNameStackView)
		
		let typeLabel = UILabel()
		typeLabel.font = .systemFont(ofSize: 20, weight: .semibold)
		typeLabel.text = "Type:"
		typeStackView = vstack(views: [typeLabel, pokemonTypeLabel], spacing: 5)
		
		let statsLabel = UILabel()
		statsLabel.font = .systemFont(ofSize: 20, weight: .semibold)
		statsLabel.text = "Stats:"
		statsStackView = vstack(views: [statsLabel, pokemonStatsLabel], spacing: 5)
		
		let movesLabel = UILabel()
		movesLabel.font = .systemFont(ofSize: 20, weight: .semibold)
		movesLabel.text = "Moves:"
		movesStackView = vstack(views: [movesLabel, pokemonMovesLabel], spacing: 5)
		
		let detailsStackView = vstack(views: [typeStackView, statsStackView, movesStackView], spacing: 15)
		contentView.addSubview(detailsStackView)
		
		NSLayoutConstraint.activate([
			imageAndNameStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
			imageAndNameStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
			imageAndNameStackView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.8),
			
			pokemonImageView.widthAnchor.constraint(equalToConstant: 150),
			pokemonImageView.heightAnchor.constraint(equalToConstant: 150),
			
			detailsStackView.topAnchor.constraint(equalTo: imageAndNameStackView.bottomAnchor, constant: 20),
			detailsStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
			detailsStackView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.8),
			detailsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
		])
	}
	
	private func setupStyles() {
		pokemonNameLabel.font = .systemFont(ofSize: 24, weight: .bold)
		pokemonNameLabel.numberOfLines = 0
		pokemonTypeLabel.font = .systemFont(ofSize: 18)
		pokemonTypeLabel.numberOfLines = 0
		pokemonStatsLabel.font = .systemFont(ofSize: 18)
		pokemonStatsLabel.numberOfLines = 0
		pokemonMovesLabel.font = .systemFont(ofSize: 18)
		pokemonMovesLabel.numberOfLines = 0
		pokemonImageView.contentMode = .scaleAspectFit
	}
	
	private func vstack(views: [UIView], 
						spacing: CGFloat,
						alignment: UIStackView.Alignment = .leading) -> UIStackView {
		let vstack = UIStackView()
		vstack.axis = .vertical
		vstack.spacing = spacing
		vstack.alignment = alignment
		vstack.translatesAutoresizingMaskIntoConstraints = false
		for view in views {
			view.translatesAutoresizingMaskIntoConstraints = false
			vstack.addArrangedSubview(view)
		}
		return vstack
	}
	
	private func fetchRemotePokemonDetails() {
		viewModel.fetchPokemonDetails(for: pokemonId)
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { [weak self] completion in
				switch completion {
					case .failure(let error):
						self?.fetchLocalPokemonDetails()
					case .finished:
						break
					}
			}, receiveValue: { [weak self] pokemonDetails in
				self?.fetchLocalPokemonDetails()
			})
			.store(in: &cancellables)
	}
	
	private func fetchLocalPokemonDetails() {
		viewModel.fetchLocalPokemonDetails(with: pokemonId) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let pokemon):
				self.configureUI(with: pokemon)
			case .failure(let error):
				hideStackViews()
				showAlert(title: "Ups!", message: error.localizedDescription)
			}
		}
	}
	
	private func configureUI(with pokemonDetails: PokemonDetails) {
		pokemonNameLabel.text = pokemonDetails.name
		if let fileName = pokemonImagePath,
		   let documentsDirectory = FileManager.default.urls(for: .documentDirectory,
															 in: .userDomainMask).first {
			let fileURL = documentsDirectory.appendingPathComponent(fileName)
			if FileManager.default.fileExists(atPath: fileURL.path),
			   let image = UIImage(contentsOfFile: fileURL.path) {
					pokemonImageView.image = image
			}
		}
		
		pokemonTypeLabel.text = viewModel.uniqueBulletedItems(from: pokemonDetails.types as? Set<PokemonType>,
															  keyPath: \PokemonType.type?.name)

		pokemonStatsLabel.text = viewModel.uniqueBulletedItems(from: pokemonDetails.stats as? Set<PokemonStat>,
															   keyPath: \PokemonStat.stat?.name) { stat in
			guard let name = stat.stat?.name else { return nil }
			return "\(name): \(stat.baseStat)"
		}

		pokemonMovesLabel.text = viewModel.uniqueBulletedItems(from: pokemonDetails.moves as? Set<PokemonMove>,
															   keyPath: \PokemonMove.move?.name)
	}
	
	private func hideStackViews() {
		typeStackView.isHidden = true
		statsStackView.isHidden = true
		movesStackView.isHidden = true
	}
	
	private func showAlert(title: String, message: String) {
		router.presentAlert(title: title,  message: message)
	}
}
