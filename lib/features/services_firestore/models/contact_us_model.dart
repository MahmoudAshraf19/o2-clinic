import 'package:cloud_firestore/cloud_firestore.dart';

class LocalizedContactString {
  final String ar;
  final String en;
  final String he;

  LocalizedContactString({
    required this.ar,
    required this.en,
    required this.he,
  });

  factory LocalizedContactString.fromMap(Map<String, dynamic> map) {
    return LocalizedContactString(
      ar: map['ar'] ?? '',
      en: map['en'] ?? '',
      he: map['he'] ?? '',
    );
  }
}

class ContactUsCoordinates {
  final double latitude;
  final double longitude;
  final GeoPoint? geoPoint;

  ContactUsCoordinates({
    required this.latitude,
    required this.longitude,
    this.geoPoint,
  });

  factory ContactUsCoordinates.fromMap(Map<String, dynamic> map) {
    return ContactUsCoordinates(
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      geoPoint: map['geoPoint'] as GeoPoint?,
    );
  }
}

class ContactUsLocation {
  final LocalizedContactString name;
  final LocalizedContactString address;
  final LocalizedContactString city;
  final LocalizedContactString country;
  final ContactUsCoordinates coordinates;
  final String googleMapsUrl;

  ContactUsLocation({
    required this.name,
    required this.address,
    required this.city,
    required this.country,
    required this.coordinates,
    required this.googleMapsUrl,
  });

  factory ContactUsLocation.fromMap(Map<String, dynamic> map) {
    return ContactUsLocation(
      name: LocalizedContactString.fromMap(map['name'] ?? {}),
      address: LocalizedContactString.fromMap(map['address'] ?? {}),
      city: LocalizedContactString.fromMap(map['city'] ?? {}),
      country: LocalizedContactString.fromMap(map['country'] ?? {}),
      coordinates: ContactUsCoordinates.fromMap(map['coordinates'] ?? {}),
      googleMapsUrl: map['google_maps_url'] ?? '',
    );
  }
}

class ContactUsContact {
  final String phone;
  final String email;

  ContactUsContact({
    required this.phone,
    required this.email,
  });

  factory ContactUsContact.fromMap(Map<String, dynamic> map) {
    return ContactUsContact(
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
    );
  }
}

class ContactUsSocial {
  final String facebook;
  final String instagram;

  ContactUsSocial({
    required this.facebook,
    required this.instagram,
  });

  factory ContactUsSocial.fromMap(Map<String, dynamic> map) {
    return ContactUsSocial(
      facebook: map['facebook'] ?? '',
      instagram: map['instagram'] ?? '',
    );
  }
}

class ContactUsModel {
  final ContactUsLocation? location;
  final ContactUsContact? contact;
  final ContactUsSocial? social;

  ContactUsModel({
    this.location,
    this.contact,
    this.social,
  });

  factory ContactUsModel.fromMap(Map<String, dynamic> map) {
    return ContactUsModel(
      location: map['location'] != null ? ContactUsLocation.fromMap(map['location']) : null,
      contact: map['contact'] != null ? ContactUsContact.fromMap(map['contact']) : null,
      social: map['social'] != null ? ContactUsSocial.fromMap(map['social']) : null,
    );
  }
}
