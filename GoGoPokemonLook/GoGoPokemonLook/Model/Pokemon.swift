//
//  Pokemon.swift
//  GoGoPokemonLook
//
//  Created by 黃柏叡 on 2024/6/25.
//

import Foundation

struct Pokemon: Decodable, Hashable {
	let name: String
	let url: String
	var id: String {
		guard let idSubString = url.split(separator: "/").last else { return "" }
		return String(idSubString)
	}
}

struct PokemonList: Decodable {
	let count: Int
	let next: String
	let previous: String?
	let results: [Pokemon]
}


