import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:google_maps_webservice/places.dart';

// class Place {
//   String streetNumber;
//   String street;
//   String city;
//   String zipCode;

//   Place({
//     this.streetNumber,
//     this.street,
//     this.city,
//     this.zipCode,
//   });

//    @override
//    String toString() {
//      return 'Place(streetNumber: $streetNumber, street: $street, city: $city, zipCode: $zipCode)';
//    }
// }

class Suggestion {
  final String placeId;
  final String description;


  Suggestion(this.placeId, this.description);

}

class Nearby {
  final String placeId;
  final String photo;

  Nearby(this.placeId, this.photo);

  @override
  String toString() {
    return 'Nearby(placeId: $placeId, photo: $photo)';
  }
}

class PlaceApiProvider {
  final client = Client();

  PlaceApiProvider(this.sessionToken);

  final sessionToken;

  static final String androidKey = 'AIzaSyDPFVBgZDnp7Ee-6y8K5vPK_8kTOGfYAZ4';
  static final String iosKey = 'AIzaSyDPFVBgZDnp7Ee-6y8K5vPK_8kTOGfYAZ4';
  final apiKey = Platform.isAndroid ? androidKey : iosKey;

  Future<List<Suggestion>> fetchSuggestions(String input, String lang) async {
    final request =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?'
        'input=$input' // input type
        '&types=address' // get address of particular area
        '&language=$lang' // current location language
        '&components=country:in' // search location 'India' exclusive
        '&key=$apiKey' // Google places API Key
        '&sessiontoken=$sessionToken'; // session token as authorization {billing optimization}
    final response = await client.get(Uri.parse(request));
    Map<dynamic, dynamic> res = json.decode(response.body);

    if (response.statusCode == 200) {
      final result = json.decode(response.body);

      //final res = json.decode(result['place_id']);
      if (result['status'] == 'OK') {
        // compose suggestions in a list
        print(result['place_id']);
        return result['predictions'].map<Suggestion>(
          (p) {
            return Suggestion(
              p['place_id'],
              p['description'],

            );
          },
        ).toList();
      }
      if (result['status'] == 'ZERO_RESULTS') {
        return [];
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }

  Future<List<dynamic>> fetchNearby(String placeId) async {
 String request2 =
      "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=AIzaSyDPFVBgZDnp7Ee-6y8K5vPK_8kTOGfYAZ4";

  final response2 = await client.get(Uri.parse(request2));
  Map<dynamic, dynamic> res2 = json.decode(response2.body);
  double lat = res2['result']['geometry']['location']['lat'];
  double long = res2['result']['geometry']['location']['lng'];
    
    var radius = 10000; // just over 6.2 miles radius
    final request =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?'
        'location=$lat,$long'
        '&radius=$radius'
        '&type=restaurant%20point_of_interest'
        '&key=$apiKey';
    // 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?'
    // 'location=$latitude,$longitude' // get nearby places using placeId
    // '&radius=$radius' // radius from users location to produce results with their proximity
    // '&type=restaurant%20point_of_interest' // type specification
    // '&keyword=food%20dinner%20dining' // keywords for tailored results
    // '&photo?maxwidth=400&photo_reference=photo_reference' // get photos
    // '&key=$apiKey' // google places API key
    // '&sessiontoken=$sessionToken' // session token
    // '&rankby=prominence'; // keyword up to 50,000 meters
    final response = await client.get(Uri.parse(request));

    // Condition to get required data from 'response'
    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        final components = result['results'] as List<dynamic>;

        return Future.value(components);
      }
      return [];
    } else {
      throw Exception('Failed to fetch nearby places');
    }
  }

  // Future<Place> getPlaceDetailFromId(String placeId) async {
  //   final request =
  //       'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=address_component&key=$apiKey&sessiontoken=$sessionToken';
  //   final response = await client.get(Uri.parse(request));

  //   if (response.statusCode == 200) {
  //     final result = json.decode(response.body);
  //     if (result['status'] == 'OK') {
  //       final components =
  //           result['result']['address_components'] as List<dynamic>;
  //       // build result
  //       final place = Place();
  //       components.forEach((c) {
  //         final List type = c['types'];
  //         if (type.contains('street_number')) {
  //           place.streetNumber = c['long_name'];
  //         }
  //         if (type.contains('route')) {
  //           place.street = c['long_name'];
  //         }
  //         if (type.contains('locality')) {
  //           place.city = c['long_name'];
  //         }
  //         if (type.contains('postal_code')) {
  //           place.zipCode = c['long_name'];
  //         }
  //       });
  //       return place;
  //     }
  //     throw Exception(result['error_message']);
  //   } else {
  //     throw Exception('Failed to fetch suggestion');
  //   }
  // }
}
