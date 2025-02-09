//
//  SceneDelegate.swift
//  Pokedex
//
//  Created by Omar Torres on 2/7/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	var window: UIWindow?

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let windowScene = (scene as? UIWindowScene) else { return }
		window = UIWindow(windowScene: windowScene)
		let coreDataManager = CoreDataManager()
		let pokemonService = PokemonService(coreDataManager: coreDataManager)
		let viewModel = PokemonListViewModel(pokemonService: pokemonService)
		let pokemonListViewController = PokemonListViewController(viewModel: viewModel)
		let navigationController = UINavigationController(rootViewController: pokemonListViewController)
		window?.rootViewController = navigationController
		window?.makeKeyAndVisible()
	}
}
