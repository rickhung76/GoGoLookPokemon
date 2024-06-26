//
//  SpeciesDetail.swift
//  GoGoPokemonLook
//
//  Created by 黃柏叡 on 2024/6/26.
//

import Foundation

struct SpeciesDetail: Decodable {
	
	let evolutionChain: EvolutionChainElement
	let flavorTextEntries: [FlavorTextEntry]
	let name: String

	enum CodingKeys: String, CodingKey {
		case evolutionChain = "evolution_chain"
		case flavorTextEntries = "flavor_text_entries"
		case name
	}
	
	func getFlavor() -> String {
		flavorTextEntries
			.first(where: { $0.language.name == "en" })?
			.flavorText
		?? "N/A"
	}
}

struct EvolutionChainElement: Decodable {
	let url: String
}

struct FlavorTextEntry: Decodable {
	let flavorText: String
	let language: VersionLanguage
	let version: VersionColor

	enum CodingKeys: String, CodingKey {
		case flavorText = "flavor_text"
		case language, version
	}
}

struct VersionLanguage: Decodable {
	let name: String
	let url: String
}

struct VersionColor: Decodable {
	let name: String
	let url: String
}
