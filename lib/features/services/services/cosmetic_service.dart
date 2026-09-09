import '../models/cosmetic_model.dart';

class CosmeticService {
  static final List<CosmeticModel> demoData = [
    CosmeticModel(
      id: "laser_treatments",
      titleEn: "Laser Treatments",
      titleAr: "علاجات الليزر",
      image:
          "https://lh3.googleusercontent.com/aida-public/AB6AXuACHY50K-BNpijnjxyzYWooi2mbKBQ1IYiuNbC4uumRXra0NAku1SxHMwGkAtcToDbrTd294QkcWb8iNRBdMoQLPgDqqLzt6hmiVIkacQq7YF9izCaq8Ow35Z8-vPNkbP3ee6CyQUhpDU2oDSQgubyMFoweem5akpLQf8zn94_Q6MC9x1zpzMKynCF_20kTmpSTDaEfDvKAyQQE-MFZkzCv93sVZCI3kfoX7xSz8frTjVtjv64gqkommE9io6MLrv4TCYWsaJkAlS4",
      itemsEn: [
        "Advanced Hair Removal",
        "Skin Resurfacing",
        "Pigmentation Correction",
      ],
      itemsAr: [
        "إزالة الشعر المتقدمة",
        "تجديد سطح البشرة",
        "تصحيح التصبغات",
      ],
      buttonTextEn: "View Services",
      buttonTextAr: "عرض الخدمات",
      price: 0.0,
    ),
    CosmeticModel(
      id: "injectables",
      titleEn: "Injectables",
      titleAr: "الحقن التجميلية",
      image:
          "https://lh3.googleusercontent.com/aida-public/AB6AXuDvFmrUPTvN3YCySYKL0VPxsvw6Zmin81T6AlHvo5et1TbInNyQqqmahv23G8Yf1wM3LFomWyeA2fp4lHkAu1S1CDLwt0sKceqsz9v8JjiUZXBMD5QSIJOxkJwPbmrFewez_pIBLfoLY2rP5dkOZwdmfmdxxZacXToGQFeLus9NRR_fTty26JkFgoi4beY_2d1mFPwuH9C4Y-Z6pEf9f5oPktpOtDh4dAY8kpGw2HwVV8fNzMovgaTEGD3xZGQRV20zw2OiuloS1uI",
      itemsEn: ["Fillers", "Botox", "Bio-stimulators"],
      itemsAr: ["الفيلر", "البوتوكس", "محفزات الكولاجين الحيوية"],
      buttonTextEn: "View Services",
      buttonTextAr: "عرض الخدمات",
      price: 0.0,
    ),
    CosmeticModel(
      id: "skin_care",
      titleEn: "Skin Care",
      titleAr: "العناية بالبشرة",
      image:
          "https://lh3.googleusercontent.com/aida-public/AB6AXuANBvKoxKgK1l7kej6Qx0IfBMwqJT2B1m8-MQpg-OXlLbTRcaLvQik-bDf20UYh-pqvgsnWtzdB17Bkc6AuqtwuNgHbdDRJwA-iwLhPK-mZ2bybrsMirAYdlbxHDQaJsGtkzGMnseI9VrkHuro5zqaeYGT3-Vyz2rL6gilokWAwnx2Z3Bj_iE7pD3YLKDFy_ocuVNvjQLw8W_49o-lkCD0AXbqwxdwSKMs6zhXCJ-NFlqfgcbkFbm5uPhYlPoyviKtMjX6MxWkhMUA",
      itemsEn: ["Facials", "Peels", "Microneedling"],
      itemsAr: ["علاجات الوجه", "التقشير", "الوخز بالإبر الدقيقة"],
      buttonTextEn: "View Services",
      buttonTextAr: "عرض الخدمات",
      price: 0.0,
    ),
  ];

  static List<CosmeticModel> getAllCosmetics() {
    return demoData;
  }

  static CosmeticModel? getCosmeticByIndex(int index) {
    if (index >= 0 && index < demoData.length) {
      return demoData[index];
    }
    return null;
  }

  static List<CosmeticModel> getCosmeticsByTitle(String searchTerm) {
    return demoData
        .where(
          (cosmetic) =>
              cosmetic.title.toLowerCase().contains(searchTerm.toLowerCase()),
        )
        .toList();
  }
}
