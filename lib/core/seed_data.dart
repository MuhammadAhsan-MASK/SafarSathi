import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../features/hotels/models/hotel_model.dart';
import '../features/restaurants/models/restaurant_model.dart';
import '../features/transport/models/transport_model.dart';

class SeedData {
  static Future<void> seedFirebase() async {
    final firestore = FirebaseFirestore.instance;

    // Hotels
    final hotels = [
      Hotel(
        id: 'serena_isb',
        name: 'Serena Hotel Islamabad',
        location: 'Islamabad, Khayaban-e-Suhrwardy',
        price: 45000,
        rating: 4.8,
        vendorId: 'premium_seed',
        imageUrl: 'https://images.unsplash.com/photo-1542314831-c6a4d2757271?w=800',
        websiteUrl: 'https://www.serenahotels.com/islamabad',
        description: 'Immerse yourself in the tranquility of our Moorish and Mughal architecture, set against the backdrop of the Margalla Hills. We offer 5-star services from the moment you step into the lobby.',
        typePrices: {'Executive Room': 45000, 'Diplomatic Suite': 80000, 'Presidential Suite': 150000},
      ),
      Hotel(
        id: 'pc_lahore',
        name: 'Pearl Continental Lahore',
        location: 'Lahore, Mall Road',
        price: 35000,
        rating: 4.7,
        vendorId: 'premium_seed',
        imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
        websiteUrl: 'https://www.pchotels.com/pclahore',
        description: 'Experience 5-star luxury at the Pearl Continental, offering unparalleled comfort and dining opulence in the heart of Lahore. Steps away from business and shopping districts.',
        typePrices: {'Standard Room': 35000, 'Deluxe Room': 50000, 'PC Suite': 95000},
      ),
      Hotel(
        id: 'luxus_grand',
        name: 'Luxus Grand Hotel',
        location: 'Lahore, Egerton Road',
        price: 25000,
        rating: 4.6,
        vendorId: 'premium_seed',
        imageUrl: 'https://images.unsplash.com/photo-1551882547-ff40c0dffe19?w=800',
        websiteUrl: 'https://luxusgrand.com/',
        description: 'Offering an indoor swimming pool and fitness center, located centrally inside the magical city of Lahore. Enjoy contemporary vibes mixed with rich hospitality.',
        typePrices: {'City View Room': 25000, 'Lake View Room': 35000, 'Luxury Suite': 55000},
      ),
    ];

    for (var h in hotels) {
      final docId = h.id;
      final docSnapshot = await firestore.collection('hotels').doc(docId).get();
      if (!docSnapshot.exists) {
        await firestore.collection('hotels').doc(docId).set(h.toMap());
      }
    }

    // Restaurants
    final restaurants = [
      Restaurant(
        id: 'monal_isb',
        name: 'The Monal Restaurant',
        cuisine: 'Pakistani & Continental',
        price: 3500,
        location: 'Margalla Hills, Islamabad',
        vendorId: 'premium_seed',
        imageUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800',
        websiteUrl: 'https://monal.com.pk/',
        typePrices: {
          'Reshmi Kebab': 1800,
          'Chicken Karahi (Half)': 2200,
          'Cheese Naan': 450,
          'Mint Margarita': 550
        }
      ),
      Restaurant(
        id: 'kolachi_khi',
        name: 'Kolachi Restaurant',
        cuisine: 'Seafood & BBQ',
        price: 4000,
        location: 'Do Darya, Karachi',
        vendorId: 'premium_seed',
        imageUrl: 'https://images.unsplash.com/photo-1550966871-3ed3cdb5ed0c?w=800',
        websiteUrl: 'https://kolachi.com.pk/',
        typePrices: {
          'Pani Puri Platter': 800,
          'Peshawari Karahi': 2800,
          'Malai Boti': 1500,
          'Hunza Kebab': 1700
        }
      ),
      Restaurant(
        id: 'howdy_lhr',
        name: 'Howdy',
        cuisine: 'Burgers & Fast Food',
        price: 1500,
        location: 'Johar Town, Lahore',
        vendorId: 'premium_seed',
        imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=800',
        websiteUrl: 'https://howdy.com.pk/',
        typePrices: {
          'Son of a Bun': 1100,
          'Tickle Pickle': 950,
          'Mac & Cheese Fries': 700,
          'Jalapeno Popper Burgers': 1250
        }
      ),
    ];

    for (var r in restaurants) {
      final docId = r.id;
      final docSnapshot = await firestore.collection('restaurants').doc(docId).get();
      if (!docSnapshot.exists) {
        await firestore.collection('restaurants').doc(docId).set(r.toMap());
      }
    }

    // Transport
    final transports = [
      TransportOption(
        id: 'daewoo_isb_lhr',
        type: 'Daewoo Express',
        route: 'ISD -> LHR',
        fare: 2500,
        time: '4.5 Hours',
        icon: Icons.directions_bus,
        vendorId: 'premium_seed',
        imageUrl: 'https://daewoo.com.pk/assets/images/logo.png',
        websiteUrl: 'https://daewoo.com.pk/',
        typePrices: {'Luxury Seat': 2500, 'Super Luxury Seat': 3200}
      ),
      TransportOption(
        id: 'faisal_movers',
        type: 'Faisal Movers',
        route: 'LHR -> KHI',
        fare: 6500,
        time: '18 Hours',
        icon: Icons.directions_bus,
        vendorId: 'premium_seed',
        imageUrl: 'https://faisalmovers.com/wp-content/uploads/2021/04/fm-logo.png',
        websiteUrl: 'https://faisalmovers.com/',
        typePrices: {'Business Class': 6500, 'Executive Class': 5800}
      ),
      TransportOption(
        id: 'serene_air',
        type: 'Serene Air',
        route: 'ISD -> KHI',
        fare: 35000,
        time: '2 Hours Flight',
        icon: Icons.flight,
        vendorId: 'premium_seed',
        imageUrl: 'https://www.sereneair.com/assets/images/logo.png',
        websiteUrl: 'https://www.sereneair.com/',
        typePrices: {'Economy Class': 35000, 'Serene Plus': 45000}
      ),
    ];

    for (var t in transports) {
      final docId = t.id;
      final docSnapshot = await firestore.collection('transport').doc(docId).get();
      if (!docSnapshot.exists) {
        await firestore.collection('transport').doc(docId).set(t.toMap());
      }
    }
  }
}
