//
//  PokemonCell.swift
//  Pokedex
//
//  Created by Omar Torres on 2/7/25.
//

import UIKit

final class PokemonCell: UITableViewCell {
	private let pokemonImageView = UIImageView()
	private let pokemonNameLabel = UILabel()

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupUI()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func setupUI() {
		contentView.addSubview(pokemonImageView)
		contentView.addSubview(pokemonNameLabel)

		pokemonImageView.translatesAutoresizingMaskIntoConstraints = false
		pokemonNameLabel.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			pokemonImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
			pokemonImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
			pokemonImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
			pokemonImageView.widthAnchor.constraint(equalToConstant: 50),
			pokemonImageView.heightAnchor.constraint(equalToConstant: 50),

			pokemonNameLabel.leadingAnchor.constraint(equalTo: pokemonImageView.trailingAnchor, constant: 10),
			pokemonNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
		])
	}
	
	func configure(with pokemonEntry: PokemonEntry) {
		pokemonNameLabel.text = pokemonEntry.pokemonSpecies.name
		
		let pokemonId = pokemonEntry.entryNumber
		let imageUrl = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(pokemonId).png"
		
		guard let url = URL(string: imageUrl) else { return }
		
		URLSession.shared.dataTask(with: url) { data, response, error in
			if let error = error {
				print("Error fetching image: \(error)")
				return
			}
			
			guard let data = data else { return }
			
			DispatchQueue.main.async { [weak self] in
				self?.pokemonImageView.image = UIImage(data: data)
			}
		}.resume()
	}
}
