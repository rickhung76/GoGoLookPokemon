import Foundation
import Combine

protocol PokemonListDataProvider {
	func fetch(offset: Int, limit: Int) -> AnyPublisher<PokemonList, NSError>
}

class PokemonListModel: ObservableObject {
	
	enum State {
		case idle
		case loading
		case loaded([Pokemon])
		case error(Error)
	}
	
	@Published
	var state: State = .idle
		
	var pokemons: [Pokemon] = []
	
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
	}
	
	func fetchPokemons(offset: Int, limit: Int) {
		
		state = .loading
		
		pokemonDataProvider
			.fetch(offset: offset, limit: limit)
			.sink { [weak self] completion in
				guard let self else { return }
				
				switch completion {
				case .finished:
					self.offset += self.limit
					self.state = .loaded(self.pokemons)
				case .failure(let error):
					self.state = .error(error)
				}
			} receiveValue: { [weak self] model in
				guard let self else { return }
				
				self.pokemons.append(contentsOf: model.results)
			}.store(in: &cancelable)
	}
}
