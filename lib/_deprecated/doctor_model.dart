import 'package:flutter/material.dart';

class DoctorModel {
  final String id;
  final String name;
  final String title;
  final String image;
  final double rating;
  final int reviews;
  final String availability;
  final int booked;
  final int total;
  final bool isTopRated;
  final bool isMostBooked;
  final bool isOnlineConsultationAvailable;
  final String? location;
  final String? about;
  final List<String>? specializations;
  final List<Credential>? credentials;
  final String? experience;

  DoctorModel({
    this.id = '',
    required this.name,
    required this.title,
    required this.image,
    required this.rating,
    required this.reviews,
    required this.availability,
    required this.booked,
    required this.total,
    this.isTopRated = false,
    this.isMostBooked = false,
    this.isOnlineConsultationAvailable = false,
    this.location,
    this.about,
    this.specializations,
    this.credentials,
    this.experience,
  });
}

class Credential {
  final String title;
  final String institution;
  final IconData icon;

  Credential({
    required this.title,
    required this.institution,
    required this.icon,
  });
}
