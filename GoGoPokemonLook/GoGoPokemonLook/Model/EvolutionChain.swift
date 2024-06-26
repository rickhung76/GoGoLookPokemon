//
//  EvolutionChain.swift
//  GoGoPokemonLook
//
//  Created by 黃柏叡 on 2024/6/26.
//

import Foundation

struct EvolutionChain: Decodable {
	let chain: ChainElement
	let id: Int
}

struct ChainElement: Decodable, Hashable {
	let evolvesTo: [ChainElement]
	let species: SpeciesElement

	enum CodingKeys: String, CodingKey {
		case evolvesTo = "evolves_to"
		case species
	}
}

extension ChainElement {
	var allEvolvesRecursively: [ChainElement] {
		return [self] + evolvesTo.flatMap { $0.allEvolvesRecursively }
	}
}
