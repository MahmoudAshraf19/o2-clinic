import '../models/department_model.dart';
import '../models/doctor_model.dart';

class DepartmentService {
  static List<DepartmentModel> getAllDepartments() {
    return [
      DepartmentModel(
        id: 'chest',
        name: 'Chest Diseases',
        subtitle: 'Pulmonary & Respiratory Care',
        icon: 'air',
        description:
            'Specialized care for respiratory conditions and lung diseases',
        doctors: [
          DoctorModel(
            id: 'chest_1',
            name: 'Dr. Michael Chen',
            title: 'Senior Pulmonologist',
            specialty: 'Chest Diseases',
            rating: 4.8,
            image: 'https://picsum.photos/seed/doctor1/200/200.jpg',
            bio: 'Expert in respiratory medicine with 15+ years experience',
            experience: '15 years',
            availableDays: ['Monday', 'Wednesday', 'Friday'],
          ),
          DoctorModel(
            id: 'chest_2',
            name: 'Dr. Lisa Anderson',
            title: 'Respiratory Specialist',
            specialty: 'Chest Diseases',
            rating: 4.9,
            image: 'https://picsum.photos/seed/doctor2/200/200.jpg',
            bio: 'Specialized in asthma treatment and pulmonary rehabilitation',
            experience: '12 years',
            availableDays: ['Tuesday', 'Thursday', 'Saturday'],
          ),
          DoctorModel(
            id: 'chest_3',
            name: 'Dr. James Wilson',
            title: 'Critical Care Pulmonologist',
            specialty: 'Chest Diseases',
            rating: 4.7,
            image: 'https://picsum.photos/seed/doctor3/200/200.jpg',
            bio: 'Expert in ICU respiratory care and sleep medicine',
            experience: '18 years',
            availableDays: ['Monday', 'Thursday', 'Friday'],
          ),
        ],
      ),
      DepartmentModel(
        id: 'cardiology',
        name: 'Cardiology',
        subtitle: 'Heart & Vascular Specialists',
        icon: 'favorite',
        description: 'Comprehensive cardiac care and vascular treatments',
        doctors: [
          DoctorModel(
            id: 'cardio_1',
            name: 'Dr. Ahmed Hassan',
            title: 'Senior Consultant Cardiologist',
            specialty: 'Cardiology',
            rating: 4.9,
            image: 'https://picsum.photos/seed/doctor4/200/200.jpg',
            bio:
                'Expert in interventional cardiology and heart failure management',
            experience: '20 years',
            availableDays: ['Sunday', 'Tuesday', 'Thursday'],
          ),
          DoctorModel(
            id: 'cardio_2',
            name: 'Dr. Sarah Jenkins',
            title: 'Interventional Cardiologist',
            specialty: 'Cardiology',
            rating: 4.8,
            image: 'https://picsum.photos/seed/doctor5/200/200.jpg',
            bio: 'Specialized in cardiac catheterization and stent procedures',
            experience: '14 years',
            availableDays: ['Monday', 'Wednesday', 'Friday'],
          ),
        ],
      ),
      DepartmentModel(
        id: 'neurology',
        name: 'Neurology',
        subtitle: 'Brain & Nervous System',
        icon: 'psychology',
        description: 'Advanced neurological treatments and brain health',
        doctors: [
          DoctorModel(
            id: 'neuro_1',
            name: 'Dr. Robert Martinez',
            title: 'Senior Neurologist',
            specialty: 'Neurology',
            rating: 4.9,
            image: 'https://picsum.photos/seed/doctor6/200/200.jpg',
            bio: 'Expert in stroke treatment and epilepsy management',
            experience: '16 years',
            availableDays: ['Tuesday', 'Thursday', 'Saturday'],
          ),
          DoctorModel(
            id: 'neuro_2',
            name: 'Dr. Emily Zhang',
            title: 'Neurophysiology Specialist',
            specialty: 'Neurology',
            rating: 4.8,
            image: 'https://picsum.photos/seed/doctor7/200/200.jpg',
            bio: 'Specialized in EEG and nerve conduction studies',
            experience: '11 years',
            availableDays: ['Monday', 'Wednesday', 'Friday'],
          ),
        ],
      ),
      DepartmentModel(
        id: 'dermatology',
        name: 'Dermatology',
        subtitle: 'Skin Health & Aesthetics',
        icon: 'spa',
        description: 'Comprehensive skin care and aesthetic treatments',
        doctors: [
          DoctorModel(
            id: 'derm_1',
            name: 'Dr. Jessica Taylor',
            title: 'Cosmetic Dermatologist',
            specialty: 'Dermatology',
            rating: 4.9,
            image: 'https://picsum.photos/seed/doctor8/200/200.jpg',
            bio: 'Expert in cosmetic procedures and anti-aging treatments',
            experience: '13 years',
            availableDays: ['Monday', 'Tuesday', 'Thursday'],
          ),
          DoctorModel(
            id: 'derm_2',
            name: 'Dr. David Brown',
            title: 'Medical Dermatologist',
            specialty: 'Dermatology',
            rating: 4.7,
            image: 'https://picsum.photos/seed/doctor9/200/200.jpg',
            bio: 'Specialized in skin cancer detection and treatment',
            experience: '17 years',
            availableDays: ['Wednesday', 'Friday', 'Saturday'],
          ),
        ],
      ),
      DepartmentModel(
        id: 'immunology',
        name: 'Immunology & Allergy',
        subtitle: 'Allergy treatment experts',
        icon: 'medical_services',
        description: 'Advanced allergy testing and immunotherapy',
        doctors: [
          DoctorModel(
            id: 'immuno_1',
            name: 'Dr. Maria Garcia',
            title: 'Allergy Specialist',
            specialty: 'Immunology & Allergy',
            rating: 4.8,
            image: 'https://picsum.photos/seed/doctor10/200/200.jpg',
            bio: 'Expert in allergic diseases and immunodeficiency disorders',
            experience: '12 years',
            availableDays: ['Monday', 'Wednesday', 'Friday'],
          ),
        ],
      ),
      DepartmentModel(
        id: 'orthopedic',
        name: 'Orthopedic Surgery',
        subtitle: 'Bone and joint specialists',
        icon: 'health_and_safety',
        description: 'Comprehensive orthopedic care and joint replacement',
        doctors: [
          DoctorModel(
            id: 'ortho_1',
            name: 'Dr. Thomas Anderson',
            title: 'Senior Orthopedic Surgeon',
            specialty: 'Orthopedic Surgery',
            rating: 4.9,
            image: 'https://picsum.photos/seed/doctor11/200/200.jpg',
            bio: 'Expert in joint replacement and sports medicine',
            experience: '19 years',
            availableDays: ['Sunday', 'Tuesday', 'Thursday'],
          ),
          DoctorModel(
            id: 'ortho_2',
            name: 'Dr. Rachel Kim',
            title: 'Spine Specialist',
            specialty: 'Orthopedic Surgery',
            rating: 4.8,
            image: 'https://picsum.photos/seed/doctor12/200/200.jpg',
            bio:
                'Specialized in spinal surgery and minimally invasive procedures',
            experience: '14 years',
            availableDays: ['Monday', 'Wednesday', 'Friday'],
          ),
        ],
      ),
      DepartmentModel(
        id: 'gynecology',
        name: 'Gynecology & Infertility',
        subtitle: 'Women\'s health specialists',
        icon: 'favorite',
        description:
            'Comprehensive women\'s healthcare and fertility treatments',
        doctors: [
          DoctorModel(
            id: 'gyn_1',
            name: 'Dr. Patricia Johnson',
            title: 'Senior Gynecologist',
            specialty: 'Gynecology & Infertility',
            rating: 4.9,
            image: 'https://picsum.photos/seed/doctor13/200/200.jpg',
            bio: 'Expert in high-risk pregnancy and reproductive medicine',
            experience: '18 years',
            availableDays: ['Monday', 'Tuesday', 'Thursday'],
          ),
          DoctorModel(
            id: 'gyn_2',
            name: 'Dr. Susan Lee',
            title: 'Fertility Specialist',
            specialty: 'Gynecology & Infertility',
            rating: 4.8,
            image: 'https://picsum.photos/seed/doctor14/200/200.jpg',
            bio: 'Specialized in IVF and assisted reproductive technologies',
            experience: '15 years',
            availableDays: ['Wednesday', 'Friday', 'Saturday'],
          ),
        ],
      ),
      DepartmentModel(
        id: 'surgery',
        name: 'General Surgery & Obesity',
        subtitle: 'Comprehensive surgical care',
        icon: 'medical_services',
        description: 'Advanced surgical procedures including bariatric surgery',
        doctors: [
          DoctorModel(
            id: 'surg_1',
            name: 'Dr. William Clark',
            title: 'Senior General Surgeon',
            specialty: 'General Surgery & Obesity',
            rating: 4.8,
            image: 'https://picsum.photos/seed/doctor15/200/200.jpg',
            bio: 'Expert in minimally invasive and bariatric surgery',
            experience: '16 years',
            availableDays: ['Tuesday', 'Thursday', 'Saturday'],
          ),
          DoctorModel(
            id: 'surg_2',
            name: 'Dr. Jennifer White',
            title: 'Bariatric Surgeon',
            specialty: 'General Surgery & Obesity',
            rating: 4.9,
            image: 'https://picsum.photos/seed/doctor16/200/200.jpg',
            bio: 'Specialized in weight loss surgery and metabolic procedures',
            experience: '13 years',
            availableDays: ['Monday', 'Wednesday', 'Friday'],
          ),
        ],
      ),
    ];
  }

  static DepartmentModel? getDepartmentById(String id) {
    try {
      return getAllDepartments().firstWhere((dept) => dept.id == id);
    } catch (e) {
      return null;
    }
  }

  static DepartmentModel? getDepartmentByName(String name) {
    try {
      return getAllDepartments().firstWhere(
        (dept) => dept.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }
}
