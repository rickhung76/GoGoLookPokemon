//
//  PokemonDetail.swift
//  GoGoPokemonLook
//
//  Created by 黃柏叡 on 2024/6/25.
//

import Foundation

struct PokemonDetail: Decodable, Hashable {
	
	let id: Int
	let name: String
	let species: SpeciesElement
	let sprites: Sprites
	let types: [TypeElement]
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
		hasher.combine(name)
	}
	
	static func == (lhs: PokemonDetail, rhs: PokemonDetail) -> Bool {
		lhs.name == rhs.name && lhs.id == rhs.id
	}
}

struct Sprites: Decodable, Hashable {

	let frontDefault: String
	
	enum CodingKeys: String, CodingKey {
		case frontDefault = "front_default"
	}
}

struct TypeElement: Decodable, Hashable {
	let slot: Int
	let type: PokemonType
}

struct SpeciesElement: Decodable, Hashable {
	let name: String
	let url: String
}

struct PokemonType: Decodable, Hashable {
	let name: String
	let url: String
}
