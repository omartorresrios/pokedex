//
//  Router.swift
//  Pokedex
//
//  Created by Omar Torres on 2/9/25.
//

import UIKit

protocol Router {
	func showPostDetailsView(pokemonId: String, pokemonImagePath: String?)
}

final class NavigationControllerRouter: Router {
	private let navigationController: UINavigationController
	private let pokemonService: PokemonService
	
	init(navigationController: UINavigationController, pokemonService: PokemonService) {
		self.navigationController = navigationController
		self.pokemonService = pokemonService
	}
	
	func showPostDetailsView(pokemonId: String, pokemonImagePath: String?) {
		let viewModel = PokemonDetailsViewModel(pokemonService: pokemonService)
		let pokemonDetailsViewController = PokemonDetailsViewController(viewModel: viewModel, 
																		pokemonId: pokemonId,
																		pokemonImagePath: pokemonImagePath)
		navigationController.pushViewController(pokemonDetailsViewController, animated: true)
	}
}
