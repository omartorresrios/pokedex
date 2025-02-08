//
//  PokemonService.swift
//  Pokedex
//
//  Created by Omar Torres on 2/7/25.
//

import Combine
import UIKit
import CoreData

protocol PokemonServiceProtocol {
	func fetchPokedex() -> AnyPublisher<Pokedex, Error>
	func fetchPokemonImage(for pokemonId: Int) -> AnyPublisher<UIImage, Error>
	func fetchPokemonDetails(for pokemonId: Int) -> AnyPublisher<PokemonDetails, Error>
}

class PokemonService: PokemonServiceProtocol {
	private let coreDataManager: CoreDataManager
	
	init(coreDataManager: CoreDataManager) {
		self.coreDataManager = coreDataManager
	}
	
	func fetchPokedex() -> AnyPublisher<Pokedex, Error> {
		guard let url = URL(string: "https://pokeapi.co/api/v2/pokedex/1/") else {
			return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
		}
		
		return URLSession.shared.dataTaskPublisher(for: url)
			.map(\.data)
			.decode(type: Pokedex.self, decoder: JSONDecoder())
			.eraseToAnyPublisher()
	}

	func fetchPokemonImage(for pokemonId: Int) -> AnyPublisher<UIImage, Error> {
		let imageUrl = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(pokemonId).png"
		
		guard let url = URL(string: imageUrl) else {
			return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
		}
		
		return URLSession.shared.dataTaskPublisher(for: url)
			.map(\.data)
			.tryMap { data in
				guard let image = UIImage(data: data) else {
					throw URLError(.badServerResponse)
				}
				return image
			}
			.eraseToAnyPublisher()
	}
	
	func fetchPokemonDetails(for pokemonId: Int) -> AnyPublisher<PokemonDetails, Error> {
		guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon/\(pokemonId)") else {
			return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
		}
		
		return URLSession.shared.dataTaskPublisher(for: url)
			.map(\.data)
			.decode(type: PokemonDetailsResponse.self, decoder: JSONDecoder())
			.handleEvents(receiveOutput: { [weak self] response in
				self?.savePokemonDetailsToCoreData(response)
			})
			.flatMap { [weak self] response -> AnyPublisher<PokemonDetails, Error> in
				guard let self = self else {
					return Fail(error: URLError(.cannotFindHost)).eraseToAnyPublisher()
				}
				
				return self.fetchPokemonFromCoreData(with: response.id)
			}
			.eraseToAnyPublisher()
	}
	
	private func fetchPokemonFromCoreData(with id: Int) -> AnyPublisher<PokemonDetails, Error> {
		Future { [weak self] promise in
			guard let self = self else {
				return promise(.failure(NSError(domain: "CoreDataError",
												code: NSValidationMissingMandatoryPropertyError,
												userInfo: [NSLocalizedDescriptionKey: "Core Data manager instance is unavailable."])))
			}
			let context = self.coreDataManager.container.viewContext
			let fetchRequest: NSFetchRequest<PokemonDetails> = PokemonDetails.fetchRequest()
			fetchRequest.predicate = NSPredicate(format: "id == %d", id)

			do {
				if let pokemon = try context.fetch(fetchRequest).first {
					promise(.success(pokemon))
				} else {
					promise(.failure(NSError(domain: "CoreDataError", 
											 code: 404,
											 userInfo: [NSLocalizedDescriptionKey: "Pokemon not found"])))
				}
			} catch {
				promise(.failure(error))
			}
		}
		.eraseToAnyPublisher()
	}

	private func savePokemonDetailsToCoreData(_ response: PokemonDetailsResponse) {
		let context = coreDataManager.container.viewContext
		
		let fetchRequest: NSFetchRequest<PokemonDetails> = PokemonDetails.fetchRequest()
			fetchRequest.predicate = NSPredicate(format: "id == %d", response.id)
		
		do {
			let existingPokemon = try context.fetch(fetchRequest).first ?? PokemonDetails(context: context)
			existingPokemon.id = Int32(response.id)
			existingPokemon.name = response.name

			if let frontDefault = response.sprites.frontDefault {
				let sprites = PokemonSprites(context: context)
				sprites.frontDefault = frontDefault
				existingPokemon.sprites = sprites
			}
			
			for typeResponse in response.types {
				let typeEntity = PokemonType(context: context)
				let pokemonTypeDetail = PokemonTypeDetail(context: context)
				pokemonTypeDetail.name = typeResponse.type.name
				typeEntity.type = pokemonTypeDetail
				existingPokemon.addToTypes(typeEntity)
			}
			
			for statsResponse in response.stats {
				let statsEntity = PokemonStat(context: context)
				statsEntity.baseStat = Int32(statsResponse.baseStat)
				let statDetailsEntity = PokemonStatDetails(context: context)
				statDetailsEntity.name = statsResponse.stat.name
				statsEntity.stat = statDetailsEntity
				existingPokemon.addToStats(statsEntity)
			}
			
			for movesResponse in response.moves {
				let movesEntity = PokemonMove(context: context)
				let movesDetailsEntity = PokemonMoveDetails(context: context)
				movesDetailsEntity.name = movesResponse.move.name
				movesEntity.move = movesDetailsEntity
				existingPokemon.addToMoves(movesEntity)
			}
			try context.save()
		} catch {
			print("Error saving Pokemon details: \(error)")
		}
	}
}
