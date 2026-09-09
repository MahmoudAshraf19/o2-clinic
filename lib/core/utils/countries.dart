class Country {
  final String name;
  final String code;
  final String dialCode;
  final String flag;

  Country({
    required this.name,
    required this.code,
    required this.dialCode,
    required this.flag,
  });
}

class Countries {
  static List<Country> all = [
    // 🇵🇸 Middle East / Priority
    Country(name: "Palestine", code: "PS", dialCode: "+970", flag: "🇵🇸"),
    Country(name: "Egypt", code: "EG", dialCode: "+20", flag: "🇪🇬"),
    Country(name: "Saudi Arabia", code: "SA", dialCode: "+966", flag: "🇸🇦"),
    Country(
      name: "United Arab Emirates",
      code: "AE",
      dialCode: "+971",
      flag: "🇦🇪",
    ),
    Country(name: "Qatar", code: "QA", dialCode: "+974", flag: "🇶🇦"),
    Country(name: "Kuwait", code: "KW", dialCode: "+965", flag: "🇰🇼"),
    Country(name: "Bahrain", code: "BH", dialCode: "+973", flag: "🇧🇭"),
    Country(name: "Oman", code: "OM", dialCode: "+968", flag: "🇴🇲"),
    Country(name: "Jordan", code: "JO", dialCode: "+962", flag: "🇯🇴"),
    Country(name: "Lebanon", code: "LB", dialCode: "+961", flag: "🇱🇧"),
    Country(name: "Syria", code: "SY", dialCode: "+963", flag: "🇸🇾"),
    Country(name: "Iraq", code: "IQ", dialCode: "+964", flag: "🇮🇶"),
    Country(name: "Yemen", code: "YE", dialCode: "+967", flag: "🇾🇪"),
    Country(name: "Iran", code: "IR", dialCode: "+98", flag: "🇮🇷"),
    Country(name: "Israel", code: "IL", dialCode: "+972", flag: "🇮🇱"),

    // 🌍 Arab Africa
    Country(name: "Morocco", code: "MA", dialCode: "+212", flag: "🇲🇦"),
    Country(name: "Algeria", code: "DZ", dialCode: "+213", flag: "🇩🇿"),
    Country(name: "Tunisia", code: "TN", dialCode: "+216", flag: "🇹🇳"),
    Country(name: "Libya", code: "LY", dialCode: "+218", flag: "🇱🇾"),
    Country(name: "Sudan", code: "SD", dialCode: "+249", flag: "🇸🇩"),
    Country(name: "Somalia", code: "SO", dialCode: "+252", flag: "🇸🇴"),
    Country(name: "Djibouti", code: "DJ", dialCode: "+253", flag: "🇩🇯"),
    Country(name: "Mauritania", code: "MR", dialCode: "+222", flag: "🇲🇷"),
    Country(name: "Comoros", code: "KM", dialCode: "+269", flag: "🇰🇲"),

    // 🌍 Major World
    Country(name: "United States", code: "US", dialCode: "+1", flag: "🇺🇸"),
    Country(name: "Canada", code: "CA", dialCode: "+1", flag: "🇨🇦"),
    Country(name: "United Kingdom", code: "GB", dialCode: "+44", flag: "🇬🇧"),
    Country(name: "France", code: "FR", dialCode: "+33", flag: "🇫🇷"),
    Country(name: "Germany", code: "DE", dialCode: "+49", flag: "🇩🇪"),
    Country(name: "Italy", code: "IT", dialCode: "+39", flag: "🇮🇹"),
    Country(name: "Spain", code: "ES", dialCode: "+34", flag: "🇪🇸"),
    Country(name: "Netherlands", code: "NL", dialCode: "+31", flag: "🇳🇱"),
    Country(name: "Sweden", code: "SE", dialCode: "+46", flag: "🇸🇪"),
    Country(name: "Norway", code: "NO", dialCode: "+47", flag: "🇳🇴"),
    Country(name: "Russia", code: "RU", dialCode: "+7", flag: "🇷🇺"),
    Country(name: "Turkey", code: "TR", dialCode: "+90", flag: "🇹🇷"),

    Country(name: "India", code: "IN", dialCode: "+91", flag: "🇮🇳"),
    Country(name: "Pakistan", code: "PK", dialCode: "+92", flag: "🇵🇰"),
    Country(name: "China", code: "CN", dialCode: "+86", flag: "🇨🇳"),
    Country(name: "Japan", code: "JP", dialCode: "+81", flag: "🇯🇵"),
    Country(name: "South Korea", code: "KR", dialCode: "+82", flag: "🇰🇷"),

    Country(name: "Brazil", code: "BR", dialCode: "+55", flag: "🇧🇷"),
    Country(name: "Mexico", code: "MX", dialCode: "+52", flag: "🇲🇽"),
    Country(name: "Argentina", code: "AR", dialCode: "+54", flag: "🇦🇷"),
    Country(name: "Chile", code: "CL", dialCode: "+56", flag: "🇨🇱"),

    Country(name: "Australia", code: "AU", dialCode: "+61", flag: "🇦🇺"),
    Country(name: "New Zealand", code: "NZ", dialCode: "+64", flag: "🇳🇿"),

    Country(name: "South Africa", code: "ZA", dialCode: "+27", flag: "🇿🇦"),
    Country(name: "Nigeria", code: "NG", dialCode: "+234", flag: "🇳🇬"),

    Country(name: "Indonesia", code: "ID", dialCode: "+62", flag: "🇮🇩"),
    Country(name: "Malaysia", code: "MY", dialCode: "+60", flag: "🇲🇾"),
    Country(name: "Philippines", code: "PH", dialCode: "+63", flag: "🇵🇭"),

    Country(name: "Greece", code: "GR", dialCode: "+30", flag: "🇬🇷"),
    Country(name: "Portugal", code: "PT", dialCode: "+351", flag: "🇵🇹"),
  ];
}
