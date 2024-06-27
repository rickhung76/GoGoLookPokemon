import Foundation
import Combine
import FiredTofu

typealias PokemonListModelDataProvider = PokemonListDataProvider & PokemonDetailDataProvider

protocol PokemonListDataProvider {
	func fetch(offset: Int, limit: Int) -> AnyPublisher<PokemonList, NSError>
}

protocol PokemonDetailDataProvider {
	func fetchDetail(_ url: String) -> AnyPublisher<PokemonDetail, NSError>
}

class PokemonListModel: ObservableObject {
	
	enum State {
		case idle
		case loading
		case loaded([PokemonViewModel])
		case error(NSError)
	}
	
	@Published
	var state: State = .idle
		
	var pokemons: [PokemonViewModel] = []
	
	private let pokemonDataProvider: PokemonListModelDataProvider
	
	private var cancelable = Set<AnyCancellable>()
	
	var offset = 0
	
	var limit = 20
	
	init(
		pokemons: [PokemonViewModel] = [],
		pokemonDataProvider: PokemonListModelDataProvider = HttpClient.default
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
					self.state = .error(error)
				}
			} receiveValue: { [weak self] model in
				guard let self else { return }
				let pokemons = model.results.map{ PokemonViewModel(element: $0) }
				pokemons.forEach {
					self.fetchPokemonDetail($0)
				}
				self.pokemons.append(contentsOf: pokemons)
			}.store(in: &cancelable)
	}
	
	func fetchPokemonDetail(_ pokemon: PokemonViewModel) {
		pokemonDataProvider
			.fetchDetail(pokemon.url)
			.receive(on: DispatchQueue.main)
			.sink { _ in
				
			} receiveValue: { [weak pokemon] detail in
				pokemon?.detail = detail
			}.store(in: &cancelable)
	}
}
