import Foundation
import Combine

typealias PokemonDataProvider = PokemonListDataProvider & PokemonDetailDataProvider

protocol PokemonListDataProvider {
	func fetch(offset: Int, limit: Int) -> AnyPublisher<PokemonList, NSError>
}

protocol PokemonDetailDataProvider {
	func fetchDetail(_ url: String) -> AnyPublisher<PokemonDetail, NSError>
	func fetchDetail(_ url: String) async throws -> PokemonDetail
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
	
	private let pokemonDataProvider: PokemonDataProvider
	
	private var cancelable = Set<AnyCancellable>()
	
	var offset = 0
	
	var limit = 20
	
	init(
		pokemons: [Pokemon] = [],
		pokemonDataProvider: PokemonDataProvider
	) {
		self.pokemons = pokemons
		self.pokemonDataProvider = pokemonDataProvider
	}
	
	func fetchPokemons(offset: Int, limit: Int) {
		
		state = .loading
		
		pokemonDataProvider
			.fetch(offset: offset, limit: limit)
			.receive(on: DispatchQueue.main)
			.sink { [weak self] completion in
				guard let self else { return }
				
				switch completion {
				case .finished:
					self.offset += self.limit
					self.state = .loaded(self.pokemons)
				case .failure(let error):
					print("\(#function) ERROR: \(error.localizedDescription)")
					self.state = .error(error)
				}
			} receiveValue: { [weak self] model in
				guard let self else { return }
				let pokemons = model.results
				pokemons.forEach {
					self.fetchPokemonDetail($0)
				}
				self.pokemons.append(contentsOf: pokemons)
			}.store(in: &cancelable)
	}
	
	func fetchPokemonDetail(_ pokemon: Pokemon) {
		pokemonDataProvider
			.fetchDetail(pokemon.url)
			.receive(on: DispatchQueue.main)
			.sink { _ in
				
			} receiveValue: { [weak pokemon] detail in
				pokemon?.detail = detail
			}.store(in: &cancelable)
	}
}
