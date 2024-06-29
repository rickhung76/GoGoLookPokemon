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

protocol FavoriteDataProvider {
	func fetch() -> AnyPublisher<FavoritePokemonList, Never>
	func add(_ pokemon: PokemonElement)
	func remove(_ pokemon: PokemonElement)
	func isFavorite(_ pokemon: PokemonElement) -> Bool
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
	
	var isFavorite: Bool = false
	
	var listElements: [PokemonViewModel] {
		isFavorite ? favorites : pokemons
	}
		
	private var pokemons: [PokemonViewModel] = []
	
	private var favorites: [PokemonViewModel] = []
	
	private let pokemonDataProvider: PokemonListModelDataProvider
	
	private let favoriteDataProvider: FavoriteDataProvider
	
	private var cancelable = Set<AnyCancellable>()
	
	var offset = 0
	
	var limit = 20
	
	init(
		pokemonDataProvider: PokemonListModelDataProvider = HttpClient.cacheClient,
		favoriteDataProvider: FavoriteDataProvider = UserDefaultDataPool.shared
	) {
		self.pokemonDataProvider = pokemonDataProvider
		self.favoriteDataProvider = favoriteDataProvider
	}
	
	func toggleDataSource() {
		isFavorite = !isFavorite
		
		if isFavorite {
			if favorites.isEmpty {
				fetchFavorites()
			} else {
				state = .loaded(favorites)
			}
		} else {
			if pokemons.isEmpty {
				fetchPokemons(offset: offset, limit: limit)
			} else {
				state = .loaded(pokemons)
			}
		}
	}
	
	func fetchFavorites() {
		state = .loading
		
		favoriteDataProvider
			.fetch()
			.receive(on: DispatchQueue.main)
			.sink { [weak self] completion in
					guard let self else { return }
					
				guard completion == .finished else { return }
				self.state = .loaded(self.favorites)
				
			} receiveValue: { [weak self] model in
				guard let self else { return }
				let pokemons = model.pokemons.map { p in
					if let pokemon = self.pokemons.first(where: { $0.name == p.name }) {
						return pokemon
					} else {
						return PokemonViewModel(
							name: p.name,
							url: p.url,
							isFavorite: true
						)
					}
				}
				pokemons.forEach {
					self.fetchPokemonDetail($0)
				}
				self.favorites = pokemons
			}.store(in: &cancelable)
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
				let pokemons = model.results.map{
					PokemonViewModel(
						name: $0.name,
						url: $0.url,
						isFavorite: self.isFavorite($0)
					)
				}
				pokemons.forEach {
					self.fetchPokemonDetail($0)
				}
				self.pokemons.append(contentsOf: pokemons)
			}.store(in: &cancelable)
	}
	
	func fetchPokemonDetail(_ pokemon: PokemonViewModel) {
		guard pokemon.detail == nil else { return }
		pokemonDataProvider
			.fetchDetail(pokemon.url)
			.receive(on: DispatchQueue.main)
			.sink { _ in
				
			} receiveValue: { [weak pokemon] detail in
				pokemon?.detail = detail
			}.store(in: &cancelable)
	}
	
	func togglePokemonFavorite(_ pokemon: PokemonViewModel) {
		pokemon.isFavorite = !pokemon.isFavorite
		
		if pokemon.isFavorite {
			favoriteDataProvider.add(pokemon.getElement())
		} else {
			favoriteDataProvider.remove(pokemon.getElement())
		}
		
		fetchFavorites()
		pokemons.first(where: {$0.id == pokemon.id})?.isFavorite = pokemon.isFavorite
	}
	
	func isFavorite(_ pokemon: PokemonElement) -> Bool {
		favoriteDataProvider.isFavorite(pokemon)
	}
}

extension UserDefaultDataPool: FavoriteDataProvider {
	func fetch() -> AnyPublisher<FavoritePokemonList, Never> {
		Just(favoritePokemons).eraseToAnyPublisher()
	}
	
	func add(_ pokemon: PokemonElement) {
		favoritePokemons.add(pokemon)
	}
	
	func remove(_ pokemon: PokemonElement) {
		favoritePokemons.remove(pokemon)
	}
	
	func isFavorite(_ pokemon: PokemonElement) -> Bool {
		favoritePokemons.pokemons.contains(pokemon)
	}
}

extension PokemonListModel: PokemonDetailModelDelegate {}
