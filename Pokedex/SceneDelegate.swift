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
		let navigationController = UINavigationController()
		let router = NavigationControllerRouter(navigationController: navigationController,
												pokemonService: pokemonService)
		let pokemonListViewController = PokemonListViewController(viewModel: viewModel, router: router)
		navigationController.pushViewController(pokemonListViewController, animated: true)
		window?.rootViewController = navigationController
		window?.makeKeyAndVisible()
	}
}
