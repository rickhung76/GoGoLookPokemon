import Foundation
import Combine

protocol PokemonListDataProvider {
	func fetch(offset: Int, limit: Int) -> AnyPublisher<PokemonList, NSError>
}

class PokemonListModel: ObservableObject {
		
	@Published var pokemons: [Pokemon] = []
	
	private let pokemonDataProvider: PokemonListDataProvider
	
	private var cancelable = Set<AnyCancellable>()
	
	var offset = 0
	
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
			} receiveValue: { [weak self] model in
				self?.pokemons.append(contentsOf: model.results)
			}.store(in: &cancelable)
	}
}

