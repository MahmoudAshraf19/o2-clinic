import '../models/doctor_model.dart';

class DoctorsService {
  static List<DoctorModel> getDoctors() {
    return [
      DoctorModel(
        name: "Dr. Ahmed Hassan",
        title: "Senior Chest Specialist",
        image: "https://lh3.googleusercontent.com/aida-public/AB6AXuAsdsWyCCLgyJ_kOp-4t3g9vOH2YH18iFRQXb_-59am3S89LQlF0QEWnbWbE9yeDeGj32pY12S40Rdl3qNSVxURcp9Ix1YOazkVym9gKkCgBK6-zwS7dat-BGtNL3-8FMe5J86CrDNcQzzW1HcItn-RqjbixLuPczJnxN4Vr397XL4a4qcjoehKmxwolrPt12OKCBJaUeXfTAQYCOwDXCxWdRW6qEy-wLj-jXAXEt72pWP6LrwxD6tbfA93ZtNTRCGLqf-Iv_V927U",
        rating: 4.9,
        reviews: 128,
        availability: "Today",
        booked: 6,
        total: 10,
        isTopRated: true,
      ),
      DoctorModel(
        name: "Dr. Layla Mahmoud",
        title: "Consultant Pulmonologist",
        image: "https://lh3.googleusercontent.com/aida-public/AB6AXuAA7nERY_KPr9avOsK-JCex8IWQJ0XEV045AmqHMKVbx6Hiz6KgQMXgm0DlMYa91rTRht-iuTiIn3jebUyHrmzbSXKZI3jDcE66G374HANaomLQ4VXikzhWOpxuv01wRavZmdyAWwsnBL2tVA1cFtNTm5ZyWTB6kz_PKnRMu1ys19PlP2jquV4KswAdnyS3WTTSJwl4TKyrcvO3R5loWSeZk4AmyG6TvGz3oNZkXb5P4zb9dLZcO_b2xRxruL5sy1p0lOa1G6V5iIU",
        rating: 4.8,
        reviews: 95,
        availability: "Tomorrow",
        booked: 9,
        total: 10,
        isMostBooked: true,
      ),
      DoctorModel(
        name: "Dr. Youssef Tariq",
        title: "Chest Diseases Specialist",
        image: "https://lh3.googleusercontent.com/aida-public/AB6AXuDgXGEu2CcHTv2uOka442W2Rl2Hw6kQKwYMj85Eulq9GBL2kJMGPtKk8zcnhUH9P_ikyIBzeaLIRwCFsP0UWjMjXkM1IwOaad33ZaRzSiEr1lndutVxktd7d23trdKnJww7E7-W3vkdbb0ZLSaYen_b3XeA2zewKzd-I5bT7M-WuTyVqri8uKexPk9M1tdmZoOZX83I0OmmJIfpP34jL8FtWJbmPRkXtMrdh3UksAHv-wvGUyAEhpOVNhhZKO-lVWNkrlVxeUyjCRQ",
        rating: 4.6,
        reviews: 64,
        availability: "Today",
        booked: 3,
        total: 10,
      ),
    ];
  }
}