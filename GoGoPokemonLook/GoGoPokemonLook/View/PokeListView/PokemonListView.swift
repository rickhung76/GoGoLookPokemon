//
//  PokemonListView.swift
//  GoGoPokemonLook
//
//  Created by 黃柏叡 on 2024/6/24.
//

import SwiftUI
import FiredTofu

struct PokemonListView: View {
	
	@StateObject var model = PokemonListModel()
	
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
		.alert(isPresented: $model.showAlert) {
			var error: NSError?
			if case let .error(err) = model.state {
				error = err
			}
			return Alert(
				title: Text("Something went wrong"),
				message: error.isNil ? nil : Text(error!.localizedDescription),
				dismissButton: .default(Text("OK"))
			)
		}

	}
}



#Preview {
	PokemonListView()
}
