//
//  PokemonDetailView.swift
//  GoGoPokemonLook
//
//  Created by 黃柏叡 on 2024/6/26.
//

import SwiftUI

struct PokemonDetailView: View {
	
	@ObservedObject var model: PokemonDetailModel
	
	var body: some View {
		VStack {
			AsyncImage(url: URL(
				string: model.pokemon.detail?.sprites.frontDefault ?? ""
			)) {
				$0.image?.resizable().scaledToFill()
			}
			.frame(width: 250, height: 250, alignment: .center)
			
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
			
			Text("Evolution")
				.frame(maxWidth: .infinity, alignment: .leading)
				.font(.title2.bold())
				.bold()
				.padding()
			
			AsyncImage(url: URL(string: model.pokemon.detail?.sprites.frontDefault ?? ""))
				.frame(width: 100, height: 100, alignment: .center)
		}
		.navigationTitle("\(model.pokemon.id). \(model.pokemon.name)")
		.onAppear {
			model.fetchPokemonSpecies()
		}
	}
}

#Preview {
	PokemonDetailView(model: PokemonDetailModel(
		pokemon: Pokemon(
			name: "種子種子",
			url: "https://pokeapi.co/api/v2/pokemon/1"
		))
	)
}
