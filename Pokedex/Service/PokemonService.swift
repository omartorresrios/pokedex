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
	var viewContext: NSManagedObjectContext { get }
	func fetchPokedex() -> AnyPublisher<PokedexResponse, Error>
	func fetchPokemonDetails(for pokemonId: Int) -> AnyPublisher<PokemonDetails, Error>
}

class PokemonService: PokemonServiceProtocol {
	private let coreDataManager: CoreDataManager
	private var cancellables: Set<AnyCancellable> = []
	
	init(coreDataManager: CoreDataManager) {
		self.coreDataManager = coreDataManager
	}
	
	var viewContext: NSManagedObjectContext {
		coreDataManager.container.viewContext
	}
	
	func fetchPokedex() -> AnyPublisher<PokedexResponse, Error> {
		guard let url = URL(string: "https://pokeapi.co/api/v2/pokedex/1/") else {
			return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
		}
		
		return URLSession.shared.dataTaskPublisher(for: url)
			.map(\.data)
			.decode(type: PokedexResponse.self, decoder: JSONDecoder())
			.receive(on: DispatchQueue.main)
			.flatMap { [weak self] response -> AnyPublisher<PokedexResponse, Error> in
				guard let self = self else {
					return Fail(error: URLError(.unknown)).eraseToAnyPublisher()
				}
				
				return self.savePokedexWithImages(entries: response.pokemonEntries)
					.map { _ in response }
					.eraseToAnyPublisher()
			}
			.eraseToAnyPublisher()
	}
	
	private func savePokedexWithImages(entries: [PokemonEntryResponse]) -> AnyPublisher<Void, Error> {
		return Deferred {
			Future { [weak self] promise in
				guard let self = self else {
					promise(.failure(URLError(.unknown)))
					return
				}
				
				let context = self.coreDataManager.container.viewContext
				
				context.performAndWait {
					let fetchRequest: NSFetchRequest<PokemonEntry> = PokemonEntry.fetchRequest()
					
					do {
						let existingEntries = try context.fetch(fetchRequest)
						let existingDict = Dictionary(uniqueKeysWithValues: existingEntries.map {
							(Int($0.entryNumber), $0)
						})
						
						let imagePublishers = entries.map { entry -> AnyPublisher<(PokemonEntryResponse, UIImage?), Error> in
							return self.fetchPokemonImage(for: entry.entryNumber)
								.map { image in (entry, image) }
								.catch { error -> AnyPublisher<(PokemonEntryResponse, UIImage?), Error> in
									return Just((entry, nil))
										.setFailureType(to: Error.self)
										.eraseToAnyPublisher()
								}
								.eraseToAnyPublisher()
						}
						
						Publishers.MergeMany(imagePublishers)
							.collect()
							.sink(
								receiveCompletion: { completion in
									if case .failure(let error) = completion {
										promise(.failure(error))
									}
								},
								receiveValue: { results in
									context.performAndWait {
										for (entry, image) in results {
											if let existingEntry = existingDict[entry.entryNumber] {
												if existingEntry.pokemonSpecies == nil {
													let species = PokemonSpecies(context: context)
													species.update(from: entry.pokemonSpecies)
													existingEntry.pokemonSpecies = species
												} else {
													existingEntry.pokemonSpecies?.update(from: entry.pokemonSpecies)
												}
												
												if let image = image {
													self.saveImage(image, for: existingEntry)
												}
											} else {
												let newEntry = PokemonEntry(context: context)
												newEntry.entryNumber = Int32(entry.entryNumber)
												
												let species = PokemonSpecies(context: context)
												species.name = entry.pokemonSpecies.name
												species.url = entry.pokemonSpecies.url
												newEntry.pokemonSpecies = species
												
												if let image = image {
													self.saveImage(image, for: newEntry)
												}
											}
										}
										
										do {
											if context.hasChanges {
												try context.save()
											}
											promise(.success(()))
										} catch {
											promise(.failure(error))
										}
									}
								}
							)
							.store(in: &self.cancellables)
						
					} catch {
						promise(.failure(error))
					}
				}
			}
		}.eraseToAnyPublisher()
	}
	
	private func saveImage(_ image: UIImage, for entry: PokemonEntry) {
		guard let imageData = image.pngData(),
			  let documentsDirectory = FileManager.default.urls(for: .documentDirectory,
																in: .userDomainMask).first else {
			return
		}
		
		let fileName = "\(entry.entryNumber).png"
		let fileURL = documentsDirectory.appendingPathComponent(fileName)
		
		do {
			try imageData.write(to: fileURL)
			print("Image successfully saved at \(fileURL.path)")
			entry.imagePath = fileName
		} catch {
			print("Error saving image: \(error)")
		}
	}
	
	private func fetchPokedexFromCoreData() -> AnyPublisher<[PokemonEntry], Error> {
		return Future { [weak self] promise in
			guard let self = self else {
				return promise(.failure(NSError(domain: "CoreDataError",
												code: NSValidationMissingMandatoryPropertyError,
												userInfo: [NSLocalizedDescriptionKey: "Core Data manager instance is unavailable."])))
			}
			let context = self.coreDataManager.container.viewContext
			let fetchRequest: NSFetchRequest<PokemonEntry> = PokemonEntry.fetchRequest()
			fetchRequest.sortDescriptors = [NSSortDescriptor(key: "entryNumber", ascending: true)]

			do {
				let entries = try context.fetch(fetchRequest)
				if entries.isEmpty {
					promise(.failure(NSError(domain: "CoreData", code: 1, userInfo: [NSLocalizedDescriptionKey: "No data in Core Data"])))
				} else {
					promise(.success(entries))
				}
			} catch {
				promise(.failure(error))
			}
		}.eraseToAnyPublisher()
	}
	
	private func fetchPokemonImage(for pokemonId: Int) -> AnyPublisher<UIImage, Error> {
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
