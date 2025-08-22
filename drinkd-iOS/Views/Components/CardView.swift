//
//  CardView.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/22/21.
//

//245,31,32

import SwiftUI
import drinkdSharedModels

struct CardView: View {

    @Environment(PartyViewModel.self) var viewModel
    @Environment(\.openURL) var openURL
    @Environment(Networking.self) var networking
    @State private var showError: (status: Bool, message: String) = (false, "")

    private var restaurantTitle: String
    private var restaurantCategories: String
    private var restaurantScore: Int
    private var restaurantPrice: String
    private var restaurantImageURL: String
    private var restaurantCity: String
    private var restaurantAddress1: String
    private var restaurantAddress2: String?
    private var restaurantPhoneNumber: String
    private var restaurantZipCode: String
    private var restaurantState: String
    private var restaurantURL: String
    private var optionsDelivery: Bool = false
    private var optionsPickup: Bool = false
    private var optionsReservations: Bool = false

    
    //We use optionals because the API can return null for some properties
    init(in restaurantDetails: YelpApiBusinessSearchProperties) {

        let verifiedRestaurantScore = restaurantDetails.rating ?? 0
        
        self.restaurantTitle = restaurantDetails.name ?? "Name not found"
        self.restaurantCategories = restaurantDetails.categories?[0].title ?? "None"
        self.restaurantScore =  verifiedRestaurantScore > 5 ? 5 : Int(verifiedRestaurantScore)
        self.restaurantPrice = restaurantDetails.price ?? "Not Found"
        self.restaurantImageURL = restaurantDetails.image_url ?? "Not Found"
        self.restaurantCity = restaurantDetails.location?.city ?? "Not Found"
        self.restaurantAddress1 = restaurantDetails.location?.address1 ?? "Not Found"
        self.restaurantAddress2 = restaurantDetails.location?.address2 ?? ""
        self.restaurantPhoneNumber  = restaurantDetails.phone ?? ""
        self.restaurantZipCode = restaurantDetails.location?.zip_code ?? ""
        self.restaurantState = restaurantDetails.location?.state ?? ""
        self.restaurantURL = restaurantDetails.url ?? ""
        self.optionsDelivery = restaurantDetails.deliveryAvailable ?? false
        self.optionsReservations = restaurantDetails.reservationAvailable ?? false
        self.optionsPickup = restaurantDetails.pickUpAvailable ?? false
    }

    var body: some View {

            ZStack {
                RoundedRectangle(cornerRadius: CardSpecificStyle.cornerRadius)
                    .fill(Color.white)
                    .overlay(RoundedRectangle(cornerRadius: CardSpecificStyle.cornerRadius).strokeBorder(Color(red: 221/255, green: 221/255, blue: 221/255), lineWidth: 2))

                VStack(alignment: .leading) {
                    Text("\(restaurantTitle)")
                        .font(.largeTitle)
                        .bold()
                    
                    Text("\(restaurantCategories)")
                        .font(.title3)
                    
                    HStack {
                        ForEach(0..<restaurantScore) { element in
                            Image(systemName: "star.fill")
                                .foregroundColor(AppColors.primaryColor)
                        }
                        Text("/")
                        Text("\(restaurantPrice)")
                            .font(.title3)

                        Spacer()

                        Button {
                            guard let url = URL(string: "\(restaurantURL)") else { return Log.error.log("Bad Restaurant URL") }
                            openURL(url)
                        } label: {
                            Image(systemName: "info.square.fill")
                                .font(.title)
                        }

                    }

                    HStack {
                        Spacer()

                        AsyncImage(url: URL(string: restaurantImageURL)) { image in

                            guard let image = image.image else {
                                return Image(systemName: "multiply.circle")
                                    .resizable()
                            }

                            return image.resizable()
                        }
                        .scaledToFit()

                        Spacer()
                    }

                        VStack(alignment: .leading) {

                            ScrollView {

                                VStack(alignment: .leading) {

                                    RowView(headline: "Address",
                                            subheadline: "\(restaurantAddress1), \(restaurantCity)",
                                            imageName: "house")

                                    Divider()

                                    RowView(headline: "Phone",
                                            subheadline: "\(restaurantPhoneNumber)",
                                            imageName: "phone")
                                    .onTapGesture {
                                        UIApplication.shared.open(URL(string: "tel:\(restaurantPhoneNumber)")!)
                                    }

                                    Divider()

                                    RowView(headline: "Pickup Options",
                                            subheadline: optionsPickup ? "Pickup Available" : "Pickup Unavailable",
                                            imageName: "bag")

                                    Divider()

                                    RowView(headline: "Delivery Options",
                                            subheadline: optionsDelivery ? "Delivery Available" : "Delivery Unavailable",
                                            imageName: "car")

                                    Divider()

                                    RowView(headline: "Reservation Options",
                                            subheadline: optionsReservations ? "Reservations Available" : "Reservations Unavailable",
                                            imageName: "square.and.pencil")

                                }
                                .labeledContentStyle(Styles.LabeledContentCardStyling())
                            }

                        }

                    if (viewModel.currentlyInParty) {

                        HStack {
                            Spacer()
                            Group {

                                ForEach(1...5, id: \.self) { index in
                                    Star(showError: $showError, starValue: index, restaurantTitle: restaurantTitle, restaurantImageURL: restaurantImageURL)
                                }

                            }
                            .scaledToFit()
                            .frame(height: 50, alignment: .center)

                            Spacer()
                        }
                    }
                }
                .padding()
            }
            .alert(isPresented: $showError.status, content: {
                Alert(title: Text("Error"), message: Text("Error - \(showError.message)"))
            })

    }
}

