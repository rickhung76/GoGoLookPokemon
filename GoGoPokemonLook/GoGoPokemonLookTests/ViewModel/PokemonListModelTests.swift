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
	
	func testToggleToFavorite_shouldReturnFavoritePokemons() throws {
		// Arrange
		let exp = XCTestExpectation(description: "\(#function)")
		let dataProvider = MockPokemonDataProvider()
		let favoriteProvider = MockFavoriteDataProvider()
		favoriteProvider.favorites = [
			PokemonElement(name: "Favorite1", url: "https://test.com/1"),
			PokemonElement(name: "Favorite2", url: "https://test.com/2"),
		]
		let model = PokemonListModel(pokemonDataProvider: dataProvider, favoriteDataProvider: favoriteProvider)
		
		model.$state
			.sink { state in
				// Assert
				switch state {
				case .loaded(let pokemons):
					XCTAssertTrue(model.isFavorite)
					XCTAssertEqual(pokemons.map { $0.name }, ["Favorite1", "Favorite2"])
					XCTAssertEqual(pokemons.map { $0.url }, ["https://test.com/1", "https://test.com/2"])
					exp.fulfill()
				default:
					break
				}
			}.store(in: &cancelable)
		
		// Act
		XCTAssertFalse(model.isFavorite)
		model.toggleDataSource()
		
		wait(for: [exp], timeout: 5.0)
	}
	
	func testToggleToPokemonList_shouldReturnExistPokemons() throws {
		// Arrange
		let exp = XCTestExpectation(description: "\(#function)")
		let dataProvider = MockPokemonDataProvider()
		let favoriteProvider = MockFavoriteDataProvider()
		let model = PokemonListModel(pokemonDataProvider: dataProvider, favoriteDataProvider: favoriteProvider)
		model.isFavorite = true
		model.limit = 2
		
		model.$state
			.sink { state in
				// Assert
				switch state {
				case .loaded(let pokemons):
					XCTAssertFalse(model.isFavorite)
					XCTAssertEqual(pokemons.map { $0.name }, ["name0", "name1"])
					XCTAssertEqual(pokemons.map { $0.url }, ["https://test.com/0", "https://test.com/1"])
					exp.fulfill()
				default:
					break
				}
			}.store(in: &cancelable)
		
		// Act
		XCTAssertTrue(model.isFavorite)
		model.toggleDataSource()
		
		wait(for: [exp], timeout: 5.0)
	}
	
	func testTogglePokemonFavorite() {
		// Arrange
		let exp = XCTestExpectation(description: "\(#function)")
		let dataProvider = MockPokemonDataProvider()
		let favoriteProvider = MockFavoriteDataProvider()
		let model = PokemonListModel(pokemonDataProvider: dataProvider, favoriteDataProvider: favoriteProvider)
		model.fetchPokemons(offset: 0, limit: 3)
		let pokemon = PokemonViewModel(name: "name0", url: "http://test.com/0", isFavorite: false)
		
		model.$state.sink { state in
			guard case .loaded(_) = state else { return }
			// Act & Assert
			model.togglePokemonFavorite(pokemon)
			XCTAssertEqual(pokemon.isFavorite, true)
			XCTAssertTrue(favoriteProvider.favorites.contains(pokemon.getElement()))
			XCTAssertEqual(model.pokemons.first?.isFavorite, true)
			
			// Act & Assert
			model.togglePokemonFavorite(pokemon)
			XCTAssertEqual(pokemon.isFavorite, false)
			XCTAssertFalse(favoriteProvider.favorites.contains(pokemon.getElement()))
			XCTAssertEqual(model.pokemons.first?.isFavorite, false)
			
			exp.fulfill()
		}.store(in: &cancelable)

		wait(for: [exp], timeout: 5.0)
	}
}

fileprivate struct MockPokemonDataProvider: PokemonListModelDataProvider {
	
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

fileprivate struct MockPokemonFailureDataProvider: PokemonListModelDataProvider {
	
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

fileprivate class MockFavoriteDataProvider: FavoriteDataProvider {
	var favorites = [PokemonElement]()
	
	func fetch() -> AnyPublisher<FavoritePokemonList, Never> {
		Just(FavoritePokemonList(pokemons: favorites)).eraseToAnyPublisher()
	}
	
	func add(_ pokemon: PokemonElement) {
		favorites.append(pokemon)
	}
	
	func remove(_ pokemon: PokemonElement) {
		favorites.removeAll(where: { $0 == pokemon })
	}
	
	func isFavorite(_ pokemon: PokemonElement) -> Bool {
		favorites.contains(pokemon)
	}
}
