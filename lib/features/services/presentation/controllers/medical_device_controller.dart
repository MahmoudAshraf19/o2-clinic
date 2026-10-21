import 'package:get/get.dart';
import '../../data/models/medical_device_model.dart';
import '../../data/services/medical_device_service.dart';

class MedicalDeviceController extends GetxController {
  final MedicalDeviceService _service = MedicalDeviceService.instance;

  final RxList<MedicalDeviceModel> devices = <MedicalDeviceModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDevices();
  }

  Future<void> fetchDevices({bool forceRefresh = false}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final result = await _service.getMedicalDevices(forceRefresh: forceRefresh);
      devices.assignAll(result);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