extension CardView {

    private struct RowView:  View {

        let headline: String
        var subheadline: String = ""
        let imageName: String

        var body: some View {
            LabeledContent {
                Image(systemName: imageName)
                    .frame(maxWidth: 24)
                    .imageScale(.large)
                    .tint(Color.black)
            } label: {
                VStack(alignment: .leading) {
                    Text(headline)
                        .font(.headline)

                    Text(subheadline)
                        .font(.subheadline)
                }
            }
            .labeledContentStyle(Styles.LabeledContentCardStyling())
        }
    }
}

#Preview("Not in a Party") {
    CardView( in: YelpApiBusinessSearchProperties(id: "43543", alias: "harvey", name: "Mcdonalds", image_url: "", is_closed: true, url: "", review_count: 7, categories: [YelpApiBusinessDetails_Categories(alias: "test", title: "Bars")], rating: 5, coordinates: YelpApiBusinessDetails_Coordinates(latitude: 565.5, longitude: 45.5), transactions: ["delivery", "pickup"], price: "$$", location: YelpApiBusinessDetails_Location(address1: "155 W 51st St", address2: "Suite 1-", address3: "34343", city: "san carlos", zip_code: "454545", country: "america", state: "cali", display_address: ["test this"], cross_streets: "none"), phone: "650-339-0869", display_phone: "test", distance: 6565.56))
        .environment(PartyViewModel())
        .environment(Networking())
}

#Preview("In a Party") {
    let partyVM = PartyViewModel()
    let party = Party(username: "USERNAME01" ,partyID: UUID(uuidString: "6f31b771-0027-4407-8c97-07a7609d3e2b")!, partyMaxVotes: 1, partyName: "Party Name", partyCode: 123123 ,yelpURL: "YELP API ")
    partyVM.currentParty = party

    return CardView( in: YelpApiBusinessSearchProperties(id: "43543", alias: "harvey", name: "Mcdonalds", image_url: "", is_closed: true, url: "", review_count: 7, categories: [YelpApiBusinessDetails_Categories(alias: "test", title: "Bars")], rating: 5, coordinates: YelpApiBusinessDetails_Coordinates(latitude: 565.5, longitude: 45.5), transactions: ["delivery", "pickup"], price: "$$", location: YelpApiBusinessDetails_Location(address1: "155 W 51st St", address2: "Suite 1-", address3: "34343", city: "san carlos", zip_code: "454545", country: "america", state: "cali", display_address: ["test this"], cross_streets: "none"), phone: "650-339-0869", display_phone: "test", distance: 6565.56))
        .environment(partyVM)
        .environment(Networking())
}
