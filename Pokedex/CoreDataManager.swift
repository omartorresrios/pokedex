//
//  CoreDataManager.swift
//  Pokedex
//
//  Created by Omar Torres on 2/7/25.
//

import CoreData

protocol CoreDataManagerProtocol {
	var container: NSPersistentContainer { get }
	func save()
}

final class CoreDataManager: CoreDataManagerProtocol {
	
	init() {
		container = NSPersistentContainer(name: "PokemonData")
		container.loadPersistentStores { storeDescription, error in
			if let error = error {
				fatalError("❌ Unresolved error loading Core Data store: \(error.localizedDescription)")
			}
		}
	}
	
	let container: NSPersistentContainer
	
	func save() {
		let context = container.viewContext
		if context.hasChanges {
			do {
				try context.save()
			} catch {
				fatalError("❌ Unresolved error saving Core Data: \(error.localizedDescription)")
			}
		}
	}
}
