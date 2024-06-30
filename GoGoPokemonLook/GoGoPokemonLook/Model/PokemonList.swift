//
//  PokemonList.swift
//  GoGoPokemonLook
//
//  Created by 黃柏叡 on 2024/6/30.
//

import Foundation

struct PokemonList: Decodable {
	let count: Int
	let next: String
	let previous: String?
	let results: [PokemonElement]
}

struct FavoritePokemonList: Codable {
	
	var pokemons: [PokemonElement]
	
	mutating func add(_ pokemon: PokemonElement) {
		guard !pokemons.contains(pokemon) else { return }
		self.pokemons.append(pokemon)
	}
	
	mutating func remove(_ pokemon: PokemonElement) {
		self.pokemons.removeAll(where: { $0 == pokemon })
	}
}

struct PokemonElement: Codable, Hashable {
	let name: String
	let url: String
	
	static func == (lhs: PokemonElement, rhs: PokemonElement) -> Bool {
		lhs.name == rhs.name
	}
}
