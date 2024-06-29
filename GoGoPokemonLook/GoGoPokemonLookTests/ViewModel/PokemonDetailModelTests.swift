//
//  PokemonDetailModelTests.swift
//  GoGoPokemonLookTests
//
//  Created by 黃柏叡 on 2024/6/26.
//

import XCTest
import Combine
@testable import GoGoPokemonLook

final class PokemonDetailModelTests: XCTestCase {

	var cancelable = Set<AnyCancellable>()

	override func setUpWithError() throws {
	}

	override func tearDownWithError() throws {
		cancelable.forEach { $0.cancel() }
	}
	
	func testModelInitializer_shouldInitPropertyWithDefaultValue() {
		// Arrange
		let dataProvider = MockPokemonDetailModelDataProvider()
		let element = PokemonElement(name: "bulbasaur", url: "https://test.pokemon/1")
		let pokemon = PokemonViewModel(element: element)
		let pokemonDetail = PokemonDetail(
			id: 1,
			name: "name1",
			species: SpeciesElement(name: "name1", url: "https://test.species/1"),
			sprites: Sprites(frontDefault: "https://test.frontDefault/1"),
			types: [
				TypeElement(slot: 1, type: PokemonType(name: "grass", url: "https://test.type/1"))
			])
		dataProvider.pokemonDetail = pokemonDetail

		let exp = XCTestExpectation(description: "fetchPokemonDetail")
		
		// Act
		let model = PokemonDetailModel(pokemon: pokemon, delegate: nil, dataProvider: dataProvider)
		model.pokemon.$detail
			.sink { _ in
				XCTFail()
			} receiveValue: { pokemonDetail in
				// Assert
				XCTAssertEqual(pokemonDetail, pokemonDetail)
				exp.fulfill()
			}.store(in: &cancelable)
		wait(for: [exp], timeout: 2)
		XCTAssertEqual(model.pokemon, pokemon)
		XCTAssertEqual(model.flavor, "")
		XCTAssertEqual(model.evolves, [])
	}

	func test_fetchPokemonDetail() {
		// Arrange
		let dataProvider = MockPokemonDetailModelDataProvider()
		let element = PokemonElement(name: "bulbasaur", url: "https://test.pokemon/1")
		let pokemon = PokemonViewModel(element: element)
		let model = PokemonDetailModel(pokemon: pokemon, delegate: nil, dataProvider: dataProvider)
		let pokemonDetail = PokemonDetail(
			id: 1,
			name: "name1",
			species: SpeciesElement(name: "name1", url: "https://test.species/1"),
			sprites: Sprites(frontDefault: "https://test.frontDefault/1"),
			types: [
				TypeElement(slot: 1, type: PokemonType(name: "grass", url: "https://test.type/1"))
			])
		dataProvider.pokemonDetail = pokemonDetail

		let exp = XCTestExpectation(description: "fetchPokemonDetail")
		
		model.pokemon.$detail
			.dropFirst()
			.sink { _ in
				XCTFail()
			} receiveValue: { pokemonDetail in
				// Assert
				XCTAssertEqual(pokemonDetail, pokemonDetail)
				exp.fulfill()
			}.store(in: &cancelable)

		// Act
		model.fetchPokemonDetail()
		wait(for: [exp], timeout: 2)
	}

	func test_fetchPokemonSpecies() {
		// Arrange
		let dataProvider = MockPokemonDetailModelDataProvider()
		let name = "bulbasaur"
		let pokemonDetail = PokemonDetail(
			id: 1,
			name: name,
			species: SpeciesElement(name: "name1", url: "https://test.species/1"),
			sprites: Sprites(frontDefault: "https://test.frontDefault/1"),
			types: []
		)
		let element = PokemonElement(name: name, url: "https://test.pokemon/1")
		let pokemon = PokemonViewModel(element: element)
		pokemon.detail = pokemonDetail
		let model = PokemonDetailModel(pokemon: pokemon, delegate: nil, dataProvider: dataProvider)
		
		let flavor = FlavorTextEntry(
			flavorText: "flavorText",
			language: VersionLanguage(name: "en", url: "VersionLanguageURL"),
			version: VersionColor(name: "VersionColor", url: "VersionColorURL")
		)
		let pokemonSpecies = SpeciesDetail(
			evolutionChain: EvolutionChainElement(url: "EvolutionChainElementURL"),
			flavorTextEntries: [flavor],
			name: name
		)
		dataProvider.speciesDetail = pokemonSpecies
		
		let exp = XCTestExpectation(description: "fetchPokemonSpecies")
		model.$flavor
			.dropFirst()
			.sink { _ in
				XCTFail()
			} receiveValue: { flavor in
				// Assert
				XCTAssertEqual(flavor, pokemonSpecies.getFlavor())
				XCTAssertTrue(dataProvider.isFetchCalled)
				exp.fulfill()
			}.store(in: &cancelable)
		
		// Act
		model.fetchPokemonSpecies()
		wait(for: [exp], timeout: 2)
	}

