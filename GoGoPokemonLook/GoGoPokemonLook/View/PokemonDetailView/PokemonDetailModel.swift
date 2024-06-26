//
//  PokemonDetailModel.swift
//  GoGoPokemonLook
//
//  Created by 黃柏叡 on 2024/6/26.
//

import Foundation
import Combine
import FiredTofu

typealias PokemonDetailAndSpeciesDataProvider = PokemonDetailDataProvider & PokemonSpeciesDataProvider

protocol PokemonSpeciesDataProvider {
	func fetchSpecies(_ url: String) -> AnyPublisher<SpeciesDetail, NSError>
}

class PokemonDetailModel: ObservableObject {
	
	let pokemon: Pokemon
	
	@Published
	var flavor: String = ""
	
	private var cancelable = Set<AnyCancellable>()
	
	private let dataProvider: PokemonDetailAndSpeciesDataProvider
	
	init(
		pokemon: Pokemon,
		dataProvider: PokemonDetailAndSpeciesDataProvider = HttpClient.default
	) {
		self.pokemon = pokemon
		self.dataProvider = dataProvider
	}
	
	func fetchPokemonSpecies() {
		guard let detail = pokemon.detail else { return }
		dataProvider
			.fetchSpecies(detail.species.url)
			.receive(on: DispatchQueue.main)
			.sink { _ in
				
			} receiveValue: { [weak self] species in
				guard let self else { return }
				print(species.evolutionChain)
				self.pokemon.species = species
				self.flavor = species.getFlavor()
			}.store(in: &cancelable)
	}
}
