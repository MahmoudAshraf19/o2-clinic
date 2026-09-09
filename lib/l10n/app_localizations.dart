import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_he.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('he'),
  ];

  /// No description provided for @onlineConsultation.
  ///
  /// In en, this message translates to:
  /// **'Online Consultation'**
  String get onlineConsultation;

  /// No description provided for @mustContactDoctorWarning.
  ///
  /// In en, this message translates to:
  /// **'* You must contact and chat with the doctor before booking to confirm details.'**
  String get mustContactDoctorWarning;

  /// No description provided for @bookingSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Booking sent to doctor and will be confirmed. You will receive a notification with the result.'**
  String get bookingSentSuccess;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @o2Clinic.
  ///
  /// In en, this message translates to:
  /// **'O2 Clinic'**
  String get o2Clinic;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @doctors.
  ///
  /// In en, this message translates to:
  /// **'Doctors'**
  String get doctors;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @book.
  ///
  /// In en, this message translates to:
  /// **'BOOK'**
  String get book;

  /// No description provided for @selectCountry.
  ///
  /// In en, this message translates to:
  /// **'Select Country'**
  String get selectCountry;

  /// No description provided for @searchCountry.
  ///
  /// In en, this message translates to:
  /// **'Search country...'**
  String get searchCountry;

  /// No description provided for @allDoctors.
  ///
  /// In en, this message translates to:
  /// **'All doctors'**
  String get allDoctors;

  /// No description provided for @chooseYourSpecialist.
  ///
  /// In en, this message translates to:
  /// **'Choose your specialist'**
  String get chooseYourSpecialist;

  /// No description provided for @noDoctorsFound.
  ///
  /// In en, this message translates to:
  /// **'No doctors found'**
  String get noDoctorsFound;

  /// No description provided for @yearsExp.
  ///
  /// In en, this message translates to:
  /// **'Years Exp.'**
  String get yearsExp;

  /// No description provided for @availableDays.
  ///
  /// In en, this message translates to:
  /// **'Available Days'**
  String get availableDays;

  /// No description provided for @trusted.
  ///
  /// In en, this message translates to:
  /// **'Trusted'**
  String get trusted;

  /// No description provided for @noAvailabilityProvided.
  ///
  /// In en, this message translates to:
  /// **'No availability provided.'**
  String get noAvailabilityProvided;

  /// No description provided for @bookAppointment.
  ///
  /// In en, this message translates to:
  /// **'Book Appointment'**
  String get bookAppointment;

  /// No description provided for @viewProfile.
  ///
  /// In en, this message translates to:
  /// **'View Profile'**
  String get viewProfile;

  /// No description provided for @searchDoctorSpecialty.
  ///
  /// In en, this message translates to:
  /// **'Search doctor, specialty...'**
  String get searchDoctorSpecialty;

  /// No description provided for @myAppointments.
  ///
  /// In en, this message translates to:
  /// **'My Appointments'**
  String get myAppointments;

  /// No description provided for @manageYourBookingsEasily.
  ///
  /// In en, this message translates to:
  /// **'Manage your bookings easily'**
  String get manageYourBookingsEasily;

  /// No description provided for @noUpcomingAppointment.
  ///
  /// In en, this message translates to:
  /// **'No upcoming appointment'**
  String get noUpcomingAppointment;

  /// No description provided for @yourNextBookingWillAppear.
  ///
  /// In en, this message translates to:
  /// **'Your next booking will appear here automatically.'**
  String get yourNextBookingWillAppear;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @directions.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get directions;

  /// No description provided for @searchDoctorServiceClinic.
  ///
  /// In en, this message translates to:
  /// **'Search doctor, service, clinic...'**
  String get searchDoctorServiceClinic;

  /// No description provided for @noAppointmentsFound.
  ///
  /// In en, this message translates to:
  /// **'No appointments found'**
  String get noAppointmentsFound;

  /// No description provided for @tryChangingTheFilterOr.
  ///
  /// In en, this message translates to:
  /// **'Try changing the filter or search keyword.'**
  String get tryChangingTheFilterOr;

  /// No description provided for @signInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get signInToContinue;

  /// No description provided for @pleaseLoginOrCreateAn.
  ///
  /// In en, this message translates to:
  /// **'Please login or create an account first to see and manage your appointments securely.'**
  String get pleaseLoginOrCreateAn;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @appointmentInfo.
  ///
  /// In en, this message translates to:
  /// **'Appointment Info'**
  String get appointmentInfo;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @patient.
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get patient;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @clinic.
  ///
  /// In en, this message translates to:
  /// **'Clinic'**
  String get clinic;

  /// No description provided for @floor.
  ///
  /// In en, this message translates to:
  /// **'Floor'**
  String get floor;

  /// No description provided for @room.
  ///
  /// In en, this message translates to:
  /// **'Room'**
  String get room;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @method.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get method;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @meta.
  ///
  /// In en, this message translates to:
  /// **'Meta'**
  String get meta;

  /// No description provided for @source.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get source;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @bookingId.
  ///
  /// In en, this message translates to:
  /// **'Booking ID'**
  String get bookingId;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back 👋'**
  String get welcomeBack;

  /// No description provided for @loginToContinueYourMedical.
  ///
  /// In en, this message translates to:
  /// **'Login to continue your medical journey'**
  String get loginToContinueYourMedical;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @dontHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAnAccount;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @editing.
  ///
  /// In en, this message translates to:
  /// **'Editing'**
  String get editing;

  /// No description provided for @updatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Updated Successfully! 🎉'**
  String get updatedSuccessfully;

  /// No description provided for @idUsername.
  ///
  /// In en, this message translates to:
  /// **'ID / Username'**
  String get idUsername;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @idUsernameAndEmailAre.
  ///
  /// In en, this message translates to:
  /// **'ID, Username, and Email are locked.'**
  String get idUsernameAndEmailAre;

  /// No description provided for @booking.
  ///
  /// In en, this message translates to:
  /// **'Booking'**
  String get booking;

  /// No description provided for @selectDateTime.
  ///
  /// In en, this message translates to:
  /// **'Select Date & Time'**
  String get selectDateTime;

  /// No description provided for @noAvailableDatesForThis.
  ///
  /// In en, this message translates to:
  /// **'No available dates for this doctor'**
  String get noAvailableDatesForThis;

  /// No description provided for @capacityStatus.
  ///
  /// In en, this message translates to:
  /// **'Capacity Status'**
  String get capacityStatus;

  /// No description provided for @bookingConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Booking Confirmed!'**
  String get bookingConfirmed;

  /// No description provided for @yourAppointmentHasBeenScheduled.
  ///
  /// In en, this message translates to:
  /// **'Your appointment has been scheduled successfully.'**
  String get yourAppointmentHasBeenScheduled;

  /// No description provided for @confirmation.
  ///
  /// In en, this message translates to:
  /// **'Confirmation'**
  String get confirmation;

  /// No description provided for @reviewAppointmentDetails.
  ///
  /// In en, this message translates to:
  /// **'Review Appointment Details'**
  String get reviewAppointmentDetails;

  /// No description provided for @o2ClinicMainBranchnfloor4.
  ///
  /// In en, this message translates to:
  /// **'O2 Clinic - Main Branch\\nFloor 4'**
  String get o2ClinicMainBranchnfloor4;

  /// No description provided for @totalPayment.
  ///
  /// In en, this message translates to:
  /// **'Total Payment'**
  String get totalPayment;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @radiologyDepartment.
  ///
  /// In en, this message translates to:
  /// **'Radiology Department'**
  String get radiologyDepartment;

  /// No description provided for @noAvailableDates.
  ///
  /// In en, this message translates to:
  /// **'No available dates'**
  String get noAvailableDates;

  /// No description provided for @yourRadiologyAppointmentHasBeen.
  ///
  /// In en, this message translates to:
  /// **'Your radiology appointment has been scheduled successfully.'**
  String get yourRadiologyAppointmentHasBeen;

  /// No description provided for @o2ClinicMainBranchnfloor1.
  ///
  /// In en, this message translates to:
  /// **'O2 Clinic - Main Branch\\nFloor 1 - Radiology Center'**
  String get o2ClinicMainBranchnfloor1;

  /// No description provided for @services.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get services;

  /// No description provided for @chooseTheMedicalServiceYou.
  ///
  /// In en, this message translates to:
  /// **'Choose the medical service you need'**
  String get chooseTheMedicalServiceYou;

  /// No description provided for @noServicesFound.
  ///
  /// In en, this message translates to:
  /// **'No services found'**
  String get noServicesFound;

  /// No description provided for @ctScan.
  ///
  /// In en, this message translates to:
  /// **'CT Scan'**
  String get ctScan;

  /// No description provided for @chooseScanAreas.
  ///
  /// In en, this message translates to:
  /// **'Choose scan areas'**
  String get chooseScanAreas;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'SELECTED'**
  String get selected;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @chooseYourPreferredDateAnd.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred date and appointment time'**
  String get chooseYourPreferredDateAnd;

  /// No description provided for @timeSlots.
  ///
  /// In en, this message translates to:
  /// **'Time Slots'**
  String get timeSlots;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @yourImagingAppointmentHasBeen.
  ///
  /// In en, this message translates to:
  /// **'Your imaging appointment has been successfully booked.'**
  String get yourImagingAppointmentHasBeen;

  /// No description provided for @continueBooking.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueBooking;

  /// No description provided for @confirmImaging.
  ///
  /// In en, this message translates to:
  /// **'Confirm Imaging'**
  String get confirmImaging;

  /// No description provided for @o2ImagingCenterDowntownHubn124.
  ///
  /// In en, this message translates to:
  /// **'O2 Imaging Center, Downtown Hub, #124'**
  String get o2ImagingCenterDowntownHubn124;

  /// No description provided for @imagingConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Imaging Confirmed!'**
  String get imagingConfirmed;

  /// No description provided for @radiology.
  ///
  /// In en, this message translates to:
  /// **'RADIOLOGY'**
  String get radiology;

  /// No description provided for @advancedDiagnosticImaging.
  ///
  /// In en, this message translates to:
  /// **'Advanced Diagnostic Imaging'**
  String get advancedDiagnosticImaging;

  /// No description provided for @ultrasound.
  ///
  /// In en, this message translates to:
  /// **'Ultrasound'**
  String get ultrasound;

  /// No description provided for @selectUltrasoundType.
  ///
  /// In en, this message translates to:
  /// **'Select Ultrasound Type'**
  String get selectUltrasoundType;

  /// No description provided for @noSelection.
  ///
  /// In en, this message translates to:
  /// **'No Selection'**
  String get noSelection;

  /// No description provided for @noUltrasoundTypesFound.
  ///
  /// In en, this message translates to:
  /// **'No Ultrasound Types Found'**
  String get noUltrasoundTypesFound;

  /// No description provided for @pleaseCheckTheFirestoreDocument.
  ///
  /// In en, this message translates to:
  /// **'Please check the Firestore document'**
  String get pleaseCheckTheFirestoreDocument;

  /// No description provided for @chooseTheRequiredDiagnosticProcedure.
  ///
  /// In en, this message translates to:
  /// **'Choose the required diagnostic procedure'**
  String get chooseTheRequiredDiagnosticProcedure;

  /// No description provided for @failedToLoadUltrasoundData.
  ///
  /// In en, this message translates to:
  /// **'Failed to load Ultrasound data'**
  String get failedToLoadUltrasoundData;

  /// No description provided for @bookingSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Booking Successful'**
  String get bookingSuccessful;

  /// No description provided for @noXrayCategoriesFound.
  ///
  /// In en, this message translates to:
  /// **'No X-Ray categories found'**
  String get noXrayCategoriesFound;

  /// No description provided for @thisCategoryDoesNotHave.
  ///
  /// In en, this message translates to:
  /// **'This category doesn\'t have any services yet.'**
  String get thisCategoryDoesNotHave;

  /// No description provided for @failedToLoadXrayData.
  ///
  /// In en, this message translates to:
  /// **'Failed to load X-Ray data'**
  String get failedToLoadXrayData;

  /// No description provided for @loginRequired.
  ///
  /// In en, this message translates to:
  /// **'Login required'**
  String get loginRequired;

  /// No description provided for @youMustLogInFirst.
  ///
  /// In en, this message translates to:
  /// **'You must log in first to book an appointment.'**
  String get youMustLogInFirst;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @noDoctorsAvailableForThis.
  ///
  /// In en, this message translates to:
  /// **'No doctors available for this specialty right now.'**
  String get noDoctorsAvailableForThis;

  /// No description provided for @highQualityMedicalService.
  ///
  /// In en, this message translates to:
  /// **'High quality medical service'**
  String get highQualityMedicalService;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @service.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get service;

  /// No description provided for @doctor.
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get doctor;

  /// No description provided for @selectedServices.
  ///
  /// In en, this message translates to:
  /// **'Selected Services'**
  String get selectedServices;

  /// No description provided for @needHelpWithInquiriesComplaints.
  ///
  /// In en, this message translates to:
  /// **'Need help with inquiries or complaints?'**
  String get needHelpWithInquiriesComplaints;

  /// No description provided for @photo.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get photo;

  /// No description provided for @sendAnImageFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Send an image from gallery'**
  String get sendAnImageFromGallery;

  /// No description provided for @video.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get video;

  /// No description provided for @sendAVideoFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Send a video from gallery'**
  String get sendAVideoFromGallery;

  /// No description provided for @voiceNote.
  ///
  /// In en, this message translates to:
  /// **'Voice note'**
  String get voiceNote;

  /// No description provided for @recordAndSendVoice.
  ///
  /// In en, this message translates to:
  /// **'Record and send voice note'**
  String get recordAndSendVoice;

  /// No description provided for @compressingMedia.
  ///
  /// In en, this message translates to:
  /// **'Compressing media...'**
  String get compressingMedia;

  /// No description provided for @typeAMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeAMessage;

  /// No description provided for @recording.
  ///
  /// In en, this message translates to:
  /// **'Recording'**
  String get recording;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @lastVisit.
  ///
  /// In en, this message translates to:
  /// **'Last Visit'**
  String get lastVisit;

  /// No description provided for @o2Vitality.
  ///
  /// In en, this message translates to:
  /// **'O2 Vitality'**
  String get o2Vitality;

  /// No description provided for @bannersUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Banners unavailable'**
  String get bannersUnavailable;

  /// No description provided for @pleaseTryAgainLater.
  ///
  /// In en, this message translates to:
  /// **'Please try again later'**
  String get pleaseTryAgainLater;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noActiveBanners.
  ///
  /// In en, this message translates to:
  /// **'No active banners'**
  String get noActiveBanners;

  /// No description provided for @newPromotionsWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'New promotions will appear here'**
  String get newPromotionsWillAppearHere;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @specialtiesClinics.
  ///
  /// In en, this message translates to:
  /// **'Specialties & Clinics'**
  String get specialtiesClinics;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @text200Pm500Pm.
  ///
  /// In en, this message translates to:
  /// **'2:00 PM – 5:00 PM'**
  String get text200Pm500Pm;

  /// No description provided for @text610SlotsFilled.
  ///
  /// In en, this message translates to:
  /// **'6/10 slots filled'**
  String get text610SlotsFilled;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @nextSlot.
  ///
  /// In en, this message translates to:
  /// **'Next Slot'**
  String get nextSlot;

  /// No description provided for @topDoctors.
  ///
  /// In en, this message translates to:
  /// **'Top Doctors'**
  String get topDoctors;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @upcomingDoctors.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Doctors'**
  String get upcomingDoctors;

  /// No description provided for @featuredDoctor.
  ///
  /// In en, this message translates to:
  /// **'FEATURED DOCTOR'**
  String get featuredDoctor;

  /// No description provided for @chestDiseases.
  ///
  /// In en, this message translates to:
  /// **'Chest Diseases'**
  String get chestDiseases;

  /// No description provided for @exceptionalCareFromLeadingSpecialists.
  ///
  /// In en, this message translates to:
  /// **'Exceptional care from leading specialists'**
  String get exceptionalCareFromLeadingSpecialists;

  /// No description provided for @doctorProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get doctorProfile;

  /// No description provided for @cityMedicalCenter.
  ///
  /// In en, this message translates to:
  /// **'City Medical Center'**
  String get cityMedicalCenter;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @specializations.
  ///
  /// In en, this message translates to:
  /// **'Specializations'**
  String get specializations;

  /// No description provided for @availability.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get availability;

  /// No description provided for @fullProfile.
  ///
  /// In en, this message translates to:
  /// **'Full Profile'**
  String get fullProfile;

  /// No description provided for @bookNow.
  ///
  /// In en, this message translates to:
  /// **'Book Now'**
  String get bookNow;

  /// No description provided for @noNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet.'**
  String get noNotificationsYet;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @markAllAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllAsRead;

  /// No description provided for @noNewNotifications.
  ///
  /// In en, this message translates to:
  /// **'No new notifications'**
  String get noNewNotifications;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @viewAllNotifications.
  ///
  /// In en, this message translates to:
  /// **'View All Notifications'**
  String get viewAllNotifications;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @noOnboardingPagesFound.
  ///
  /// In en, this message translates to:
  /// **'No onboarding pages found.'**
  String get noOnboardingPagesFound;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// No description provided for @selectYourPreferredLanguageFor.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred language for a personalized app experience.'**
  String get selectYourPreferredLanguageFor;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @manageYourClinicPreferences.
  ///
  /// In en, this message translates to:
  /// **'Manage your clinic preferences.'**
  String get manageYourClinicPreferences;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @appointments.
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get appointments;

  /// No description provided for @alertsForBookings.
  ///
  /// In en, this message translates to:
  /// **'Alerts for bookings'**
  String get alertsForBookings;

  /// No description provided for @labAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Lab Analysis'**
  String get labAnalysis;

  /// No description provided for @resultNotifications.
  ///
  /// In en, this message translates to:
  /// **'Result notifications'**
  String get resultNotifications;

  /// No description provided for @accessMedicalArchives.
  ///
  /// In en, this message translates to:
  /// **'Access medical archives'**
  String get accessMedicalArchives;

  /// No description provided for @needAssistance.
  ///
  /// In en, this message translates to:
  /// **'Need assistance?'**
  String get needAssistance;

  /// No description provided for @text247DigitalConcierge.
  ///
  /// In en, this message translates to:
  /// **'24/7 Digital Concierge'**
  String get text247DigitalConcierge;

  /// No description provided for @id.
  ///
  /// In en, this message translates to:
  /// **'ID: '**
  String get id;

  /// No description provided for @settingsPreferences.
  ///
  /// In en, this message translates to:
  /// **'Settings & Preferences'**
  String get settingsPreferences;

  /// No description provided for @manageYourAccountDetailsSecurity.
  ///
  /// In en, this message translates to:
  /// **'Manage your account details, security, and notification preferences.'**
  String get manageYourAccountDetailsSecurity;

  /// No description provided for @healthcareSimplified.
  ///
  /// In en, this message translates to:
  /// **'Healthcare, Simplified'**
  String get healthcareSimplified;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get orContinueWith;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get continueAsGuest;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @o2.
  ///
  /// In en, this message translates to:
  /// **'O2'**
  String get o2;

  /// No description provided for @first.
  ///
  /// In en, this message translates to:
  /// **'First'**
  String get first;

  /// No description provided for @startYournhealthJourney.
  ///
  /// In en, this message translates to:
  /// **'Start Your Health Journey'**
  String get startYournhealthJourney;

  /// No description provided for @signInToAccessYour.
  ///
  /// In en, this message translates to:
  /// **'Sign in to access your appointments and medical records seamlessly.'**
  String get signInToAccessYour;

  /// No description provided for @helloGuest.
  ///
  /// In en, this message translates to:
  /// **'Hello Guest 👋'**
  String get helloGuest;

  /// No description provided for @hiName.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name} 👋'**
  String hiName(String name);

  /// No description provided for @tapToSignIn.
  ///
  /// In en, this message translates to:
  /// **'TAP TO SIGN IN'**
  String get tapToSignIn;

  /// No description provided for @yourHealthComesFirst.
  ///
  /// In en, this message translates to:
  /// **'Your health comes first'**
  String get yourHealthComesFirst;

  /// No description provided for @allCategory.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allCategory;

  /// No description provided for @failedToLoadDoctors.
  ///
  /// In en, this message translates to:
  /// **'Failed to load doctors'**
  String get failedToLoadDoctors;

  /// No description provided for @topRated.
  ///
  /// In en, this message translates to:
  /// **'Top Rated'**
  String get topRated;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @noDescriptionAvailable.
  ///
  /// In en, this message translates to:
  /// **'No description available.'**
  String get noDescriptionAvailable;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get showLess;

  /// No description provided for @readMore.
  ///
  /// In en, this message translates to:
  /// **'Read more'**
  String get readMore;

  /// No description provided for @years.
  ///
  /// In en, this message translates to:
  /// **'yrs'**
  String get years;

  /// No description provided for @onlineSupport.
  ///
  /// In en, this message translates to:
  /// **'Online support'**
  String get onlineSupport;

  /// No description provided for @welcomeToSupportFull.
  ///
  /// In en, this message translates to:
  /// **'Hello! Welcome to O2 Clinic Support. We’re here for inquiries, complaints, appointments, photos, videos, and voice notes.'**
  String get welcomeToSupportFull;

  /// No description provided for @welcomeToSupportShort.
  ///
  /// In en, this message translates to:
  /// **'Hello! Welcome to O2 Clinic Support.'**
  String get welcomeToSupportShort;

  /// No description provided for @chatMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get chatMessage;

  /// No description provided for @tapToStartChat.
  ///
  /// In en, this message translates to:
  /// **'Tap to start chat'**
  String get tapToStartChat;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @radiologyServices.
  ///
  /// In en, this message translates to:
  /// **'Radiology Services'**
  String get radiologyServices;

  /// No description provided for @chooseImagingService.
  ///
  /// In en, this message translates to:
  /// **'Choose your imaging service'**
  String get chooseImagingService;

  /// No description provided for @cosmeticTreatments.
  ///
  /// In en, this message translates to:
  /// **'Cosmetic Treatments'**
  String get cosmeticTreatments;

  /// No description provided for @exploreCosmeticTreatments.
  ///
  /// In en, this message translates to:
  /// **'Explore cosmetic treatments'**
  String get exploreCosmeticTreatments;

  /// No description provided for @specializedClinics.
  ///
  /// In en, this message translates to:
  /// **'Specialized Clinics'**
  String get specializedClinics;

  /// No description provided for @chooseSpecialtyToSeeDoctors.
  ///
  /// In en, this message translates to:
  /// **'Choose a specialty to see doctors'**
  String get chooseSpecialtyToSeeDoctors;

  /// No description provided for @full.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get full;

  /// No description provided for @selectionRequired.
  ///
  /// In en, this message translates to:
  /// **'Selection Required'**
  String get selectionRequired;

  /// No description provided for @pleaseSelectDateFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select a date first'**
  String get pleaseSelectDateFirst;

  /// No description provided for @pleaseSelectTimeFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select a time first'**
  String get pleaseSelectTimeFirst;

  /// No description provided for @slotFull.
  ///
  /// In en, this message translates to:
  /// **'Slot Full'**
  String get slotFull;

  /// No description provided for @thisSlotHasReachedItsMaximumCapacity.
  ///
  /// In en, this message translates to:
  /// **'This slot has reached its maximum capacity.'**
  String get thisSlotHasReachedItsMaximumCapacity;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @anUnexpectedErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred.'**
  String get anUnexpectedErrorOccurred;

  /// No description provided for @aboutThisService.
  ///
  /// In en, this message translates to:
  /// **'About this Service'**
  String get aboutThisService;

  /// No description provided for @availableDaysCount.
  ///
  /// In en, this message translates to:
  /// **'Available {count} days a week'**
  String availableDaysCount(String count);

  /// No description provided for @coreDiagnostics.
  ///
  /// In en, this message translates to:
  /// **'Core Diagnostics'**
  String get coreDiagnostics;

  /// No description provided for @specializedImaging.
  ///
  /// In en, this message translates to:
  /// **'Specialized Imaging'**
  String get specializedImaging;

  /// No description provided for @doctorDetails.
  ///
  /// In en, this message translates to:
  /// **'Doctor Details'**
  String get doctorDetails;

  /// No description provided for @appointmentSchedule.
  ///
  /// In en, this message translates to:
  /// **'Appointment Schedule'**
  String get appointmentSchedule;

  /// No description provided for @clinicLocation.
  ///
  /// In en, this message translates to:
  /// **'Clinic Location'**
  String get clinicLocation;

  /// No description provided for @paymentSummary.
  ///
  /// In en, this message translates to:
  /// **'Payment Summary'**
  String get paymentSummary;

  /// No description provided for @patientInfo.
  ///
  /// In en, this message translates to:
  /// **'Patient Info'**
  String get patientInfo;

  /// No description provided for @guestPatient.
  ///
  /// In en, this message translates to:
  /// **'Guest Patient'**
  String get guestPatient;

  /// No description provided for @notLinked.
  ///
  /// In en, this message translates to:
  /// **'Not linked'**
  String get notLinked;

  /// No description provided for @bookingFailed.
  ///
  /// In en, this message translates to:
  /// **'Booking Failed'**
  String get bookingFailed;

  /// No description provided for @timeIsNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Time is not available'**
  String get timeIsNotAvailable;

  /// No description provided for @couldNotCompleteYourBooking.
  ///
  /// In en, this message translates to:
  /// **'Could not complete your booking at this time. Please try again.'**
  String get couldNotCompleteYourBooking;

  /// No description provided for @specialty.
  ///
  /// In en, this message translates to:
  /// **'Specialty'**
  String get specialty;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @chooseImagingAreas.
  ///
  /// In en, this message translates to:
  /// **'Choose imaging areas'**
  String get chooseImagingAreas;

  /// No description provided for @selectServices.
  ///
  /// In en, this message translates to:
  /// **'Select services'**
  String get selectServices;

  /// No description provided for @am.
  ///
  /// In en, this message translates to:
  /// **'AM'**
  String get am;

  /// No description provided for @pm.
  ///
  /// In en, this message translates to:
  /// **'PM'**
  String get pm;

  /// No description provided for @max.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get max;

  /// No description provided for @searchAndBook.
  ///
  /// In en, this message translates to:
  /// **'Search & Book'**
  String get searchAndBook;

  /// No description provided for @findDoctorsClinicsRadiology.
  ///
  /// In en, this message translates to:
  /// **'Find doctors, clinics, radiology...'**
  String get findDoctorsClinicsRadiology;

  /// No description provided for @bookingFound.
  ///
  /// In en, this message translates to:
  /// **'{count} booking(s) found'**
  String bookingFound(String count);

  /// No description provided for @allAppointments.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allAppointments;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @doctorAppointment.
  ///
  /// In en, this message translates to:
  /// **'Doctor Appointment'**
  String get doctorAppointment;

  /// No description provided for @serviceAppointment.
  ///
  /// In en, this message translates to:
  /// **'Service Appointment'**
  String get serviceAppointment;

  /// No description provided for @imagingAppointment.
  ///
  /// In en, this message translates to:
  /// **'Imaging Appointment'**
  String get imagingAppointment;

  /// No description provided for @cosmeticAppointment.
  ///
  /// In en, this message translates to:
  /// **'Cosmetic Appointment'**
  String get cosmeticAppointment;

  /// No description provided for @imaging.
  ///
  /// In en, this message translates to:
  /// **'Imaging'**
  String get imaging;

  /// No description provided for @cosmetic.
  ///
  /// In en, this message translates to:
  /// **'Cosmetic'**
  String get cosmetic;

  /// No description provided for @appointmentOnly.
  ///
  /// In en, this message translates to:
  /// **'Appointment'**
  String get appointmentOnly;

  /// No description provided for @todayOnly.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayOnly;

  /// No description provided for @inOneDay.
  ///
  /// In en, this message translates to:
  /// **'In 1 day'**
  String get inOneDay;

  /// No description provided for @inDays.
  ///
  /// In en, this message translates to:
  /// **'In {count} days'**
  String inDays(String count);

  /// No description provided for @ourLocation.
  ///
  /// In en, this message translates to:
  /// **'Our Location'**
  String get ourLocation;

  /// No description provided for @takeMeThere.
  ///
  /// In en, this message translates to:
  /// **'Take Me There'**
  String get takeMeThere;

  /// No description provided for @emailUs.
  ///
  /// In en, this message translates to:
  /// **'Email Us'**
  String get emailUs;

  /// No description provided for @callUs.
  ///
  /// In en, this message translates to:
  /// **'Call Us'**
  String get callUs;

  /// No description provided for @notifSectionNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get notifSectionNew;

  /// No description provided for @notifSectionToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get notifSectionToday;

  /// No description provided for @notifSectionYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get notifSectionYesterday;

  /// No description provided for @notifSectionEarlier.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get notifSectionEarlier;

  /// No description provided for @notifTimeJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get notifTimeJustNow;

  /// No description provided for @notifTimeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String notifTimeMinutesAgo(int count);

  /// No description provided for @notifTimeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String notifTimeHoursAgo(int count);

  /// No description provided for @notifTimeYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get notifTimeYesterday;

  /// No description provided for @notifTimeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String notifTimeDaysAgo(int count);

  /// No description provided for @notifUnreadCount.
  ///
  /// In en, this message translates to:
  /// **'{count} New'**
  String notifUnreadCount(int count);

  /// No description provided for @labTestsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Lab Tests'**
  String get labTestsScreenTitle;

  /// No description provided for @labTestsContactUs.
  ///
  /// In en, this message translates to:
  /// **'To book lab tests or inquiries, contact'**
  String get labTestsContactUs;

  /// No description provided for @chatWithAdmin.
  ///
  /// In en, this message translates to:
  /// **'Or send a message in chat'**
  String get chatWithAdmin;

  /// No description provided for @findNumberInLocation.
  ///
  /// In en, this message translates to:
  /// **'You will find the contact number in our location screen'**
  String get findNumberInLocation;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get termsAndConditions;

  /// No description provided for @loginAsDoctor.
  ///
  /// In en, this message translates to:
  /// **'Login as Doctor'**
  String get loginAsDoctor;

  /// No description provided for @doctorLogin.
  ///
  /// In en, this message translates to:
  /// **'Doctor Login'**
  String get doctorLogin;

  /// No description provided for @welcomeBackDoctor.
  ///
  /// In en, this message translates to:
  /// **'Welcome back, Doctor. Please login to continue.'**
  String get welcomeBackDoctor;

  /// No description provided for @doctorHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get doctorHome;

  /// No description provided for @doctorAppointments.
  ///
  /// In en, this message translates to:
  /// **'Appts'**
  String get doctorAppointments;

  /// No description provided for @doctorPatients.
  ///
  /// In en, this message translates to:
  /// **'Patients'**
  String get doctorPatients;

  /// No description provided for @doctorChats.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get doctorChats;

  /// No description provided for @doctorEmailNotFound.
  ///
  /// In en, this message translates to:
  /// **'This email is not found. Please contact administration.'**
  String get doctorEmailNotFound;

  /// No description provided for @doctorEmailNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Email Not Found'**
  String get doctorEmailNotFoundTitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'he'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'he':
      return AppLocalizationsHe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
