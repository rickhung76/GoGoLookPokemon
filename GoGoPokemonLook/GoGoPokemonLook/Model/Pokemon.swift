//
//  Pokemon.swift
//  GoGoPokemonLook
//
//  Created by 黃柏叡 on 2024/6/25.
//

import Foundation
import Combine

class PokemonViewModel: ObservableObject {
		
	@Published
	var detail: PokemonDetail?
	
	var species: SpeciesDetail?
	
	let name: String
	
	let url: String
	
	@Published
	var flavor: String?
	
	@Published
	var evolves: [EvolutionChainViewModel]? = []
	
	@Published
	var isFavorite: Bool
	
	var id: String {
		guard let idSubString = url.split(separator: "/").last else { return "" }
		return String(idSubString)
	}
	var typesString: String {
		guard let detail = detail else { return "" }
		var types = detail.types
		let first = types.removeFirst()
		return types.reduce(first.type.name, { return "\($0), \($1.type.name)" })
	}
	
	init(element: PokemonElement) {
		self.name = element.name
		self.url = element.url
		self.isFavorite = false
	}
	
	init(name: String, url: String, isFavorite: Bool) {
		self.name = name
		self.url = url
		self.isFavorite = isFavorite
	}
	
	func getElement() -> PokemonElement {
		PokemonElement(name: name, url: url)
	}
}

extension PokemonViewModel {
	
	convenience init?(species: SpeciesElement) {
		guard let id = species.url.split(separator: "/").last else { return nil }
		self.init(
			name: species.name,
			url: "https://pokeapi.co/api/v2/pokemon/\(id)",
			isFavorite: false
		)
	}
}

extension PokemonViewModel: Hashable {
	
	nonisolated func hash(into hasher: inout Hasher) {
		hasher.combine(name)
		hasher.combine(url)
	}
	
	static func == (lhs: PokemonViewModel, rhs: PokemonViewModel) -> Bool {
		lhs.name == rhs.name && lhs.url == rhs.url
	}
}

struct PokemonElement: Codable, Hashable {
	let name: String
	let url: String
	
	static func == (lhs: PokemonElement, rhs: PokemonElement) -> Bool {
		lhs.name == rhs.name
	}
}

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
