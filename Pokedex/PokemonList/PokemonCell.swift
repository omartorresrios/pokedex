//
//  PokemonCell.swift
//  Pokedex
//
//  Created by Omar Torres on 2/7/25.
//

import UIKit

final class PokemonCell: UITableViewCell {
	let pokemonNameLabel = UILabel()

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupUI()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func setupUI() {
		contentView.addSubview(pokemonNameLabel)
		pokemonNameLabel.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			pokemonNameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
			pokemonNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
		])
	}

	func configure(with pokemon: Pokemon) {
		pokemonNameLabel.text = pokemon.name
	}
}
