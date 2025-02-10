//
//  Router.swift
//  Pokedex
//
//  Created by Omar Torres on 2/9/25.
//

import UIKit

protocol Router {
	func showPostDetailsView(pokemonId: String, pokemonImagePath: String?)
	func presentAlert(title: String, message: String)
}

final class NavigationControllerRouter: Router {
	private let navigationController: UINavigationController
	private let pokemonDetailsService: PokemonDetailsService
	
	init(navigationController: UINavigationController,
		 pokemonDetailsService: PokemonDetailsService) {
		self.navigationController = navigationController
		self.pokemonDetailsService = pokemonDetailsService
	}
	
	func showPostDetailsView(pokemonId: String, pokemonImagePath: String?) {
		let viewModel = PokemonDetailsViewModel(service: pokemonDetailsService)
		let pokemonDetailsViewController = PokemonDetailsViewController(viewModel: viewModel, 
																		router: self,
																		pokemonId: pokemonId,
																		pokemonImagePath: pokemonImagePath)
		navigationController.pushViewController(pokemonDetailsViewController, animated: true)
	}
	
	func presentAlert(title: String, message: String) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		navigationController.present(alert, animated: true, completion: nil)
	}
}
