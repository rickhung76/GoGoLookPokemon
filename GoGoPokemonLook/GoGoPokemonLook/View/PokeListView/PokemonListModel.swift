import Foundation
import Combine

protocol PokemonListDataProvider {
	func fetch(offset: Int, limit: Int) -> AnyPublisher<[Pokemon], Error>
}

class PokemonListModel: ObservableObject {
		
	@Published var pokemons: [Pokemon] = []
	
	private let pokemonDataProvider: PokemonListDataProvider
	
	private var cancelable = Set<AnyCancellable>()
	
	var offset = 1
	
	var limit = 20
	
	init(
		pokemons: [Pokemon] = [],
		pokemonDataProvider: PokemonListDataProvider
	) {
		self.pokemons = pokemons
		self.pokemonDataProvider = pokemonDataProvider
	
		fetchPokemons(offset: offset, limit: limit)
	}
	
	func fetchPokemons(offset: Int, limit: Int) {
		pokemonDataProvider
			.fetch(offset: offset, limit: limit)
			.receive(on: DispatchQueue.main)
			.sink { [weak self] completion in
				guard let self else { return }
				self.offset += self.limit
			} receiveValue: { [weak self] models in
				self?.pokemons.append(contentsOf: models)
			}.store(in: &cancelable)
	}
}

struct MockPokemonListDataProvider: PokemonListDataProvider {
	func fetch(offset: Int, limit: Int) -> AnyPublisher<[Pokemon], any Error> {
		var data: [Pokemon] = []
		for i in offset ..< (offset + limit) {
			data.append(Pokemon(id: i, name: "妙蛙種子\(i)"))
		}
		return Just(data)
		.setFailureType(to: Error.self)
		.eraseToAnyPublisher()
	}
}
