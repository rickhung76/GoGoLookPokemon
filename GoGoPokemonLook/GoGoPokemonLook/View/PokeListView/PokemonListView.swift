//
//  PokemonListView.swift
//  GoGoPokemonLook
//
//  Created by 黃柏叡 on 2024/6/24.
//

import SwiftUI
import FiredTofu

struct PokemonListView: View {
	
	@ObservedObject var model = PokemonListModel()
	
	var body: some View {
		List(0 ..< model.listElements.count, id: \.self) { i in
			let element = model.listElements[i]
			let isLast = i == (model.listElements.count - 1)
			PokemonListCell(
				pokemon: element,
				onFavoriteButtonTapped: model.togglePokemonFavorite
			)
			.background {
				NavigationLink(destination:PokemonDetailView(model: PokemonDetailModel(
					pokemon: element,
					delegate: model
				))) { EmptyView() }
			}
			.onAppear {
				guard isLast, !model.isFavorite else { return }
				model.fetchPokemons(
					offset: model.offset,
					limit: model.limit
				)
			}
			
		}
		.navigationTitle(model.isFavorite ? "Favorite List" : "Pokemon List")
		.onAppear {
			guard !model.isFavorite,
				  model.listElements.isEmpty else { return }
			model.fetchPokemons(
				offset: model.offset,
				limit: model.limit
			)
		}
		.toolbar {
			Button {
				model.toggleDataSource()
			} label: {
				let name = model.isFavorite ? "suit.heart.fill" : "suit.heart"
				Image(systemName: name)
			}
		}
	}
}



#Preview {
	PokemonListView()
}
