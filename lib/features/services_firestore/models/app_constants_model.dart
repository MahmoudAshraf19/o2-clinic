class AppConstantsModel {
  final CurrencyModel currency;
  final Map<String, LanguageModel> languages;
  final AppVersionModel version;
  final ContactUsModel contactUs;

  AppConstantsModel({
    required this.currency,
    required this.languages,
    required this.version,
    required this.contactUs,
  });

  factory AppConstantsModel.fromMap(Map<String, dynamic> map) {
    return AppConstantsModel(
      currency: CurrencyModel.fromMap(
          (map['currency'] as Map<String, dynamic>?) ?? {}),
      languages: (map['languages'] as Map<String, dynamic>? ?? {}).map(
        (key, value) => MapEntry(
            key, LanguageModel.fromMap(value as Map<String, dynamic>)),
      ),
      version: AppVersionModel.fromMap(
          (map['version'] as Map<String, dynamic>?) ?? {}),
      contactUs: ContactUsModel.fromMap(
          (map['ContactUs'] as Map<String, dynamic>?) ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'currency': currency.toMap(),
      'languages': languages.map((key, value) => MapEntry(key, value.toMap())),
      'version': version.toMap(),
      'ContactUs': contactUs.toMap(),
    };
  }
}

class CurrencyModel {
  final String name;
  final String symbol;

  CurrencyModel({
    required this.name,
    required this.symbol,
  });

  factory CurrencyModel.fromMap(Map<String, dynamic> map) {
    return CurrencyModel(
      name: map['name'] ?? '',
      symbol: map['symbol'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'symbol': symbol,
    };
  }
}

class LanguageModel {
  final String slug;
  final String title;
  final bool isActive;
  final bool isRtl;

  LanguageModel({
    required this.slug,
    required this.title,
    required this.isActive,
    required this.isRtl,
  });

  factory LanguageModel.fromMap(Map<String, dynamic> map) {
    return LanguageModel(
      slug: map['slug'] ?? '',
      title: map['title'] ?? '',
      isActive: map['isActive'] ?? false,
      isRtl: map['is_rtl'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'slug': slug,
      'title': title,
      'isActive': isActive,
      'is_rtl': isRtl,
    };
  }
}

class AppVersionModel {
  final String appVersion;

  AppVersionModel({
    required this.appVersion,
  });

  factory AppVersionModel.fromMap(Map<String, dynamic> map) {
    return AppVersionModel(
      appVersion: map['app_version'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'app_version': appVersion,
    };
  }
}

class ContactUsModel {
  final String address;
  final String email;
  final String phone;

  ContactUsModel({
    required this.address,
    required this.email,
    required this.phone,
  });

  factory ContactUsModel.fromMap(Map<String, dynamic> map) {
    return ContactUsModel(
      address: map['Address'] ?? '',
      email: map['Email'] ?? '',
      phone: map['Phone'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'Address': address,
      'Email': email,
      'Phone': phone,
    };
  }
}
