//
//  PokemonListModelTests.swift
//  GoGoPokemonLookTests
//
//  Created by 黃柏叡 on 2024/6/25.
//

import XCTest
import Combine
@testable import GoGoPokemonLook

final class PokemonListModelTests: XCTestCase {
	
	var cancelable = Set<AnyCancellable>()

    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
		cancelable.forEach { $0.cancel() }
    }

    func testModelInitializer_shouldInitPropertyWithDefaultValue() throws {
		// Arrange
		let dataProvider = MockPokemonDataProvider()
		// Act
		let model = PokemonListModel(pokemonDataProvider: dataProvider)
		// Assert
		XCTAssertEqual(model.offset, 0)
		XCTAssertEqual(model.limit, 20)
		XCTAssertEqual(model.pokemons.count, 0)
    }
	
	func testModelFetchPokemons_shouldIncreaseOffsetAndPokemonDataArray() throws {
		// Arrange
		let exp = XCTestExpectation()
		exp.expectedFulfillmentCount = 3
		let dataProvider = MockPokemonDataProvider()
		let model = PokemonListModel(pokemonDataProvider: dataProvider)
		
		model.$state
			.sink { state in
				// Assert
				switch state {
				case .idle:
					exp.fulfill()
				case .loading:
					exp.fulfill()
				case .loaded(let pokemons):
					XCTAssertEqual(model.offset, 20)
					XCTAssertEqual(model.limit, 20)
					XCTAssertEqual(pokemons.count, 20)
					exp.fulfill()
				case .error(_):
					XCTFail()
				}
			}.store(in: &cancelable)
		
		// Act
		model.fetchPokemons(offset: 0, limit: 20)
		wait(for: [exp], timeout: 5.0)
	}
	
	func testModelFetchPokemonsFailure_shouldReturnErrorState() throws {
		// Arrange
		let exp = XCTestExpectation()
		exp.expectedFulfillmentCount = 3
		let mockError = NSError(domain: "test_failure_\(#function)", code: -9999)
		let dataProvider = MockPokemonFailureDataProvider(error: mockError)
		let model = PokemonListModel(pokemonDataProvider: dataProvider)
		
		model.$state
			.sink { state in
				// Assert
				switch state {
				case .idle:
					exp.fulfill()
				case .loading:
					exp.fulfill()
				case .loaded(_):
					XCTFail()
				case .error(let error):
					XCTAssertEqual(error, mockError)
					exp.fulfill()
				}
			}.store(in: &cancelable)
		
		// Act
		model.fetchPokemons(offset: 0, limit: 20)
		wait(for: [exp], timeout: 5.0)
	}
	
	func testModelFetchPokemonDetail_shouldMutatePokemonDetail() throws {
		// Arrange
		let exp = XCTestExpectation()
		let dataProvider = MockPokemonDataProvider()
		let model = PokemonListModel(pokemonDataProvider: dataProvider)
		let mockID = 99
		let mockElement = PokemonElement(name: "Pokemon_\(#function)", url: "https://test.com/\(mockID)")
		let mockPokemon = PokemonViewModel(element: mockElement)
		
		mockPokemon.$detail
			.dropFirst()
			.sink(receiveValue: { detail in
				// Assert
				XCTAssertNotNil(detail)
				XCTAssertEqual(detail?.name, "name\(mockID)")
				exp.fulfill()
			}).store(in: &cancelable)
		
		// Act
		model.fetchPokemonDetail(mockPokemon)
		wait(for: [exp], timeout: 5.0)
	}
}

struct MockPokemonDataProvider: PokemonListModelDataProvider {
	
	func fetch(offset: Int, limit: Int) -> AnyPublisher<PokemonList, NSError> {
		let subject = PassthroughSubject<PokemonList, NSError>()
		
		RunLoop.current.perform {
			let pokemons = (offset ..< offset + limit)
				.map({ PokemonElement(name: "name\($0)", url: "https://test.com/\($0)") })
			let data: PokemonList = PokemonList(count: 0, next: "", previous: "", results: pokemons)
			subject.send(data)
			subject.send(completion: .finished)
		}

		return subject.eraseToAnyPublisher()
	}
	
	func fetchDetail(_ url: String) -> AnyPublisher<PokemonDetail, NSError> {
		let subject = PassthroughSubject<PokemonDetail, NSError>()
		
		RunLoop.current.perform {
			guard let idString = url.split(separator: "/").last,
				  let id = Int(idString)
			else {
				subject.send(completion: .failure(NSError()))
				return
			}
			let detail = PokemonDetail(
				id: id,
				name: "name\(id)",
				species: SpeciesElement(name: "species\(id)", url: "species_url_\(id)"),
				sprites: Sprites(frontDefault: "frontDefault_url_\(id)"),
				types: []
			)
			subject.send(detail)
			subject.send(completion: .finished)
		}
		
		return subject.eraseToAnyPublisher()
	}
}

struct MockPokemonFailureDataProvider: PokemonListModelDataProvider {
	
	let error: NSError
	
	init(error: NSError) {
		self.error = error
	}
	
	func fetch(offset: Int, limit: Int) -> AnyPublisher<PokemonList, NSError> {
		let subject = PassthroughSubject<PokemonList, NSError>()
		
		RunLoop.current.perform {
			subject.send(completion: .failure(self.error))
		}

		return subject.eraseToAnyPublisher()
	}
	
	func fetchDetail(_ url: String) -> AnyPublisher<PokemonDetail, NSError> {
		let subject = PassthroughSubject<PokemonDetail, NSError>()
		
		RunLoop.current.perform {
			subject.send(completion: .failure(self.error))
		}
		
		return subject.eraseToAnyPublisher()
	}
}
