//
//  PokemonListViewModel.swift
//  Pokedex
//
//  Created by Omar Torres on 2/9/25.
//

import Foundation
import CoreData
import Combine
import UIKit

final class PokemonListViewModel: NSObject {
	private let pokemonService: PokemonServiceProtocol
	
	var viewContext: NSManagedObjectContext {
		pokemonService.viewContext
	}
	
	init(pokemonService: PokemonServiceProtocol) {
		self.pokemonService = pokemonService
	}
	
	func fetchPokedex() -> AnyPublisher<PokedexResponse, Error> {
		pokemonService.fetchPokedex()
	}
	
	func fetchLocalPokedex(completion: @escaping (Result<[PokemonEntry], FetchError>) -> Void) {
		let context = viewContext
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
							completion: @escaping (Result<[PokemonEntry], FetchError>) -> Void) {
		let fetchRequest: NSFetchRequest<PokemonEntry> = PokemonEntry.fetchRequest()
		fetchRequest.predicate = NSPredicate(format: "pokemonSpecies.name CONTAINS[cd] %@", searchText)
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "entryNumber", ascending: true)]
		
		do {
			let searchResults = try viewContext.fetch(fetchRequest)
			completion(.success(searchResults))
		} catch {
			print("Error filtering: \(error)")
		}
	}
}
