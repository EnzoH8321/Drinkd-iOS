//
//  CardView.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/22/21.
//

//245,31,32

import SwiftUI

struct CardView: View {
    
    private enum CardPadding: CGFloat{
        case smallPadding = 4
        case mediumPadding = 12
    }
    
    @State private var scrollDimensionminY = 0.0
    @State private var scrollDimensionmaxY = 0.0
    @State private var frame = CGRect(x: 0, y: 0, width: 0, height: 0)
    @State private var offset = CGSize.zero
    @EnvironmentObject var viewModel: drinkdViewModel
    @Environment(\.openURL) var openURL

    var restaurantTitle: String
    var restaurantCategories: String
    var restaurantScore: Int
    var restaurantPrice: String
    var restaurantImage: String
    var restaurantCity: String
    var restaurantAddress1: String
    var restaurantAddress2: String?
    var restaurantPhoneNumber: String
    var restaurantZipCode: String
    var restaurantState: String
    var restaurantURL: String
    var optionsDelivery: Bool = false
    var optionsPickup: Bool = false
    var optionsReservations: Bool = false
    
    
    //We use optionals because the API can return null for some properties
    init(in restaurantDetails: YelpApiBusinessSearchProperties, forView viewModel: drinkdViewModel) {
        
        let verifiedRestaurantScore = restaurantDetails.rating ?? 0
        
        self.restaurantTitle = restaurantDetails.name ?? "Name not found"
        self.restaurantCategories = restaurantDetails.categories?[0].title ?? "None"
        self.restaurantScore =  verifiedRestaurantScore > 5 ? 5 : Int(verifiedRestaurantScore)
        self.restaurantPrice = restaurantDetails.price ?? "Not Found"
        self.restaurantImage = restaurantDetails.image_url ?? "Not Found"
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
        GeometryReader { geo in
            
            ZStack {
                RoundedRectangle(cornerRadius: CardSpecificStyle.cornerRadius)
                    .fill(Color.white)
                    .overlay(RoundedRectangle(cornerRadius: CardSpecificStyle.cornerRadius).strokeBorder(Color(red: 221/255, green: 221/255, blue: 221/255), lineWidth: 1))
                
                
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
                    }
                    
                    RemoteImageLoader(url: "\(restaurantImage)")
                        
                    
                    HStack {
                        GeometryReader { geo in
                            
                            let minY = geo.frame(in: CoordinateSpace.global).minY
                            let maxY = geo.frame(in: CoordinateSpace.global).maxY
                            let frame = geo.frame(in: CoordinateSpace.global)
                            
                            VStack(alignment: .leading) {
                                Text("About")
                                    .font(.title2)
                                    .bold()
                                
                                ScrollView {
                                    
                                    VStack(alignment: .leading) {
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text("Address")
                                                    .font(.headline)
                                                
                                                Text("\(restaurantAddress1), \(restaurantCity)")
                                                    .font(.subheadline)
                                            }
                                            
                                            Spacer()
                                            Image(systemName: "house")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 24)
                                            
                                        }
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text("Phone")
                                                    .font(.headline)
                                                Text("\(restaurantPhoneNumber)")
                                                    .font(.subheadline)
                                            }
                                            Spacer()
                                            Image(systemName: "phone")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 24)
                                        }
                                        .onTapGesture {
                                            
                                            UIApplication.shared.open(URL(string: "tel:\(restaurantPhoneNumber)")!)
                                        }
                                        //
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text("Pickup Options")
                                                    .font(.headline)
                                                Text(optionsPickup ? "Pickup Available" : "Pickup Unavailable")
                                                    .font(.subheadline)
                                                
                                            }
                                            Spacer()
                                            Image(systemName: "bag")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 24)
                                        }
                                        
                                        
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text("Delivery Options")
                                                    .font(.headline)
                                                Text(optionsDelivery ? "Delivery Available" : "Delivery Unavailable")
                                                    .font(.subheadline)
                                            }
                                            Spacer()
                                            Image(systemName: "car")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 24)
                                            
                                        }
                                        
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text("Reservation Options")
                                                    .font(.headline)
                                                Text(optionsReservations ? "Reservations Available" : "Reservations Unavailable")
                                                    .font(.subheadline)
                                            }
                                            
                                            Spacer()
                                            Image(systemName: "square.and.pencil")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 24)
                                            
                                        }
                                        
                                        if (!viewModel.currentlyInParty) {
                                            HStack {
                                                Spacer()
                                                noPartyYelpButton(buttonName: "doc.plaintext", yelpURL: "\(restaurantURL)")
                                                    .padding(.top, 20)
                                                Spacer()
                                            }
                                            
                                        }
                                    }
                                }
                                
                            }
                            .onAppear {
                                self.scrollDimensionminY = minY
                                self.scrollDimensionmaxY = maxY
                                self.frame = frame
                            }
                        }
                        
                    }
                    
                    if (viewModel.currentlyInParty) {
                        // Button H-Stack
                        HStack {
                            Spacer()
                            // Submit Button
                            Button {
                                submitRestaurantScore(viewModel: viewModel)
                            } label: {
                                Text("Submit")
                                    .bold()
                            }
                            // More Info Button
                            Button {
                                guard let url = URL(string: "\(restaurantURL)") else { return print("BAD URL") }
                                openURL(url)
                            } label: {
                                Text("More Info")
                                    .bold()
                            }

                            Spacer()
                        }
                        .buttonStyle(viewModel.isPhone ? CardInfoButton(deviceType: .phone) : CardInfoButton(deviceType: .ipad))

                        HStack {
                            Spacer()
                            Group {
                                Star( starValue: 1)
                                Star( starValue: 2)
                                Star( starValue: 3)
                                Star( starValue: 4)
                                Star( starValue: 5)
                            }
                            .scaledToFit()
                            .frame(height: 50, alignment: .center)
                            Spacer()
                        }
                    }
                }
                .padding(.all, CardPadding.mediumPadding.rawValue)
            }
            .rotationEffect(.degrees(Double(offset.width / 5 )))
            .offset(x: offset.width * 5, y: 0)
            .opacity(2 - Double(abs(offset.width / 50)))
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        //TODO: currently not able to get accurate frame of scrollview. Find a solution without having to add extra padding
                        if (gesture.startLocation.y + 60 > self.scrollDimensionminY) {return}
                        
                        self.offset = gesture.translation
                    }
                
                    .onEnded { _ in
                        if abs(self.offset.width) > 100 {
                            // remove the card
                            viewModel.updateRestaurantList()
                            viewModel.whenCardIsDraggedFromView()
                            viewModel.setCurrentTopCardScoreToZero()
                            viewModel.emptyTopBarList()
                            
                        } else {
                            self.offset = .zero
                        }
                    }
            )
        }
    
    }
}

