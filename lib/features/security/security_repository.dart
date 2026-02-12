abstract class SecurityVerificationRepository {
  Future<MfaOtpInfo> loadMfaInfo();

  Future<void> bindMfa({
    required String code,
    required String interval,
    required String secret,
  });
}

class MfaOtpInfo {
  const MfaOtpInfo({
    required this.secret,
    required this.qrImage,
    required this.enabled,
  });

  final String secret;
  final String qrImage;
  final bool enabled;
}

class MockSecurityVerificationRepository
    implements SecurityVerificationRepository {
  const MockSecurityVerificationRepository();

  @override
  Future<MfaOtpInfo> loadMfaInfo() async {
    return const MfaOtpInfo(
      secret: 'UI-ADAPTER-MFA-SECRET',
      qrImage: '',
      enabled: false,
    );
  }

  @override
  Future<void> bindMfa({
    required String code,
    required String interval,
    required String secret,
  }) async {
    return;
  }
}
