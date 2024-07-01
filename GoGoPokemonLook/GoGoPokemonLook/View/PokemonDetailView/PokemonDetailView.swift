//
//  PokemonDetailView.swift
//  GoGoPokemonLook
//
//  Created by 黃柏叡 on 2024/6/26.
//

import SwiftUI

struct PokemonDetailView: View {
	
	@StateObject var model: PokemonDetailModel
	
	var body: some View {
		ScrollView {
			VStack {
				ZStack {
					if let url = URL(string: model.pokemon.detail?.sprites.frontDefault ?? "") {
						CachedAsyncImage(url: url)
							.frame(width: 200, height: 200, alignment: .center)
					} else {
						ProgressView()
							.scaleEffect(2)
							.frame(width: 200, height: 200, alignment: .center)
					}
					
					Button {
						model.togglePokemonFavorite()
					} label: {
						let imageName = model.isFavorite ? "suit.heart.fill" : "suit.heart"
						Image(systemName: imageName)
							.foregroundStyle(.red)
							.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
							.padding(30)
					}
				}
				
				Text("Type")
					.frame(maxWidth: .infinity, alignment: .leading)
					.font(.title2.bold())
					.padding()
				
				HStack {
					if let detail = model.pokemon.detail {
						ForEach(detail.types, id: \.self) {
							Text($0.type.name)
								.padding()
						}
					}
				}
				
				Text("Flavor")
					.frame(maxWidth: .infinity, alignment: .leading)
					.font(.title2.bold())
					.padding()
				
				Text(model.flavor)
					.frame(maxWidth: .infinity, alignment: .center)
					.fixedSize(horizontal: false, vertical: true)
					.padding()
				
				Text("Evolution")
					.frame(maxWidth: .infinity, alignment: .leading)
					.font(.title2.bold())
					.bold()
					.padding()
				
				HStack {
					ForEach(model.evolves, id: \.self) { evolve in
						if evolve.isClickable,
						   let pokemon = PokemonViewModel(species: evolve.chain.species) {
							
							NavigationLink(destination: PokemonDetailView(
								model: PokemonDetailModel(
									pokemon: pokemon,
									delegate: model.delegate
								)
							)) {
								Text(evolve.chain.species.name)
									.padding()
							}
						} else {
							Text(evolve.chain.species.name)
								.padding()
						}
					}
				}
			}
		}
		.navigationTitle("\(model.pokemon.id). \(model.pokemon.name)")
		.onAppear {
			model.fetchPokemonSpecies()
		}
	}
}

#Preview {
	PokemonDetailView(model: PokemonDetailModel(
		pokemon: PokemonViewModel(
			name: "種子種子",
			url: "https://pokeapi.co/api/v2/pokemon/1",
			isFavorite: true
		),
		delegate: nil
	)
	)
}
