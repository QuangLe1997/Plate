class AppStrings {
  AppStrings._();

  // App Info
  static const String appName = 'PlateSnap';
  static const String tagline = 'AI trong tam tay';
  static const String version = '1.0.0';

  // Company Info
  static const String companyName = 'NEXTIA';
  static const String companySlogan = 'AI TRONG TAM TAY';
  static const String companyPhone = '19006837';
  static const String companyEmail = 'contact@nextia.vn';
  static const String companyWebsite = 'https://nextia.vn';
  static const String companyDescription =
      'Nen tang ung dung AI su dung cong nghe tien tien de phan tich va so hoa du lieu tu hinh anh va video';
  static const String poweredBy = 'Powered by NEXTIA';
  static const String copyright = '2024 NEXTIA. All rights reserved.';

  // Scan Screen
  static const String scanInstruction = 'Huong camera vao bien so xe';
  static const String detecting = 'Dang nhan dien...';
  static const String detected = 'Da nhan dien';
  static const String noPlateFound = 'Khong tim thay bien so';
  static const String scanAgain = 'Quet lai';
  static const String copy = 'Sao chep';
  static const String copied = 'Da sao chep!';

  // History Screen
  static const String history = 'Lich su quet';
  static const String searchPlate = 'Tim kiem bien so...';
  static const String today = 'Hom nay';
  static const String yesterday = 'Hom qua';
  static const String clearAll = 'Xoa tat ca';
  static const String noHistory = 'Chua co lich su quet';
  static const String totalScanned = 'Tong: %d bien so da quet';
  static const String deleteConfirm = 'Ban co chac muon xoa?';

  // Settings Screen
  static const String settings = 'Cai dat';
  static const String scanning = 'Quet';
  static const String confidenceThreshold = 'Nguong do chinh xac';
  static const String autoContinuousScan = 'Tu dong quet lien tuc';
  static const String startupDelay = 'Do tre khoi dong';
  static const String startupDelayDescription = 'Thoi gian cho truoc khi bat dau quet';
  static const String confirmationFrames = 'So frame xac nhan';
  static const String confirmationFramesDescription = 'So frame lien tiep can khop de xac nhan ket qua';
  static const String feedback = 'Phan hoi';
  static const String sound = 'Am thanh';
  static const String vibration = 'Rung';
  static const String information = 'Thong tin';
  static const String appVersion = 'Phien ban';
  static const String about = 'Ve ung dung';

  // Result
  static const String success = 'Thanh cong!';
  static const String confidence = 'Do chinh xac';
  static const String vehicleType = 'Loai xe';
  static const String car = 'O to';
  static const String motorbike = 'Xe may';
  static const String scannedAt = 'Quet luc';

  // Permissions
  static const String cameraPermissionTitle = 'Can quyen Camera';
  static const String cameraPermissionMessage =
      'Ung dung can quyen truy cap camera de quet bien so xe';
  static const String grantPermission = 'Cap quyen';
  static const String openSettings = 'Mo Cai dat';

  // Errors
  static const String errorCameraNotAvailable = 'Camera khong kha dung';
  static const String errorOcrFailed = 'Loi nhan dien. Vui long thu lai.';
  static const String errorModelLoadFailed = 'Loi tai model ML';

  // Contact
  static const String contactSupport = 'Lien he ho tro';
  static const String callHotline = 'Goi hotline';
  static const String sendEmail = 'Gui email';
  static const String visitWebsite = 'Truy cap website';
}