	func test_fetchPokemonEvolution() {
		// Arrange
		let dataProvider = MockPokemonDetailModelDataProvider()
		let name = "bulbasaur"
		let species = SpeciesDetail(
			evolutionChain: EvolutionChainElement(url: "EvolutionChainElementURL"),
			flavorTextEntries: [],
			name: name
		)
		let element = PokemonElement(name: name, url: "https://test.pokemon/1")
		let pokemon = PokemonViewModel(element: element)
		pokemon.species = species
		let model = PokemonDetailModel(pokemon: pokemon, delegate: nil, dataProvider: dataProvider)
		let evolutionChain = EvolutionChain(
			chain: ChainElement(
				evolvesTo: [],
				species: SpeciesElement(name: "SpeciesElement", url: "SpeciesElementURL")),
			id: 1
		)
		dataProvider.evolutionChain = evolutionChain
		
		let evoViewModels = evolutionChain
			.chain
			.allEvolvesRecursively
			.map {
				EvolutionChainViewModel(
					chain: $0,
					isClickable: true
				)
			}

		let exp = XCTestExpectation(description: "fetchPokemonEvolution")
		
		model.$evolves
			.dropFirst()
			.sink { _ in
				XCTFail()
			} receiveValue: { evolvesViewModels in
				XCTAssertEqual(evolvesViewModels, evoViewModels)
				XCTAssertTrue(dataProvider.isFetchCalled)
				exp.fulfill()
			}
			.store(in: &cancelable)

		model.fetchEvolutionChain()
		wait(for: [exp], timeout: 20)
	}

	func test_togglePokemonFavorite() {
		// Arrange
		class MockDelegate: PokemonDetailModelDelegate {
			var delegatePokemon: PokemonViewModel? = nil
			func togglePokemonFavorite(_ pokemon: PokemonViewModel) {
				delegatePokemon = pokemon
			}
		}
		let delegate = MockDelegate()
		let dataProvider = MockPokemonDetailModelDataProvider()
		let element = PokemonElement(name: "bulbasaur", url: "https://test.pokemon/1")
		let pokemon = PokemonViewModel(element: element)
		let model = PokemonDetailModel(pokemon: pokemon, delegate: delegate, dataProvider: dataProvider)
				
		// Act
		model.togglePokemonFavorite()
		// Assert
		XCTAssertEqual(delegate.delegatePokemon, pokemon)
	}
}

fileprivate class MockPokemonDetailModelDataProvider: PokemonDetailModelDataProvider {
	var pokemonDetail: PokemonDetail?
	var speciesDetail: SpeciesDetail?
	var evolutionChain: EvolutionChain?
	var error: NSError?
	var isFetchCalled = false
	
	func fetchDetail(_ url: String) -> AnyPublisher<PokemonDetail, NSError> {
		let subject = PassthroughSubject<PokemonDetail, NSError>()
		
		RunLoop.current.perform {
			self.isFetchCalled = true
			if let error = self.error {
				subject.send(completion: .failure(error))
			}
			if let pokemonDetail = self.pokemonDetail {
				subject.send(pokemonDetail)
				subject.send(completion: .finished)
			}
		}
		return subject.eraseToAnyPublisher()
	}
	
	func fetchEvolutionChain(_ url: String) -> AnyPublisher<EvolutionChain, NSError> {
		let subject = PassthroughSubject<EvolutionChain, NSError>()
		
		RunLoop.current.perform {
			self.isFetchCalled = true
			if let error = self.error {
				subject.send(completion: .failure(error))
			}
			if let evolutionChain = self.evolutionChain {
				subject.send(evolutionChain)
				subject.send(completion: .finished)
			}
		}
		return subject.eraseToAnyPublisher()
	}
	
	func fetchSpecies(_ url: String) -> AnyPublisher<SpeciesDetail, NSError> {
		let subject = PassthroughSubject<SpeciesDetail, NSError>()
		
		RunLoop.current.perform {
			self.isFetchCalled = true
			if let error = self.error {
				subject.send(completion: .failure(error))
			}
			if let speciesDetail = self.speciesDetail {
				subject.send(speciesDetail)
				subject.send(completion: .finished)
			}
		}
		return subject.eraseToAnyPublisher()
	}

}
