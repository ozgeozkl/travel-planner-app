// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get emptyFieldsError => 'Lütfen e-posta ve şifrenizi girin.';

  @override
  String get emailVerifyError => 'Lütfen e-posta adresinize gelen linke tıklayarak hesabınızı doğrulayın.';

  @override
  String get loginSuccess => 'Giriş başarılı! Haritaya yönlendiriliyorsunuz...';

  @override
  String get loginSubtitle => 'Seyahatlerini planlamaya başlamak için giriş yap';

  @override
  String get emailLabel => 'E-posta';

  @override
  String get passwordLabel => 'Şifre';

  @override
  String get emailRequiredForReset => 'Lütfen önce e-posta adresinizi yukarıya yazın.';

  @override
  String get passwordResetSent => 'Şifre sıfırlama linki e-postanıza gönderildi.';

  @override
  String get forgotPassword => 'Şifremi Unuttum';

  @override
  String get loginButton => 'Giriş Yap';

  @override
  String get noAccountRegister => 'Hesabın yok mu? Hemen kayıt ol.';

  @override
  String get registerEmptyFieldsError => 'Lütfen e-posta ve şifre alanlarını doldurun.';

  @override
  String get registerSuccessMsg => 'Kayıt başarılı! Lütfen e-posta adresinize gelen doğrulama linkine tıklayın.';

  @override
  String get registerAppBarTitle => 'Yeni Hesap Oluştur';

  @override
  String get registerTitle => 'Aramıza Katıl';

  @override
  String get registerSubtitle => 'Seyahat haritanı oluşturmak için ücretsiz hesap aç';

  @override
  String get registerEmailLabel => 'E-posta Adresi';

  @override
  String get registerPasswordLabel => 'Şifre (En az 6 karakter)';

  @override
  String get registerButton => 'Kayıt Ol ve Onay Kodu Gönder';

  @override
  String get locationServicesDisabled => 'Konum servisleri kapalı.';

  @override
  String get locationPermissionDenied => 'Konum izni verilmedi.';

  @override
  String get locationPermissionDeniedForever => 'Konum izinleri kalıcı olarak reddedildi.';

  @override
  String get locationFetchFailed => 'Konum alınamadı.';

  @override
  String get mapAddPlaceTitle => 'Yeni Yer Ekle';

  @override
  String get mapEditPlaceTitle => 'Yeri Düzenle';

  @override
  String get placeNameHint => 'Mekan Adı (Zorunlu)';

  @override
  String get placeNameLabel => 'Mekan Adı';

  @override
  String get placeNoteHint => 'Buraya dair notlarınız...';

  @override
  String get placeNoteLabel => 'Not (İsteğe Bağlı)';

  @override
  String get addPhotoLabel => 'Fotoğraf Ekle';

  @override
  String get selectPinColorLabel => 'Pin Rengi Seçin:';

  @override
  String get processingDataWait => 'Veriler işleniyor...\nLütfen bekleyin.';

  @override
  String get cancelButton => 'İptal';

  @override
  String get saveButton => 'Kaydet';

  @override
  String get savedSuccessfully => 'Kaydedildi!';

  @override
  String get errorOccurred => 'Hata oluştu.';

  @override
  String get updatedSuccessfully => 'Güncellendi!';

  @override
  String get noNoteAdded => 'Not eklenmemiş.';

  @override
  String get areYouSure => 'Emin misiniz?';

  @override
  String deletePlaceWithPhoto(String title) {
    return '$title ve içindeki fotoğraf kalıcı olarak silinecek.';
  }

  @override
  String deletePlaceOnly(String title) {
    return '$title silinecek.';
  }

  @override
  String get deleteButton => 'Sil';

  @override
  String get noSavedPlacesYet => 'Henüz kaydedilmiş bir yer yok.';

  @override
  String get mySavedPlaces => 'Kaydettiğim Yerler';

  @override
  String get addressLoadingOrNotFound => 'Adres yükleniyor veya bulunamadı...';

  @override
  String get placeNotFoundLongPress => 'Mekan bulunamadı. Haritaya UZUN BASARAK kendiniz ekleyebilirsiniz!';

  @override
  String get myTravelMapTitle => 'Seyahat Haritam';

  @override
  String get myProfileTooltip => 'Profilim';

  @override
  String get savedPlacesTooltip => 'Kaydedilen Yerler';

  @override
  String get searchCityOrPlaceHint => 'Şehir veya mekan ara...';

  @override
  String get plannerCreateTripTitle => 'Yeni Seyahat Planla';

  @override
  String get plannerTripTitleLabel => 'Seyahat Başlığı (Örn: Roma Tatili)';

  @override
  String get plannerSelectDateRange => 'Tarih Aralığı Seç';

  @override
  String get plannerFillAllFieldsError => 'Lütfen tüm alanları doldurun.';

  @override
  String get plannerCreateButton => 'Oluştur';

  @override
  String get plannerTripArchived => 'Seyahat arşive taşındı.';

  @override
  String get plannerTripUnarchived => 'Seyahat aktif planlara taşındı.';

  @override
  String get plannerDeleteTripTitle => 'Seyahati Sil';

  @override
  String plannerDeleteTripConfirm(String title) {
    return '\"$title\" seyahatini silmek istediğinize emin misiniz?';
  }

  @override
  String get plannerAppBarTitle => 'Seyahat Planlarım';

  @override
  String get plannerTabActive => 'Planlananlar';

  @override
  String get plannerTabPast => 'Geçmiş / Arşiv';

  @override
  String get plannerNoPastTrips => 'Geçmiş seyahat bulunmuyor.';

  @override
  String get plannerNoActiveTrips => 'Henüz planlanmış bir seyahatiniz yok.';

  @override
  String get plannerMoveToActive => 'Aktife Taşı';

  @override
  String get plannerMoveToArchive => 'Arşive Kaldır';

  @override
  String plannerPlaceCount(int count) {
    return '$count Mekan';
  }

  @override
  String get plannerCompleted => 'Tamamlandı';

  @override
  String get plannerNewTripFab => 'Yeni Seyahat';

  @override
  String get tripThemeSelectTitle => 'Gezi Temasını Seç';

  @override
  String get tripSmartDistributionSuccess => '🔒 Sabitlenen yerler korunarak akıllı dağıtım yapıldı!';

  @override
  String get tripNotesSavedSuccess => 'Notlar kaydedildi!';

  @override
  String tripSelectPlaceForDay(int dayIndex) {
    return '$dayIndex. Gün İçin Mekan Seç';
  }

  @override
  String get tripAllPlacesAssignedOrEmpty => 'Tüm mekanlar atandı veya havuz boş.';

  @override
  String get tripThemeSelectTooltip => 'Tema Rengi Seç';

  @override
  String get tripTabPinPool => 'Pin Havuzu';

  @override
  String get tripTabDailyPlan => 'Günlük Plan';

  @override
  String get tripTabNotes => 'Notlar';

  @override
  String get tripNoPlacesOnMapYet => 'Haritada henüz kaydedilmiş bir yer yok.';

  @override
  String get tripSmartDistributeTitle => 'Akıllı Dağıt';

  @override
  String get tripSmartDistributeSubtitle => 'Sabitlenenleri koru, kalanları yakınlığa göre böl';

  @override
  String get tripSmartDistributeStartButton => 'Başlat';

  @override
  String tripDayNumber(int dayNum) {
    return '$dayNum. Gün';
  }

  @override
  String get tripNoPlanForThisDay => 'Bu gün için plan yok.';

  @override
  String get tripUnlockTooltip => 'Kilidi Kaldır';

  @override
  String get tripLockToThisDayTooltip => 'Bu Güne Sabitle';

  @override
  String tripMoveToDay(int dayNum) {
    return '$dayNum. Gün\'e Taşı';
  }

  @override
  String tripAddPlaceToDay(int dayNum) {
    return '$dayNum. Güne Mekan Ekle';
  }

  @override
  String get tripSeeRouteOnMap => 'Rotayı Haritada Gör';

  @override
  String get tripNotesHint => 'Aklına gelen her şeyi buraya karalayabilirsin...';

  @override
  String get tripSaveNotesButton => 'Notları Kaydet';

  @override
  String tripBulkMoveDayTitle(int dayIndex) {
    return '$dayIndex. Günü Toplu Taşı';
  }

  @override
  String get tripBulkMoveDayContent => 'Bu gündeki tüm mekanları hangi güne aktarmak istiyorsunuz?';

  @override
  String get tripBulkMoveTargetDayLabel => 'Hedef Gün';

  @override
  String get tripBulkMoveMoveAllButton => 'Hepsini Taşı';

  @override
  String get galleryAppBarTitle => 'Anı Albümüm';

  @override
  String get galleryNoPhotosYet => 'Henüz fotoğraflı bir anı eklemediniz.';

  @override
  String get profileAppBarTitle => 'Profilim';

  @override
  String get profilePhotoUpdated => 'Profil fotoğrafı güncellendi.';

  @override
  String get profilePhotoUploadFailed => 'Fotoğraf yüklenemedi.';

  @override
  String get profileStatSavedPlaces => 'Kayıtlı Yer';

  @override
  String get profileStatPhotos => 'Fotoğraflar';

  @override
  String get profileMenuTripPlanner => 'Seyahat Planlama';

  @override
  String get profileMenuPastTrips => 'Geçmiş Seyahatlerim';

  @override
  String get profileMenuLogout => 'Çıkış Yap';

  @override
  String get savedListAppBarTitle => 'Kaydedilen Yerler';

  @override
  String get savedListEmptyText => 'Henüz kaydedilmiş bir yer yok.';

  @override
  String get savedListNoAddress => 'Adres bilgisi bulunamadı';

  @override
  String get settingsSecurityAuthTitle => 'Güvenlik Doğrulaması';

  @override
  String get settingsSecurityAuthSubtitle => 'Bu kritik işlem için mevcut şifrenizi girmeniz gerekmektedir.';

  @override
  String get settingsEmailLabel => 'E-posta';

  @override
  String get settingsCurrentPasswordLabel => 'Mevcut Şifre';

  @override
  String get settingsCancel => 'İptal';

  @override
  String get settingsVerify => 'Doğrula';

  @override
  String get settingsWrongPassword => 'Hatalı şifre girdiniz.';

  @override
  String get settingsChangePasswordTitle => 'Şifre Değiştir';

  @override
  String get settingsNewPasswordLabel => 'Yeni Şifre';

  @override
  String get settingsPasswordLengthError => 'Şifre en az 6 karakter olmalıdır.';

  @override
  String get settingsPasswordUpdateSuccess => 'Şifreniz başarıyla güncellendi.';

  @override
  String get settingsPasswordUpdateError => 'Şifre güncellenemedi.';

  @override
  String get settingsUpdate => 'Güncelle';

  @override
  String get settingsChangeEmailTitle => 'E-posta Değiştir';

  @override
  String get settingsNewEmailLabel => 'Yeni E-posta Adresi';

  @override
  String get settingsInvalidEmailError => 'Lütfen geçerli bir e-posta adresi girin.';

  @override
  String get settingsVerificationSentTitle => 'Doğrulama Gönderildi 📩';

  @override
  String get settingsVerificationSentBody => 'Yeni e-posta adresinize bir onay bağlantısı gönderdik.\n\nLütfen gelen kutunuzu kontrol edin ve bağlantıya tıklayın. Onaylama işlemini yapana kadar mevcut e-postanız görünmeye devam edecektir.';

  @override
  String get settingsGotIt => 'Anladım';

  @override
  String get settingsEmailUpdateError => 'E-posta güncellenemedi. Başka bir hesap tarafından kullanılıyor olabilir.';

  @override
  String get settingsDeleteAccountTitle => 'Hesabı Kalıcı Olarak Sil';

  @override
  String get settingsDeleteAccountWarning => 'Hesabınızı sildiğinizde tüm kaydedilen yerleriniz ve anılarınız kalıcı olarak silinecektir. Bu işlem geri alınamaz.';

  @override
  String get settingsDeleteAccountConfirm => 'Hesabımı Sil';

  @override
  String get settingsDeleteAccountError => 'Hesap silme işlemi başarısız oldu.';

  @override
  String get settingsAppBarTitle => 'Ayarlar';

  @override
  String get settingsAppLanguage => 'Uygulama Dili';

  @override
  String get authErrorSignUp => 'Kayıt olurken bir hata oluştu.';

  @override
  String get authErrorWeakPassword => 'Şifreniz çok zayıf. Lütfen en az 6 karakterli daha güçlü bir şifre belirleyin.';

  @override
  String get authErrorEmailInUse => 'Bu e-posta adresi ile zaten kayıtlı bir hesap bulunuyor.';

  @override
  String get authErrorInvalidEmail => 'Lütfen geçerli bir e-posta adresi girin.';

  @override
  String get authErrorUnexpected => 'Beklenmeyen bir hata oluştu.';

  @override
  String get authErrorSignIn => 'Giriş yapılamadı.';

  @override
  String get authErrorInvalidCredential => 'E-posta adresiniz veya şifreniz hatalı. Lütfen kontrol edin.';

  @override
  String get authErrorInvalidEmailFormat => 'Lütfen geçerli bir e-posta adresi formatı girin.';

  @override
  String get authErrorUserDisabled => 'Bu kullanıcı hesabı sistem tarafından engellenmiş.';

  @override
  String get authErrorVerificationEmail => 'Doğrulama e-postası gönderilemedi.';

  @override
  String get authErrorPasswordReset => 'Şifre sıfırlama linki gönderilemedi.';

  @override
  String get authErrorInvalidEmailReset => 'Geçersiz bir e-posta adresi girdiniz.';

  @override
  String get authErrorSignOut => 'Çıkış yapılırken bir sorun oluştu.';

  @override
  String get dbErrorAddPin => 'Yer kaydedilemedi.';

  @override
  String get dbErrorPinIdNotFound => 'Güncellenecek pinin ID\'si bulunamadı.';

  @override
  String get dbErrorUpdatePin => 'Yer güncellenemedi.';

  @override
  String get dbErrorDeletePin => 'Yer silinemedi.';

  @override
  String get placesFallbackType => 'Mekan';

  @override
  String get appTitle => 'Seyahat Planlayıcı';

  @override
  String get securityApprovalTitle => 'Güvenlik Onayı';

  @override
  String emailNotVerifiedMessage(String email) {
    return 'Kayıt oldunuz ancak $email adresini henüz onaylamadınız.';
  }

  @override
  String get checkInboxMessage => 'Lütfen gelen kutunuzu (veya spam klasörünü) kontrol edip onay linkine tıklayın. Onayladıktan sonra tekrar giriş yapabilirsiniz.';

  @override
  String get returnToLoginButton => 'Giriş Ekranına Dön';
}
