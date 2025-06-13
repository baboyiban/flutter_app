import 'package:flutter/material.dart';
import 'package:flutter_app/constants/app_colors.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

// 열 너비 비율 설정 (Key: 열 이름, Value: flex 비율)
const Map<String, int> _columnFlex = {
  'ID': 5,
  '종류': 5,
  '지역': 5,
  '상태': 8,
  '등록시간': 7,
};

class Package {
  final int packageId;
  final String packageType;
  final String regionId;
  final String packageStatus;
  final DateTime registeredAt;

  Package({
    required this.packageId,
    required this.packageType,
    required this.regionId,
    required this.packageStatus,
    required this.registeredAt,
  });

  factory Package.fromJson(Map<String, dynamic> json) {
    return Package(
      packageId: json['package_id'],
      packageType: json['package_type'],
      regionId: json['region_id'],
      packageStatus: json['package_status'],
      registeredAt: DateTime.parse(json['registered_at']),
    );
  }
}

class PackagePage extends StatefulWidget {
  const PackagePage({super.key});

  @override
  State<PackagePage> createState() => _PackagePageState();
}

class _PackagePageState extends State<PackagePage> {
  List<Package> packages = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    fetchPackages();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      fetchPackages();
    });
  }

  Future<void> fetchPackages() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://choidaruhan.xyz/api/package/search?sort=-registered_at',
        ),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          packages = data.map((item) => Package.fromJson(item)).toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching packages: $e');
    }
  }

  String _getRegionName(String regionId) {
    switch (regionId) {
      case 'S':
        return '서울';
      case 'K':
        return '경기';
      case 'W':
        return '경북';
      case 'G':
        return '강원';
      default:
        return regionId;
    }
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.month}/${dt.day} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  // 텍스트 스타일 통일 헬퍼 함수
  Widget _buildText(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 13),
      textAlign: TextAlign.left,
    );
  }

  // 헤더 셀 생성 헬퍼 함수
  Widget _buildCell(int flex, String text) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Align(alignment: Alignment.centerLeft, child: _buildText(text)),
      ),
    );
  }

  // 테이블 헤더
  Widget _buildTableHeader() {
    return Container(
      decoration: BoxDecoration(color: AppColors.gray),
      child: Row(
        children: [
          _buildCell(_columnFlex['ID']!, 'ID'),
          _buildCell(_columnFlex['종류']!, '종류'),
          _buildCell(_columnFlex['지역']!, '지역'),
          _buildCell(_columnFlex['상태']!, '상태'),
          _buildCell(_columnFlex['등록시간']!, '등록시간'),
        ],
      ),
    );
  }

  // 테이블 행
  Widget _buildTableRow(Package package) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.gray)),
      ),
      child: Row(
        children: [
          _buildCell(_columnFlex['ID']!, package.packageId.toString()),
          _buildCell(_columnFlex['종류']!, package.packageType),
          _buildCell(_columnFlex['지역']!, _getRegionName(package.regionId)),
          _buildCell(_columnFlex['상태']!, package.packageStatus),
          _buildCell(
            _columnFlex['등록시간']!,
            _formatDateTime(package.registeredAt),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.gray),
          borderRadius: BorderRadius.circular(8),
        ),
        width: double.infinity,
        child: Column(
          children: [
            _buildTableHeader(), // 헤더
            Expanded(
              child: ListView.builder(
                itemCount: packages.length,
                itemBuilder: (context, index) {
                  return _buildTableRow(packages[index]); // 행
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
