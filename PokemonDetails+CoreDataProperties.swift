//
//  PokemonDetails+CoreDataProperties.swift
//  Pokedex
//
//  Created by Omar Torres on 2/7/25.
//
//

import Foundation
import CoreData


extension PokemonDetails {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PokemonDetails> {
        return NSFetchRequest<PokemonDetails>(entityName: "PokemonDetails")
    }

    @NSManaged public var id: Int32
    @NSManaged public var name: String?
    @NSManaged public var types: NSSet?
    @NSManaged public var stats: NSSet?
    @NSManaged public var moves: NSSet?
    @NSManaged public var sprites: PokemonSprites?

}

// MARK: Generated accessors for types
extension PokemonDetails {

    @objc(addTypesObject:)
    @NSManaged public func addToTypes(_ value: PokemonType)

    @objc(removeTypesObject:)
    @NSManaged public func removeFromTypes(_ value: PokemonType)

    @objc(addTypes:)
    @NSManaged public func addToTypes(_ values: NSSet)

    @objc(removeTypes:)
    @NSManaged public func removeFromTypes(_ values: NSSet)

}

// MARK: Generated accessors for stats
extension PokemonDetails {

    @objc(addStatsObject:)
    @NSManaged public func addToStats(_ value: PokemonStat)

    @objc(removeStatsObject:)
    @NSManaged public func removeFromStats(_ value: PokemonStat)

    @objc(addStats:)
    @NSManaged public func addToStats(_ values: NSSet)

    @objc(removeStats:)
    @NSManaged public func removeFromStats(_ values: NSSet)

}

// MARK: Generated accessors for moves
extension PokemonDetails {

    @objc(addMovesObject:)
    @NSManaged public func addToMoves(_ value: PokemonMove)

    @objc(removeMovesObject:)
    @NSManaged public func removeFromMoves(_ value: PokemonMove)

    @objc(addMoves:)
    @NSManaged public func addToMoves(_ values: NSSet)

    @objc(removeMoves:)
    @NSManaged public func removeFromMoves(_ values: NSSet)

}

extension PokemonDetails : Identifiable {

}
