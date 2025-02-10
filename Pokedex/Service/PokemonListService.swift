//
//  PokemonListService.swift
//  Pokedex
//
//  Created by Omar Torres on 2/7/25.
//

import Combine
import CoreData

typealias fetchPokedexCompletion = (Result<[PokemonEntry], FetchError>) -> Void
typealias FetchSearhCompletion = (Result<[PokemonEntry], FetchError>) -> Void

protocol PokemonListServiceProtocol {
	func fetchPokedex() -> AnyPublisher<PokedexResponse, Error>
	func fetchLocalPokedex(completion: @escaping fetchPokedexCompletion)
	func fetchSearchRequest(_ searchText: String,
							completion: @escaping FetchSearhCompletion)
}

class PokemonListService: PokemonListServiceProtocol {
	private let coreDataManager: CoreDataManager
	private var cancellables: Set<AnyCancellable> = []
	
	init(coreDataManager: CoreDataManager) {
		self.coreDataManager = coreDataManager
	}
	
	func fetchPokedex() -> AnyPublisher<PokedexResponse, Error> {
		guard let url = URL(string: "https://pokeapi.co/api/v2/pokedex/1/") else {
			return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
		}
		
		return URLSession.shared.dataTaskPublisher(for: url)
			.map(\.data)
			.decode(type: PokedexResponse.self, decoder: JSONDecoder())
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
				let imagePublishers = self.getImagePublishers(for: entries)
				
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
								do {
									let fetchRequest: NSFetchRequest<PokemonEntry> = PokemonEntry.fetchRequest()
									let existingEntries = try context.fetch(fetchRequest)
									let existingDict = Dictionary(uniqueKeysWithValues: existingEntries.map {
										(Int($0.entryNumber), $0)
									})
									
									for (entry, image) in results {
										if let existingEntry = existingDict[entry.entryNumber] {
											self.updateExistingEntry(existingEntry,
																imageData: image,
																in: context,
																with: entry)
										} else {
											self.createNewEntry(imageData: image,
																in: context,
																with: entry)
										}
									}
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
			}
		}.eraseToAnyPublisher()
	}
	
	private func getImagePublishers(for entries: [PokemonEntryResponse]) -> [AnyPublisher<(PokemonEntryResponse, 
																						   Data?),
																			 Error>] {
		entries.map { entry -> AnyPublisher<(PokemonEntryResponse, Data?), Error> in
			return self.fetchPokemonImage(for: entry.entryNumber)
				.map { image in (entry, image) }
				.catch { error -> AnyPublisher<(PokemonEntryResponse, Data?), Error> in
					return Just((entry, nil))
						.setFailureType(to: Error.self)
						.eraseToAnyPublisher()
				}
				.eraseToAnyPublisher()
		}
	}
	
	private func updateExistingEntry(_ existingEntry: PokemonEntry,
									 imageData: Data?,
									 in context: NSManagedObjectContext,
									 with entry: PokemonEntryResponse) {
		if existingEntry.pokemonSpecies == nil {
			let species = PokemonSpecies(context: context)
			species.update(from: entry.pokemonSpecies)
			existingEntry.pokemonSpecies = species
		} else {
			existingEntry.pokemonSpecies?.update(from: entry.pokemonSpecies)
		}
		
		if let imageData = imageData {
			self.saveImage(imageData, for: existingEntry)
		}
	}
	
	private func createNewEntry(imageData: Data?,
						in context: NSManagedObjectContext,
						with entry: PokemonEntryResponse) {
		let newEntry = PokemonEntry(context: context)
		newEntry.entryNumber = Int32(entry.entryNumber)
		
		let species = PokemonSpecies(context: context)
		species.name = entry.pokemonSpecies.name
		species.url = entry.pokemonSpecies.url
		newEntry.pokemonSpecies = species
		
		if let imageData = imageData {
			self.saveImage(imageData, for: newEntry)
		}
	}
	
	private func saveImage(_ image: Data?, for entry: PokemonEntry) {
		guard let imageData = image,
			  let documentsDirectory = FileManager.default.urls(for: .documentDirectory,
																in: .userDomainMask).first else {
			return
		}
		
		let fileName = "\(entry.entryNumber).png"
		let fileURL = documentsDirectory.appendingPathComponent(fileName)
		
		do {
			try imageData.write(to: fileURL)
			entry.imagePath = fileName
		} catch {
			print("Error saving image: \(error)")
		}
	}
	
	private func fetchPokemonImage(for pokemonId: Int) -> AnyPublisher<Data, Error> {
		let imageUrl = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(pokemonId).png"
		
		guard let url = URL(string: imageUrl) else {
			return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
		}
		
		return URLSession.shared.dataTaskPublisher(for: url)
			.tryMap(\.data)
			.eraseToAnyPublisher()
	}
	
	func fetchLocalPokedex(completion: @escaping fetchPokedexCompletion) {
		let context = coreDataManager.container.viewContext
		let fetchRequest: NSFetchRequest<PokemonEntry> = PokemonEntry.fetchRequest()
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "entryNumber", ascending: true)]
		
		context.perform {
			do {
				let pokemonEntries = try context.fetch(fetchRequest)
				completion(.success(pokemonEntries))
			} catch {
				completion(.failure(.dataFetchError))
			}
		}
	}
	
	func fetchSearchRequest(_ searchText: String,
							completion: @escaping FetchSearhCompletion) {
		let fetchRequest: NSFetchRequest<PokemonEntry> = PokemonEntry.fetchRequest()
		fetchRequest.predicate = NSPredicate(format: "pokemonSpecies.name CONTAINS[cd] %@", searchText)
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "entryNumber", ascending: true)]
		
		do {
			let searchResults = try coreDataManager.container.viewContext.fetch(fetchRequest)
			completion(.success(searchResults))
		} catch {
			completion(.failure(.dataFetchError))
		}
	}
}
