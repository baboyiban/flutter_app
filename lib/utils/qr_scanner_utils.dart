import 'package:flutter/material.dart';

double getScanAreaSize(BuildContext context) {
  return (MediaQuery.of(context).size.width < 400 ||
          MediaQuery.of(context).size.height < 400)
      ? 150.0
      : 300.0;
}

// 추가 유틸리티 함수들을 여기에 작성할 수 있습니다.
// 예: QR 결과 유효성 검사, 형식 변환 등
