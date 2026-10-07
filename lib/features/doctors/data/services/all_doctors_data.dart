import '../models/all_doctor_entity.dart';
import '../models/all_doctor_model.dart';

class DoctorsData {
  static List<DoctorModel> getAllDoctors() {
    return const [
      DoctorModel(
        name: "Dr. Ahmed Yassin",
        specialty: "Cardiology",
        rating: 4.9,
        image:
            "https://lh3.googleusercontent.com/aida-public/AB6AXuDKOfyr2HgHGNJyh_5QlKY41K4GiUrn7Ns7RjEMdfzLQZSMF-Srm3_cMCwXEcAqm5vAV8DdyQiObNYNNSvif8WdzarUNmDGPQYvW3oP7y0H93xWmJXc_D4JFkeHwxp4vP0v5fGkMxWge29uSDeooR3VVqiS0Z3MCkovXrbupSt0ulRNXbdFSRv19YRSebXbsqfRQOSVd-YTU3Ob8qJALTcONJQq6osspyDbu0NR-8ytWAVoy6ESYZMIP5Ad1ZegNZFl8uHG8RqbGwg",
        time: "09:00 AM - 04:00 PM",
        availableDays: {
          'Saturday': '02:00 PM - 05:00 PM',
          'Sunday': '07:00 PM - 09:00 PM',
          'Monday': '09:00 AM - 12:00 PM',
          'Wednesday': '03:00 PM - 06:00 PM',
        },
        bookedPerDay: {
          'Saturday': 6,
          'Sunday': 7,
          'Monday': 10,
          'Wednesday': 8,
        },
        maxBookingsPerTime: 12,
        yearsExp: 14,
        patients: 1800,
        about:
            "Cardiology consultant focused on preventive care, hypertension management, and evidence-based treatment plans.",
        academicDegrees: [
          AcademicDegreeEntity(
            name: "MBBS",
            description: "Bachelor of Medicine and Bachelor of Surgery.",
          ),
          AcademicDegreeEntity(
            name: "MD Cardiology",
            description:
                "Postgraduate specialization in cardiovascular medicine.",
          ),
        ],
      ),

      DoctorModel(
        name: "Dr. Layla Mansour",
        specialty: "Immunology & Allergy",
        rating: 4.8,
        image:
            "https://lh3.googleusercontent.com/aida-public/AB6AXuDv-QNiwxxY8B2VQYbJzjbuixbh7tXT9cyYJ1Oxus5G-_sofzvf9EThqxH0oGg8Z0-rQmhWsw6mx-6klVgMo8gGxMLaRvRilZ4suARP5Ehy8O4z7XhCpzVrUiu3Nwg52DnRZjdpRlLXEyt7_I81XPNwn9Cq2EJxm1xO_xlPDNGDwvM87-4WXdOzXbcfTSRFssujDpoZhJcQNhPVvyi8wGt-U4KTOQftTGCFGnh0J-e9UM0opWc7hINd7UysiVIuUi0mATwnz2trExs",
        time: "10:00 AM - 05:00 PM",
        availableDays: {
          'Saturday': '11:00 AM - 02:00 PM',
          'Tuesday': '04:00 PM - 07:00 PM',
          'Thursday': '09:00 AM - 01:00 PM',
        },
        bookedPerDay: {'Saturday': 5, 'Tuesday': 10, 'Thursday': 7},
        maxBookingsPerTime: 10,
        yearsExp: 9,
        patients: 1200,
        about:
            "Allergy and immunology specialist providing comprehensive assessment, skin testing, and long-term control plans.",
        academicDegrees: [
          AcademicDegreeEntity(
            name: "MBBS",
            description: "Bachelor of Medicine and Bachelor of Surgery.",
          ),
          AcademicDegreeEntity(
            name: "Diploma in Allergy",
            description:
                "Clinical diploma focused on allergy diagnosis and immunotherapy.",
          ),
        ],
      ),

      DoctorModel(
        name: "Dr. Omar Tariq",
        specialty: "Orthopedics",
        rating: 4.7,
        image:
            "https://lh3.googleusercontent.com/aida-public/AB6AXuB5RGCfsmbcWAB6iBr_ahj40fT4pjh1lsF-f5NQYg3Z5BrOpWpt0WWLXzsZmMWL2avIyt_Zn2J3UXsRtojCQJjRLxyu0TLr8QeJ1luVVBPRdfUhgUfPYQgIF3Owvsv00yfr9ycRs4F04UwyNgaM7YVQmK6-uvQYTP0X-pq4b31BuHIfvtOow3D63Se1058DHiS1jbWHopeuOsbE3pdc-GzUJEX-wF_Ec5Jma5WRB7VZpvEVWif4VdOryf-FDX-rbq9E10KcRWr6hxg",
        time: "08:00 AM - 02:00 PM",
        availableDays: {
          'Saturday': '10:00 AM - 01:00 PM',
          'Monday': '03:00 PM - 06:00 PM',
          'Thursday': '08:00 AM - 12:00 PM',
        },
        bookedPerDay: {'Saturday': 9, 'Monday': 14, 'Thursday': 7},
        maxBookingsPerTime: 14,
        yearsExp: 11,
        patients: 1600,
        about:
            "Orthopedics specialist helping patients with joint pain, sports injuries, and rehabilitation-focused recovery.",
        academicDegrees: [
          AcademicDegreeEntity(
            name: "MBBS",
            description: "Bachelor of Medicine and Bachelor of Surgery.",
          ),
          AcademicDegreeEntity(
            name: "MS Orthopedics",
            description:
                "Master of Surgery with a focus on orthopedics and trauma care.",
          ),
        ],
      ),

      DoctorModel(
        name: "Dr. Fatima Ali",
        specialty: "General Surgery & Obesity",
        rating: 5.0,
        image:
            "https://lh3.googleusercontent.com/aida-public/AB6AXuC9EqqJsoQpSZffvKBfdus54alV3QaD6JTJAYlNLioNlnpsTiBl1eK9gsZDugdUq3o_akkMkUNA04uhOPxw7sGwLF8jEpJBWhFnuDZ_P-ojf_6NEbHuYUFQdJQmc8NYB4jTNpIQJ_GSQ9hfcuJueAJHe-JjpEtifSqSZnn4OnXH10GhCG57daQKZ9eFxD8xIC75m5_ya6AvDWtrhg2RjotUVudn4_HG4d2SPAU4NmQ_4DDB8SK0x5FnnyYqwTF8EBkVi69jT7V73r4",
        time: "11:00 AM - 06:00 PM",
        availableDays: {
          'Saturday': '02:00 PM - 05:00 PM',
          'Sunday': '10:00 AM - 02:00 PM',
          'Wednesday': '04:00 PM - 07:00 PM',
        },
        bookedPerDay: {'Saturday': 6, 'Sunday': 7, 'Wednesday': 8},
        maxBookingsPerTime: 8,
        yearsExp: 12,
        patients: 900,
        about:
            "General surgeon with special interest in obesity management, pre-op evaluation, and postoperative follow-up.",
        academicDegrees: [
          AcademicDegreeEntity(
            name: "MBBS",
            description: "Bachelor of Medicine and Bachelor of Surgery.",
          ),
          AcademicDegreeEntity(
            name: "MS General Surgery",
            description:
                "Master of Surgery in general surgery and operative care.",
          ),
        ],
      ),

      DoctorModel(
        name: "Dr. Sami Haddad",
        specialty: "General Surgery & Obesity",
        rating: 4.8,
        image:
            "https://lh3.googleusercontent.com/aida-public/AB6AXuCO2xIpWtf1lSSaQl61JYd0UoqsltWGZwLetVDJ2MmT-pkBgWO2KcE1Jp6DjuscFQ_lFBPBUX3XEhz7sODTZNAbu8bUyP-gCG3ZPOo03ouvtxqQaAvMXUqnDufLszvmNEMLdOkaClBcy6bNekSWPspYbTzPPVzHKHA04-FGwezbKfg0B2BoqAXWmUqckqPdfxbY3putNntioeaMLaWuTdmk_WQDneBXSDDDCYLOHW_eRlEU5NSHKB-r-FtyFotjePU_0SMebltvxCA",
        time: "09:30 AM - 04:30 PM",
        availableDays: {
          'Saturday': '11:00 AM - 03:00 PM',
          'Tuesday': '02:00 PM - 06:00 PM',
          'Friday': '09:00 AM - 01:00 PM',
        },
        bookedPerDay: {'Saturday': 6, 'Tuesday': 9, 'Friday': 7},
        maxBookingsPerTime: 10,
        yearsExp: 10,
        patients: 1100,
        about:
            "Surgical consultant supporting safe weight-management options, minimally invasive procedures, and patient education.",
        academicDegrees: [
          AcademicDegreeEntity(
            name: "MBBS",
            description: "Bachelor of Medicine and Bachelor of Surgery.",
          ),
          AcademicDegreeEntity(
            name: "Fellowship in Bariatric Surgery",
            description:
                "Clinical fellowship focusing on bariatric and metabolic surgical techniques.",
          ),
        ],
      ),

      DoctorModel(
        name: "Dr. Noor Salem",
        specialty: "Gynecology & Infertility",
        rating: 4.9,
        image:
            "https://lh3.googleusercontent.com/aida-public/AB6AXuAL85hd0ORNc51fZIrS_EnryUUqcr4gG4qctjNMjkqVCZUEiDnU-hEMGoTStFBGrHi9MU_rMZzwFbRDXivldjS_nTiM-C3mD-ifa2ZvRdDmPRY3FdxyrxSHbQ2VWb_ib967o5gdGrl7kNOaCXKlY4-HXcKbN6XN0sUG1YREBWF8u0pLqbTVDffJtMynd2wpsJ0e7dGk3lCOtklDYYs4AeB8HYZ9H-ilhsueQGgxpvyo372AKAE9M8f9vagrPmaHtUNsd1661DQLapg",
        time: "08:00 AM - 03:00 PM",
        availableDays: {
          'Saturday': '09:00 AM - 12:00 PM',
          'Monday': '02:00 PM - 05:00 PM',
          'Thursday': '10:00 AM - 03:00 PM',
        },
        bookedPerDay: {'Saturday': 6, 'Monday': 7, 'Thursday': 8},
        maxBookingsPerTime: 9,
        yearsExp: 13,
        patients: 1500,
        about:
            "Gynecology and infertility specialist providing comprehensive women's health services, antenatal care, and fertility counseling.",
        academicDegrees: [
          AcademicDegreeEntity(
            name: "MBBS",
            description: "Bachelor of Medicine and Bachelor of Surgery.",
          ),
          AcademicDegreeEntity(
            name: "MRCOG",
            description:
                "Membership of the Royal College of Obstetricians and Gynaecologists.",
          ),
        ],
      ),

      DoctorModel(
        name: "Dr. Kareem Ibrahim",
        specialty: "Immunology & Allergy",
        rating: 4.7,
        image:
            "https://lh3.googleusercontent.com/aida-public/AB6AXuD5uWC1kizGgVQ0cgzPM0Wn4DDq-uTzKbyMvaPsWgD1C4HEf1nrWhOsIovH4-NM2DNmn2v9UHzl83V2QBxKU5HgiXRDtSjcjgnHhj4c04Lna_7qukUQo05jmJIHwhhfLrewy5BH4D92SzgGxeXcvtqYSbioLixD4M6tzoeOFuPvDBxI6AZO-BIWiWIPW2KDje4csqnkwXuPnjwJgub4J5t59sYKJCmfBPvEZCHU486iPis9vmfqbshEi2AjLfz8Ky5xR__XWGlradQ",
        time: "12:00 PM - 07:00 PM",
        availableDays: {
          'Saturday': '03:00 PM - 06:00 PM',
          'Wednesday': '10:00 AM - 01:00 PM',
          'Friday': '02:00 PM - 05:00 PM',
        },
        bookedPerDay: {'Saturday': 7, 'Wednesday': 6, 'Friday': 8},
        maxBookingsPerTime: 10,
        yearsExp: 8,
        patients: 1000,
        about:
            "Immunology specialist focusing on allergic rhinitis, asthma triggers, urticaria, and personalized treatment protocols.",
        academicDegrees: [
          AcademicDegreeEntity(
            name: "MBBS",
            description: "Bachelor of Medicine and Bachelor of Surgery.",
          ),
          AcademicDegreeEntity(
            name: "Clinical Immunology Training",
            description:
                "Advanced clinical training in immune system disorders and allergy care.",
          ),
        ],
      ),

      DoctorModel(
        name: "Dr. Sarah Al-Fayed",
        specialty: "Chest Diseases",
        rating: 4.8,
        image:
            "https://lh3.googleusercontent.com/aida-public/AB6AXuDKb70CAbUQmsRSqEyfTJ6WZWyySbpKpT60zgKzO8-NvgWgqgfC_tffuLjlc2GV4AchVH5VMCWh5D-3EWfPR33Y9vwaJUuaoyxk3YdeWaa0bBiK5rPzDOwsUCom24ND-7_6ezUJ8IG_j3eKB4f7Rj2FpIyTNKQH79wjJ8Va5zPFhf6kleIBkZsOmIjeip-wa1sclEyxU6wo2H8p7DoSgrY4TS_pcEPNCYE552oHYux8d4rOmqSus_mNhtWZtoQdM2kcW0q9Ub0xxrY",
        time: "09:00 AM - 03:00 PM",
        availableDays: {
          'Saturday': '08:00 AM - 11:00 AM',
          'Tuesday': '01:00 PM - 04:00 PM',
          'Thursday': '03:00 PM - 06:00 PM',
        },
        bookedPerDay: {'Saturday': 8, 'Tuesday': 9, 'Thursday': 7},
        maxBookingsPerTime: 11,
        yearsExp: 10,
        patients: 1400,
        about:
            "Chest diseases specialist supporting asthma and COPD management, respiratory infections care, and follow-up plans.",
        academicDegrees: [
          AcademicDegreeEntity(
            name: "MBBS",
            description: "Bachelor of Medicine and Bachelor of Surgery.",
          ),
          AcademicDegreeEntity(
            name: "MD Pulmonology",
            description:
                "Postgraduate specialization in pulmonary and respiratory medicine.",
          ),
        ],
      ),
    ];
  }
}
