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
		let dataProvider = MockPokemonListDataProvider()
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
		let dataProvider = MockPokemonListDataProvider()
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
}

struct MockPokemonListDataProvider: PokemonListDataProvider {
	func fetch(offset: Int, limit: Int) -> AnyPublisher<PokemonList, NSError> {
		let subject = PassthroughSubject<PokemonList, NSError>()
		
		RunLoop.current.perform {
			let pokemons = (offset ..< offset + limit)
				.map({ Pokemon(name: "name\($0)", url: "https://test.com/\($0)") })
			let data: PokemonList = PokemonList(count: 0, next: "", previous: "", results: pokemons)
			subject.send(data)
			subject.send(completion: .finished)
		}

		return subject.eraseToAnyPublisher()
	}
}
