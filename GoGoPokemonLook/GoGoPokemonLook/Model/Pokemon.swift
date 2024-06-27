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
	}
	
	init(name: String, url: String) {
		self.name = name
		self.url = url
	}
}

extension PokemonViewModel {
	
	convenience init?(species: SpeciesElement) {
		guard let id = species.url.split(separator: "/").last else { return nil }
		self.init(name: species.name, url: "https://pokeapi.co/api/v2/pokemon/\(id)")
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

struct PokemonElement: Decodable {
	let name: String
	let url: String
}

struct PokemonList: Decodable {
	let count: Int
	let next: String
	let previous: String?
	let results: [PokemonElement]
}

