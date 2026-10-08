import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:o2_clinic/common/widgets/common_snackbar.dart';
import '../../../../common/widgets/common_button.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';

import '../../../../common/controllers/contact_us_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:o2_clinic/common/widgets/common_loading_indicator.dart';
import 'package:o2_clinic/common/widgets/common_empty_state.dart';

class OurLocationScreen extends StatefulWidget {
  const OurLocationScreen({super.key});

  @override
  State<OurLocationScreen> createState() => _OurLocationScreenState();
}

class _OurLocationScreenState extends State<OurLocationScreen> {
  final ContactUsController controller = Get.put(ContactUsController());
  GoogleMapController? mapController;

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  bool _isDrawingRoute = false;

  final String _googleMapsApiKey = "AIzaSyBNKXPbgmEG6gxOrdVHkqDo1pWQXsRH0Sc";

  @override
  void initState() {
    super.initState();
  }

  void _onMapCreated(
    GoogleMapController c,
    LatLng clinicLocation,
    String name,
    String city,
  ) {
    mapController = c;
    setState(() {
      _markers.add(
        Marker(
          markerId: const MarkerId('clinic_location'),
          position: clinicLocation,
          infoWindow: InfoWindow(title: "We are here 📍", snippet: name),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    });

    // Automatically open the info window to show the message
    Future.delayed(const Duration(milliseconds: 500), () {
      mapController?.showMarkerInfoWindow(const MarkerId('clinic_location'));
    });
  }

  Future<void> _drawRoute(LatLng clinicLocation) async {
    setState(() {
      _isDrawingRoute = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      String lang = Get.locale?.languageCode ?? 'en';
      String errorTitle = lang == 'ar'
          ? 'عفواً'
          : (lang == 'he' ? 'שגיאה' : 'Error');
      String servicesDisabledMsg = lang == 'ar'
          ? 'يرجى تفعيل خدمات الموقع للاستمرار.'
          : (lang == 'he'
                ? 'אנא הפעל את שירותי המיקום כדי להמשיך.'
                : 'Please enable Location Services to continue.');
      String permissionDeniedMsg = lang == 'ar'
          ? 'لن نتمكن من الاستمرار حتى نحصل على صلاحيات الموقع منك.'
          : (lang == 'he'
                ? 'לא נוכל להמשיך עד שנקבל ממך הרשאות מיקום.'
                : 'We cannot proceed until we get location permissions from you.');

      if (!serviceEnabled) {
        CommonSnackbar.showError(title: errorTitle, message: servicesDisabledMsg);
        await Geolocator.openLocationSettings();
        setState(() => _isDrawingRoute = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          CommonSnackbar.showError(title: errorTitle, message: permissionDeniedMsg);
          setState(() => _isDrawingRoute = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        CommonSnackbar.showError(title: errorTitle, message: permissionDeniedMsg);
        await Geolocator.openAppSettings();
        setState(() => _isDrawingRoute = false);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        // ignore: deprecated_member_use
        desiredAccuracy: LocationAccuracy.high,
      );

      LatLng userLocation = LatLng(position.latitude, position.longitude);

      // Add user marker
      setState(() {
        _markers.add(
          Marker(
            markerId: const MarkerId('user_location'),
            position: userLocation,
            infoWindow: const InfoWindow(title: "My Location"),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue,
            ),
          ),
        );
      });

      final String urlStr =
          'https://maps.googleapis.com/maps/api/directions/json?origin=${position.latitude},${position.longitude}&destination=${clinicLocation.latitude},${clinicLocation.longitude}&mode=driving&key=$_googleMapsApiKey';

      final response = await http.get(Uri.parse(urlStr));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final status = data['status'];

        if (status == 'OK') {
          final points = data['routes'][0]['overview_polyline']['points'];
          List<LatLng> polylineCoordinates = _decodePolyline(points);

          Polyline polyline = Polyline(
            polylineId: const PolylineId("route"),
            color: AppColors.primary,
            points: polylineCoordinates,
            width: 5,
          );

          setState(() {
            _polylines.add(polyline);
          });

          LatLngBounds bounds;
          if (position.latitude > clinicLocation.latitude &&
              position.longitude > clinicLocation.longitude) {
            bounds = LatLngBounds(
              southwest: clinicLocation,
              northeast: userLocation,
            );
          } else if (position.longitude > clinicLocation.longitude) {
            bounds = LatLngBounds(
              southwest: LatLng(position.latitude, clinicLocation.longitude),
              northeast: LatLng(clinicLocation.latitude, position.longitude),
            );
          } else if (position.latitude > clinicLocation.latitude) {
            bounds = LatLngBounds(
              southwest: LatLng(clinicLocation.latitude, position.longitude),
              northeast: LatLng(position.latitude, clinicLocation.longitude),
            );
          } else {
            bounds = LatLngBounds(
              southwest: userLocation,
              northeast: clinicLocation,
            );
          }

          mapController?.animateCamera(
            CameraUpdate.newLatLngBounds(bounds, 100),
          );
        } else {
          final errorMessage = data['error_message'] ?? 'Unknown API Error';
          if (status == 'ZERO_RESULTS') {
            List<LatLng> polylineCoordinates = [userLocation, clinicLocation];
            Polyline polyline = Polyline(
              polylineId: const PolylineId("route"),
              color: AppColors.primary,
              points: polylineCoordinates,
              width: 5,
              patterns: [PatternItem.dash(30), PatternItem.gap(20)],
            );
            setState(() {
              _polylines.add(polyline);
            });

            LatLngBounds bounds;
            if (position.latitude > clinicLocation.latitude &&
                position.longitude > clinicLocation.longitude) {
              bounds = LatLngBounds(
                southwest: clinicLocation,
                northeast: userLocation,
              );
            } else if (position.longitude > clinicLocation.longitude) {
              bounds = LatLngBounds(
                southwest: LatLng(position.latitude, clinicLocation.longitude),
                northeast: LatLng(clinicLocation.latitude, position.longitude),
              );
            } else if (position.latitude > clinicLocation.latitude) {
              bounds = LatLngBounds(
                southwest: LatLng(clinicLocation.latitude, position.longitude),
                northeast: LatLng(position.latitude, clinicLocation.longitude),
              );
            } else {
              bounds = LatLngBounds(
                southwest: userLocation,
                northeast: clinicLocation,
              );
            }
            mapController?.animateCamera(
              CameraUpdate.newLatLngBounds(bounds, 100),
            );
            CommonSnackbar.showSuccess(title: 'Route Info', message: 'No roads found between your location and the clinic. Showing direct distance.');
          } else if (status == 'REQUEST_DENIED' ||
              status == 'OVER_QUERY_LIMIT') {
            _launchMapsUrl(clinicLocation.latitude, clinicLocation.longitude);
          } else {
            CommonSnackbar.showError(title: 'API Error', message: 'Directions API: $status. $errorMessage');
          }
        }
      } else {
        CommonSnackbar.showError(title: 'Error', message: 'Failed to fetch directions.');
      }
    } catch (e) {
      if (kIsWeb) {
        _launchMapsUrl(clinicLocation.latitude, clinicLocation.longitude);
      } else {
        CommonSnackbar.showError(title: 'Error', message: 'An error occurred while drawing the route.');
      }
    }

    setState(() {
      _isDrawingRoute = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              title: Text(
                AppLocalizations.of(context)!.ourLocation,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark ? AppColors.white : AppColors.colorFF1A2020,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Theme.of(context).brightness == Brightness.dark ? AppColors.white : AppColors.colorFF1A2020,
                ),
                onPressed: () => Get.back(),
              ),
              backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.brandBlue.withValues(alpha: 0.55) : AppColors.white.withValues(alpha: 0.55),
              elevation: 0,
              centerTitle: true,
            ),
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CommonLoadingIndicator(color: AppColors.primary),
          );
        }
        if (controller.error.value.isNotEmpty) {
          return Center(child: Text(controller.error.value));
        }

        final data = controller.contactUsData.value;
        if (data == null || data.location == null) {
          return const CommonEmptyState(title: "Location data not available");
        }

        final loc = data.location!;
        final center = LatLng(
          loc.coordinates.latitude,
          loc.coordinates.longitude,
        );

        return Stack(
          children: [
            // Full Screen Map
            GoogleMap(
              initialCameraPosition: CameraPosition(target: center, zoom: 16),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              markers: _markers,
              polylines: _polylines,
              onMapCreated: (c) => _onMapCreated(
                c,
                center,
                controller.getLocalizedText(loc.name, context),
                controller.getLocalizedText(loc.city, context),
              ),
            ),

            // Draggable Bottom Sheet
            DraggableScrollableSheet(
              initialChildSize: 0.38,
              minChildSize: 0.15,
              maxChildSize: 0.55,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(32),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF0F766E,
                            ).withValues(alpha: 0.15),
                            blurRadius: 24,
                            offset: const Offset(0, -8),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Drag Handle
                            Center(
                              child: Container(
                                width: 48,
                                height: 4,
                                margin: const EdgeInsets.only(bottom: 24),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).brightness == Brightness.dark ? AppColors.colorFF546868 : AppColors.colorFFE6ECEC,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),

                            Text(
                              controller.getLocalizedText(loc.name, context),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Theme.of(context).brightness == Brightness.dark ? AppColors.white : AppColors.colorFF1A2020,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.location_on_rounded,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    controller.getLocalizedText(
                                      loc.address,
                                      context,
                                    ),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context).brightness == Brightness.dark ? AppColors.white70 : AppColors.colorFF546868,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                _ContactButton(
                                  icon: Icons.phone_rounded,
                                  label: AppLocalizations.of(context)!.callUs,
                                  onTap: () =>
                                      _launchUrl('tel:${data.contact?.phone}'),
                                ),
                                const SizedBox(width: 16),
                                _ContactButton(
                                  icon: Icons.email_rounded,
                                  label: AppLocalizations.of(context)!.emailUs,
                                  onTap: () => _launchUrl(
                                    'mailto:${data.contact?.email}',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: CommonButton(
                                onPressed: _isDrawingRoute
                                    ? null
                                    : () => _drawRoute(center),
                                text: AppLocalizations.of(context)!.takeMeThere,
                                type: CommonButtonType.primary,
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.white,
                                borderRadius: BorderRadius.circular(16),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                elevation: 0,
                                isLoading: _isDrawingRoute,
                                icon: Icons.directions_rounded,
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16), // Bottom padding
                          ],
                        ),
                      ),
                    );
                  },
            ),
          ],
        );
      }),
    );
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      poly.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return poly;
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      CommonSnackbar.showError(title: 'Error', message: 'Could not launch action');
    }
  }

  Future<void> _launchMapsUrl(double lat, double lng) async {
    final String googleMapsUrl =
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';
    final Uri url = Uri.parse(googleMapsUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      CommonSnackbar.showError(title: 'Error', message: 'Could not open maps');
    }
  }
}

class _ContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ContactButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Theme.of(context).brightness == Brightness.dark ? AppColors.white : AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark ? AppColors.white : AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
