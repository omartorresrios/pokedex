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

	private func setupUI() {
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
	
	func configure(with pokemonEntry: PokemonEntry, image: UIImage?) {
		pokemonNameLabel.text = pokemonEntry.pokemonSpecies.name
		pokemonImageView.image = image
	}
}
