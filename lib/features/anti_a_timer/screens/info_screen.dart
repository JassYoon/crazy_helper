import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme.dart';
import '../models/breathing_mode.dart';

class InfoScreen extends StatefulWidget {
  final int sets;
  final int restAfter;
  final bool restEnabled;

  const InfoScreen({
    super.key,
    required this.sets,
    required this.restAfter,
    required this.restEnabled,
  });

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  late int _sets;
  late int _restAfter;
  late bool _restEnabled;

  @override
  void initState() {
    super.initState();
    _sets = widget.sets;
    _restAfter = widget.restAfter;
    _restEnabled = widget.restEnabled;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('sets', _sets);
    await prefs.setInt('restAfter', _restAfter);
    await prefs.setBool('restEnabled', _restEnabled);
    if (mounted) {
      Navigator.of(context).pop({
        'sets': _sets,
        'restAfter': _restAfter,
        'restEnabled': _restEnabled,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _save,
                    child: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border),
                        color: AppColors.white,
                      ),
                      child: Icon(Icons.arrow_back, color: AppColors.textSecondary, size: 20),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text('설정',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 사용 방법 (맨 위)
                    Text('사용 방법', style: _sectionStyle),
                    const SizedBox(height: 12),
                    _buildInstruction('1', '호흡 모드를 선택하세요'),
                    _buildInstruction('2', '시작 버튼을 눌러 도넛 차트의 안내를 따라 호흡하세요'),
                    _buildInstruction('3', '설정한 세트만큼 반복하면 자동으로 종료됩니다'),
                    _buildInstruction('4', '직접 호흡 패턴을 등록할 수 있습니다'),
                    const SizedBox(height: 32),
                    // 호흡 단계
                    Text('호흡 단계', style: _sectionStyle),
                    const SizedBox(height: 12),
                    ..._buildPhaseGuide(),
                    const SizedBox(height: 32),
                    // 세트 수
                    _SettingStepper(
                      label: '세트 수',
                      description: '한 세션의 호흡 반복 횟수',
                      value: _sets, min: 1, max: 20,
                      onChanged: (v) => setState(() => _sets = v),
                    ),
                    const SizedBox(height: 28),
                    // 휴식 알림
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('휴식 알림', style: _sectionStyle),
                            const SizedBox(height: 4),
                            Text(
                              _restEnabled ? '일정 세션 후 휴식을 권합니다' : '휴식 알림이 꺼져 있습니다',
                              style: TextStyle(fontSize: 12, color: AppColors.textHint),
                            ),
                          ],
                        ),
                        Switch(
                          value: _restEnabled,
                          onChanged: (v) => setState(() => _restEnabled = v),
                          activeThumbColor: AppColors.primary,
                          activeTrackColor: AppColors.primaryLight,
                          inactiveThumbColor: AppColors.textHint,
                          inactiveTrackColor: AppColors.divider,
                        ),
                      ],
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      child: _restEnabled
                          ? Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: _SettingStepper(
                                label: '휴식 간격',
                                description: '몇 세션마다 휴식을 권할지',
                                value: _restAfter, min: 1, max: 50,
                                onChanged: (v) => setState(() => _restAfter = v),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle get _sectionStyle => TextStyle(
        fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 1);

  List<Widget> _buildPhaseGuide() {
    final phases = [
      (label: '들이쉬기', color: kInhaleColor, desc: '코로 천천히 들이쉽니다'),
      (label: '참기', color: kHoldColor, desc: '숨을 잠시 참습니다'),
      (label: '내쉬기', color: kExhaleColor, desc: '입으로 천천히 내쉽니다'),
    ];
    return phases.map((p) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Container(width: 12, height: 12,
                decoration: BoxDecoration(color: p.color, shape: BoxShape.circle)),
            const SizedBox(width: 12),
            Text(p.label,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
            const SizedBox(width: 8),
            Text(p.desc, style: TextStyle(fontSize: 13, color: AppColors.textHint)),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildInstruction(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24, height: 24,
            decoration: BoxDecoration(color: AppColors.primaryVeryLight, borderRadius: BorderRadius.circular(6)),
            child: Center(
              child: Text(number,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
          ),
        ],
      ),
    );
  }
}

class _SettingStepper extends StatefulWidget {
  final String label;
  final String description;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _SettingStepper({
    required this.label, required this.description,
    required this.value, required this.min, required this.max,
    required this.onChanged,
  });

  @override
  State<_SettingStepper> createState() => _SettingStepperState();
}

class _SettingStepperState extends State<_SettingStepper> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.value}');
  }

  @override
  void didUpdateWidget(covariant _SettingStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.text = '${widget.value}';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _commitText() {
    final parsed = int.tryParse(_controller.text);
    if (parsed == null) {
      _controller.text = '${widget.value}';
      return;
    }
    final clamped = parsed.clamp(widget.min, widget.max);
    if (clamped != widget.value) {
      widget.onChanged(clamped);
    }
    _controller.text = '$clamped';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(widget.description, style: TextStyle(fontSize: 12, color: AppColors.textHint)),
        const SizedBox(height: 12),
        Row(
          children: [
            // 숫자 입력 텍스트 박스
            SizedBox(
              width: 64, height: 40,
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.primaryVeryLight,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.border)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.primary)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                ),
                onSubmitted: (_) => _commitText(),
                onTapOutside: (_) => _commitText(),
              ),
            ),
            const SizedBox(width: 12),
            // 위/아래 버튼
            Column(
              children: [
                _StepButton(
                  icon: Icons.keyboard_arrow_up,
                  onTap: widget.value < widget.max ? () => widget.onChanged(widget.value + 1) : null,
                  enabled: widget.value < widget.max,
                ),
                const SizedBox(height: 4),
                _StepButton(
                  icon: Icons.keyboard_arrow_down,
                  onTap: widget.value > widget.min ? () => widget.onChanged(widget.value - 1) : null,
                  enabled: widget.value > widget.min,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool enabled;

  const _StepButton({required this.icon, this.onTap, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32, height: 24,
        decoration: BoxDecoration(
          color: enabled ? AppColors.white : AppColors.divider,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: enabled ? AppColors.border : AppColors.divider),
        ),
        child: Icon(icon, size: 18,
            color: enabled ? AppColors.textSecondary : AppColors.textHint),
      ),
    );
  }
}
