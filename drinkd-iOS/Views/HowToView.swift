//
//  HowToView.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 11/12/21.
//

import SwiftUI

struct HowToView: View {
	//203,203,208
	private enum selectionChoices {
		case createParty, joinParty, voteForParty, topChoices
	}

	@State var showCreateParty = false
	@State var showJoinParty = false
	@State var showVoteForParty = false
	@State var showTopChoices = false

	@State var firstButtonPressed = false
	@State var secondButtonPressed = false
	@State var thirdButtonPressed = false
	@State var fourthButtonPressed = false

	var body: some View {
		
		List {
			HStack {
				Text("How to Create a Party")
				Spacer()
				Image(systemName: "chevron.right")
			}
			.listRowBackground(firstButtonPressed ? Color(red: 203 / 255, green: 208 / 255, blue: 208 / 255, opacity: 0.7) : Color.white)
			.contentShape(Rectangle())
			.onTapGesture {
				showModal(for: .createParty)
				self.firstButtonPressed = true
			}
			.sheet(isPresented: $showCreateParty, onDismiss: {firstButtonPressed = false}) {
				createPartySheet()
			}
			

			HStack {
				Text("How to Join a Party")
				Spacer()
				Image(systemName: "chevron.right")
			}
			.listRowBackground(secondButtonPressed ? Color(red: 203 / 255, green: 208 / 255, blue: 208 / 255, opacity: 0.7) : Color.white)
			.contentShape(Rectangle())
			.onTapGesture {
				showModal(for: .joinParty)
				self.secondButtonPressed = true
			}
			.sheet(isPresented: $showJoinParty, onDismiss: {secondButtonPressed = false}) {
				joinPartySheet()
			}

			HStack {
				Text("How to Vote for a Party")
				Spacer()
				Image(systemName: "chevron.right")
			}
			.listRowBackground(thirdButtonPressed ? Color(red: 203 / 255, green: 208 / 255, blue: 208 / 255, opacity: 0.7) : Color.white)
			.contentShape(Rectangle())
			.onTapGesture {
				showModal(for: .voteForParty)
				self.thirdButtonPressed = true
			}
			.sheet(isPresented: $showVoteForParty, onDismiss: {thirdButtonPressed = false}) {
				voteForPartySheet()
			}

			HStack {
				Text("How to Check the Restaurant Rankings")
				Spacer()
				Image(systemName: "chevron.right")
			}
			.listRowBackground(fourthButtonPressed ? Color(red: 203 / 255, green: 208 / 255, blue: 208 / 255, opacity: 0.7) : Color.white)
			.contentShape(Rectangle())
			.onTapGesture {
				showModal(for: .topChoices)
				self.fourthButtonPressed = true
			}
			.sheet(isPresented: $showTopChoices, onDismiss: {fourthButtonPressed = false}) {
				topChoicesSheet()
			}
		}
		.navigationBarTitle("Tutorials")

		Spacer()
	}

	private struct createPartySheet: View {
		var body: some View {
			VStack(alignment: .leading) {
				Text("Creating a party makes you the Party Leader. As the Party Leader you are responsible for creating and dismantling your party.")
					.addBottomPadding()
				Text("To create a party, follow the below steps:")
					.addBottomPadding()
				Text("1. Go to the Party tab. Choose a name for your party.")
					.addBottomPadding()
				Text("2. You will see a unique Party ID. This number allows others to join your party.")
					.addBottomPadding()
				Text("3. The leave button will both exit and destroy your current party. All users in the party will be kicked out.")
			}
		}
	}

	private struct joinPartySheet: View {
		var body: some View {
			VStack(alignment: .leading) {
				Text("1. To join a party, click on the Party tab, press join button and enter the Party ID in the Input Field.")
					.addBottomPadding()
				Text("2. If a valid ID is entered, you will enter into the main party screen. If an invalid ID is entered, you will be presented with an error.")
			}
		}
	}

	private struct voteForPartySheet: View {
		var body: some View {
			VStack(alignment: .leading) {
				Text("1. To vote for a restaurant, you must either create or join an existing party.")
					.addBottomPadding()
				Text("2. Each card on the Home screen will have a row of five stars. Press one of the stars to set a rating for that restaurant, minimum rating is one and maximum is five.")
					.addBottomPadding()
				Text("3. Press on the Submit button to finalize the vote. If you do not press submit, the rating will not be finalized.")
					.addBottomPadding()
				Text("4. After submitting a score, you can rerate by choosing a different rating and resubmitting. This will override your previous rating of the restaurant.")
			}
		}
	}

	private struct topChoicesSheet: View {
		var body: some View {
			VStack(alignment: .leading) {
				Text("1. On the Top Choices screen, you can see your parties highest rated restaurants.")
					.addBottomPadding()
				Text("2. The list is updated everytime a user votes for a restaurant.")
					.addBottomPadding()
				Text("3. To see the the highest rated restaurants, you must be in a party.")
			}
		}
	}

	private func showModal(for type: selectionChoices) {

		switch(type) {
		case .createParty:
			self.showCreateParty = true
		case .joinParty:
			self.showJoinParty = true
		case .voteForParty:
			self.showVoteForParty = true
		case .topChoices:
			self.showTopChoices = true
		}

	}

}

extension Text {
	func addBottomPadding() -> some View {
		return self.padding(.bottom, 10)
	}
}

struct HowToView_Previews: PreviewProvider {
	static var previews: some View {
		HowToView()
	}
}
