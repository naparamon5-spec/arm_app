import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/di/app_dependencies.dart';
import '../../../core/network/api_exception.dart';
import '../../../shared/navigation/app_router.dart';

class ApprovalSummaryCard extends StatefulWidget {
  const ApprovalSummaryCard({super.key});

  @override
  State<ApprovalSummaryCard> createState() => _ApprovalSummaryCardState();
}

class _ApprovalSummaryCardState extends State<ApprovalSummaryCard>
    with SingleTickerProviderStateMixin {
  // Timing constants
  static const _typeDelay = Duration(milliseconds: 120);
  static const _eraseDelay = Duration(milliseconds: 80);
  static const _pauseAfterType = Duration(milliseconds: 1800);
  static const _pauseAfterErase = Duration(milliseconds: 400);

  late final AnimationController _cursorController;
  late final TextEditingController _inputController;
  late final FocusNode _focusNode;
  Timer? _timer;

  String _displayDigits = '';
  String _targetDigits = '';
  bool _isInteracting = false;

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController();
    _focusNode = FocusNode();
    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);

    _inputController.addListener(_onInputChanged);
    _focusNode.addListener(_onFocusChanged);

    _startTypewriterLoop();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cursorController.dispose();
    _inputController.removeListener(_onInputChanged);
    _inputController.dispose();
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  // ── helpers ──────────────────────────────────────────────────────────────

  String _randomDigits() {
    final rand = Random();
    return List.generate(6, (_) => rand.nextInt(10).toString()).join();
  }

  void _stopLoop() {
    _timer?.cancel();
    _timer = null;
  }

  // ── listener callbacks ────────────────────────────────────────────────────

  void _onInputChanged() {
    if (_inputController.text.isNotEmpty && !_isInteracting) {
      _stopLoop();
      if (mounted) setState(() => _isInteracting = true);
    }
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus && !_isInteracting) {
      _stopLoop();
      if (mounted) setState(() => _isInteracting = true);
    } else if (!_focusNode.hasFocus &&
        _inputController.text.isEmpty &&
        _isInteracting) {
      if (mounted) setState(() => _isInteracting = false);
      _startTypewriterLoop();
    }
  }

  // ── typewriter loop ───────────────────────────────────────────────────────

  void _startTypewriterLoop() {
    if (_isInteracting || !mounted) return;
    _stopLoop();
    _targetDigits = _randomDigits();
    setState(() => _displayDigits = '');
    _typeNextChar();
  }

  void _typeNextChar() {
    if (_isInteracting || !mounted) return;
    if (_displayDigits.length < _targetDigits.length) {
      _timer = Timer(_typeDelay, () {
        if (!mounted || _isInteracting) return;
        setState(() {
          _displayDigits =
              _targetDigits.substring(0, _displayDigits.length + 1);
        });
        _typeNextChar();
      });
    } else {
      _timer = Timer(_pauseAfterType, () {
        if (!mounted || _isInteracting) return;
        _eraseNextChar();
      });
    }
  }

  void _eraseNextChar() {
    if (_isInteracting || !mounted) return;
    if (_displayDigits.isNotEmpty) {
      _timer = Timer(_eraseDelay, () {
        if (!mounted || _isInteracting) return;
        setState(() {
          _displayDigits =
              _displayDigits.substring(0, _displayDigits.length - 1);
        });
        _eraseNextChar();
      });
    } else {
      _timer = Timer(_pauseAfterErase, () {
        if (!mounted || _isInteracting) return;
        _startTypewriterLoop();
      });
    }
  }

  // ── search logic ──────────────────────────────────────────────────────────

  void _activateInput() {
    _stopLoop();
    setState(() => _isInteracting = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  Future<void> _runSearch() async {
    final input = _inputController.text.trim();
    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a quote number')),
      );
      return;
    }

    try {
      final quote =
          await AppDependencies.instance.quoteRepository.getQuoteFull(input);
      if (!mounted) return;
      Navigator.of(context).pushNamed(
        AppRouter.quoteDetail,
        arguments: quote,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: const Color(0xFF1C2333),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Quote #$input not found'),
          backgroundColor: const Color(0xFF1C2333),
        ),
      );
    }
  }

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFD32F2F),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: label
          Text(
            'FOR APPROVAL',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white.withOpacity(0.85),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          // Row 2: QT# + input/typewriter + search icon
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'QT#',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _isInteracting
                    ? TextField(
                        focusNode: _focusNode,
                        controller: _inputController,
                        keyboardType: TextInputType.number,
                        // Quote numbers are digits only — strip letters/symbols.
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                        cursorColor: Colors.white,
                        decoration: const InputDecoration(
                          hintText: '',
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onSubmitted: (_) => _runSearch(),
                      )
                    : GestureDetector(
                        onTap: _activateInput,
                        child: AnimatedBuilder(
                          animation: _cursorController,
                          builder: (context, _) {
                            final cursorVisible = _cursorController.value > 0.5;
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedOpacity(
                                  opacity: _isInteracting ? 1.0 : 0.45,
                                  duration: const Duration(milliseconds: 300),
                                  child: Text(
                                    _displayDigits,
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Text(
                                  cursorVisible ? '|' : ' ',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  if (!_isInteracting) _activateInput();
                  _runSearch();
                },
                child: const Icon(
                  Icons.search,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Row 3: subtitle
          Text(
            'Tap, type the quote number and click search.',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.75),
            ),
          ),
        ],
      ),
    );
  }
}
