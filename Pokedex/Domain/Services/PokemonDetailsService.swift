//
//  PokemonDetailsService.swift
//  Pokedex
//
//  Created by Omar Torres on 2/10/25.
//

import CoreData
import Combine

typealias FetchPokemonDetailsCompletion = (Result<PokemonDetails, FetchError>) -> Void

protocol PokemonDetailsServiceProtocol {
	func fetchPokemonDetails(for pokemonId: String) -> AnyPublisher<PokemonDetailsResponse, Error>
	func fetchLocalPokemonDetails(with id: String,
								  completion: @escaping FetchPokemonDetailsCompletion)
}

final class PokemonDetailsService: PokemonDetailsServiceProtocol {
	private let coreDataManager: CoreDataManager
	
	init(coreDataManager: CoreDataManager) {
		self.coreDataManager = coreDataManager
	}
	
	func fetchPokemonDetails(for pokemonId: String) -> AnyPublisher<PokemonDetailsResponse, Error> {
		guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon/\(pokemonId)") else {
			return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
		}
		
		return URLSession.shared.dataTaskPublisher(for: url)
			.map(\.data)
			.decode(type: PokemonDetailsResponse.self, decoder: JSONDecoder())
			.handleEvents(receiveOutput: { [weak self] response in
				self?.savePokemonDetailsToCoreData(response)
			})
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
	
	func fetchLocalPokemonDetails(with id: String,
								  completion: @escaping FetchPokemonDetailsCompletion) {
		let context = coreDataManager.container.viewContext
		let fetchRequest: NSFetchRequest<PokemonDetails> = PokemonDetails.fetchRequest()
		fetchRequest.predicate = NSPredicate(format: "id == %@", id)
		
		context.perform {
			do {
				if let pokemon = try context.fetch(fetchRequest).first {
					completion(.success(pokemon))
				}
			} catch {
				completion(.failure(.dataFetchError))
			}
		}
	}
}
