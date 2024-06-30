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