//Button that goes to the yelp website.
struct noPartyYelpButton: View {
    @Environment(\.openURL) var openURL
    
    let deviceIsPhone = UIDevice.current.userInterfaceIdiom == .phone
    let buttonName: String
    let yelpURL: String
    
    
    var body: some View {
        Button {
            guard let url = URL(string: "\(yelpURL)") else {
                return print("BAD URL")
            }
            openURL(url)
        } label: {
            Text("More Info")
                .bold()
            
        }
        .buttonStyle(deviceIsPhone ? CardInfoButton(deviceType: .phone) : CardInfoButton(deviceType: .ipad))
    }
}

struct CardView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        CardView(in: YelpApiBusinessSearchProperties(id: "43543", alias: "harvey", name: "Mcdonalds", image_url: "", is_closed: true, url: "", review_count: 7, categories: [YelpApiBusinessDetails_Categories(alias: "test", title: "Bars")], rating: 5, coordinates: YelpApiBusinessDetails_Coordinates(latitude: 565.5, longitude: 45.5), transactions: ["delivery", "pickup"], price: "$$", location: YelpApiBusinessDetails_Location(address1: "155 W 51st St", address2: "Suite 1-", address3: "34343", city: "san carlos", zip_code: "454545", country: "america", state: "cali", display_address: ["test this"], cross_streets: "none"), phone: "650-339-0869", display_phone: "test", distance: 6565.56), forView: drinkdViewModel()).environmentObject(drinkdViewModel())
    }
    
}

struct CardView_Previews_Online: PreviewProvider {
    
    static var previews: some View {
        
        let mockVM = drinkdViewModel()
        mockVM.model.setCurrentToPartyTrue()
        
        return  CardView(in: YelpApiBusinessSearchProperties(id: "43543", alias: "harvey", name: "Mcdonalds", image_url: "", is_closed: true, url: "", review_count: 7, categories: [YelpApiBusinessDetails_Categories(alias: "test", title: "Bars")], rating: 5, coordinates: YelpApiBusinessDetails_Coordinates(latitude: 565.5, longitude: 45.5), transactions: ["delivery", "pickup"], price: "454", location: YelpApiBusinessDetails_Location(address1: "4545", address2: "4545", address3: "34343", city: "san carlos", zip_code: "454545", country: "america", state: "cali", display_address: ["test this"], cross_streets: "none"), phone: "test", display_phone: "test", distance: 6565.56), forView: mockVM).environmentObject(mockVM)
    }
    
}
