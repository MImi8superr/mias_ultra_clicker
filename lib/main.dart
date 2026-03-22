import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MiasUltraClickerApp());
}

class MiasUltraClickerApp extends StatelessWidget {
  const MiasUltraClickerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mias Ultra Clicker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFB703),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0B1020),
      ),
      home: const ClickerPage(),
    );
  }
}

enum ShopEffect { addClick, addAuto, multClick, multAuto }

class ShopItem {
  final String name;
  final String subtitle;
  final int cost;
  final int value;
  final IconData icon;
  final ShopEffect effect;

  const ShopItem({
    required this.name,
    required this.subtitle,
    required this.cost,
    required this.value,
    required this.icon,
    required this.effect,
  });
}

class ClickerPage extends StatefulWidget {
  const ClickerPage({super.key});

  @override
  State<ClickerPage> createState() => _ClickerPageState();
}

class _ClickerPageState extends State<ClickerPage> {
  SharedPreferences? prefs;
  Timer? autoTimer;
  final AudioPlayer musicPlayer = AudioPlayer();

  bool isLoaded = false;
  bool musicEnabled = true;
  bool musicStarted = false;

  int coins = 0;

  int clickBase = 1;
  int autoBase = 0;

  int clickMultiplier = 1;
  int autoMultiplier = 1;

  double clickButtonScale = 1.0;

  final List<ShopItem> clickUpgrades = const [
    ShopItem(
      name: 'Basic Tap',
      subtitle: '+1 pro Klick',
      cost: 50,
      value: 1,
      icon: Icons.touch_app,
      effect: ShopEffect.addClick,
    ),
    ShopItem(
      name: 'Iron Finger',
      subtitle: '+5 pro Klick',
      cost: 250,
      value: 5,
      icon: Icons.ads_click,
      effect: ShopEffect.addClick,
    ),
    ShopItem(
      name: 'Laser Tap',
      subtitle: '+25 pro Klick',
      cost: 1500,
      value: 25,
      icon: Icons.flash_on,
      effect: ShopEffect.addClick,
    ),
    ShopItem(
      name: 'Nitro Tap',
      subtitle: '+100 pro Klick',
      cost: 7000,
      value: 100,
      icon: Icons.bolt,
      effect: ShopEffect.addClick,
    ),
    ShopItem(
      name: 'Quantum Tap',
      subtitle: '+1000 pro Klick',
      cost: 65000,
      value: 1000,
      icon: Icons.local_fire_department,
      effect: ShopEffect.addClick,
    ),
    ShopItem(
      name: 'Ultra Tap',
      subtitle: '+10000 pro Klick',
      cost: 900000,
      value: 10000,
      icon: Icons.rocket_launch,
      effect: ShopEffect.addClick,
    ),
  ];

  final List<ShopItem> autoUpgrades = const [
    ShopItem(
      name: 'Mini Bot',
      subtitle: '+1 pro Sekunde',
      cost: 100,
      value: 1,
      icon: Icons.smart_toy,
      effect: ShopEffect.addAuto,
    ),
    ShopItem(
      name: 'Worker Drone',
      subtitle: '+5 pro Sekunde',
      cost: 500,
      value: 5,
      icon: Icons.precision_manufacturing,
      effect: ShopEffect.addAuto,
    ),
    ShopItem(
      name: 'Auto Rig',
      subtitle: '+25 pro Sekunde',
      cost: 3000,
      value: 25,
      icon: Icons.memory,
      effect: ShopEffect.addAuto,
    ),
    ShopItem(
      name: 'Click Factory',
      subtitle: '+100 pro Sekunde',
      cost: 15000,
      value: 100,
      icon: Icons.factory,
      effect: ShopEffect.addAuto,
    ),
    ShopItem(
      name: 'Nano Swarm',
      subtitle: '+1000 pro Sekunde',
      cost: 170000,
      value: 1000,
      icon: Icons.hub,
      effect: ShopEffect.addAuto,
    ),
    ShopItem(
      name: 'Galaxy Farm',
      subtitle: '+10000 pro Sekunde',
      cost: 2000000,
      value: 10000,
      icon: Icons.auto_awesome,
      effect: ShopEffect.addAuto,
    ),
  ];

  final List<ShopItem> clickMultiplierUpgrades = const [
    ShopItem(
      name: 'Turbo Glove',
      subtitle: 'x2 auf Klick-Power',
      cost: 4000,
      value: 2,
      icon: Icons.sports_motorsports,
      effect: ShopEffect.multClick,
    ),
    ShopItem(
      name: 'Plasma Hand',
      subtitle: 'x5 auf Klick-Power',
      cost: 40000,
      value: 5,
      icon: Icons.back_hand,
      effect: ShopEffect.multClick,
    ),
    ShopItem(
      name: 'Hyper Tap',
      subtitle: 'x10 auf Klick-Power',
      cost: 300000,
      value: 10,
      icon: Icons.electric_bolt,
      effect: ShopEffect.multClick,
    ),
    ShopItem(
      name: 'God Finger',
      subtitle: 'x50 auf Klick-Power',
      cost: 9000000,
      value: 50,
      icon: Icons.star,
      effect: ShopEffect.multClick,
    ),
  ];

  final List<ShopItem> autoMultiplierUpgrades = const [
    ShopItem(
      name: 'Server Boost',
      subtitle: 'x2 auf Auto-Power',
      cost: 7000,
      value: 2,
      icon: Icons.dns,
      effect: ShopEffect.multAuto,
    ),
    ShopItem(
      name: 'Data Center',
      subtitle: 'x5 auf Auto-Power',
      cost: 65000,
      value: 5,
      icon: Icons.storage,
      effect: ShopEffect.multAuto,
    ),
    ShopItem(
      name: 'Time Engine',
      subtitle: 'x10 auf Auto-Power',
      cost: 500000,
      value: 10,
      icon: Icons.timer,
      effect: ShopEffect.multAuto,
    ),
    ShopItem(
      name: 'Black Hole Core',
      subtitle: 'x50 auf Auto-Power',
      cost: 15000000,
      value: 50,
      icon: Icons.public,
      effect: ShopEffect.multAuto,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadGame();
  }

  int get clickPerTap => clickBase * clickMultiplier;
  int get autoPerSecond => autoBase * autoMultiplier;

  Future<void> _loadGame() async {
    prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      coins = prefs?.getInt('coins') ?? 0;
      clickBase = prefs?.getInt('clickBase') ?? 1;
      autoBase = prefs?.getInt('autoBase') ?? 0;
      clickMultiplier = prefs?.getInt('clickMultiplier') ?? 1;
      autoMultiplier = prefs?.getInt('autoMultiplier') ?? 1;
      musicEnabled = prefs?.getBool('musicEnabled') ?? true;
      isLoaded = true;
    });

    _startAutoTimer();

    if (musicEnabled) {
      await _tryStartMusic();
    }
  }

  void _startAutoTimer() {
    autoTimer?.cancel();

    autoTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || !isLoaded || autoPerSecond <= 0) return;

      setState(() {
        coins += autoPerSecond;
      });

      _saveGame();
    });
  }

  Future<void> _tryStartMusic() async {
    try {
      await musicPlayer.setReleaseMode(ReleaseMode.loop);
      await musicPlayer.setVolume(0.35);

      if (!musicStarted) {
        await musicPlayer.play(AssetSource('audio/bg_music.mp3'));
        musicStarted = true;
      } else {
        await musicPlayer.resume();
      }
    } catch (_) {
      // Falls Audio auf der aktuellen Plattform noch nicht direkt startet
    }
  }

  Future<void> _stopMusic() async {
    try {
      await musicPlayer.stop();
    } catch (_) {}
  }

  Future<void> _toggleMusic() async {
    setState(() {
      musicEnabled = !musicEnabled;
    });

    await _saveGame();

    if (musicEnabled) {
      await _tryStartMusic();
      _showMessage('Musik an');
    } else {
      await _stopMusic();
      _showMessage('Musik aus');
    }
  }

  Future<void> _saveGame() async {
    final p = prefs ?? await SharedPreferences.getInstance();
    prefs = p;

    await p.setInt('coins', coins);
    await p.setInt('clickBase', clickBase);
    await p.setInt('autoBase', autoBase);
    await p.setInt('clickMultiplier', clickMultiplier);
    await p.setInt('autoMultiplier', autoMultiplier);
    await p.setBool('musicEnabled', musicEnabled);
  }

  Future<void> _tapMainButton() async {
    if (!isLoaded) return;

    if (musicEnabled) {
      _tryStartMusic();
    }

    setState(() {
      coins += clickPerTap;
      clickButtonScale = 0.92;
    });

    _saveGame();

    await Future.delayed(const Duration(milliseconds: 90));

    if (!mounted) return;

    setState(() {
      clickButtonScale = 1.0;
    });
  }

  void _buyItem(ShopItem item) {
    if (coins < item.cost) {
      _showMessage('Zu wenig Coins 😅');
      return;
    }

    setState(() {
      coins -= item.cost;

      switch (item.effect) {
        case ShopEffect.addClick:
          clickBase += item.value;
          break;
        case ShopEffect.addAuto:
          autoBase += item.value;
          break;
        case ShopEffect.multClick:
          clickMultiplier *= item.value;
          break;
        case ShopEffect.multAuto:
          autoMultiplier *= item.value;
          break;
      }
    });

    _saveGame();
    _showMessage('${item.name} gekauft!');
  }

  Future<void> _resetGame() async {
    setState(() {
      coins = 0;
      clickBase = 1;
      autoBase = 0;
      clickMultiplier = 1;
      autoMultiplier = 1;
    });

    await _saveGame();
    _showMessage('Spielstand zurückgesetzt');
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 900),
      ),
    );
  }

  String formatNumber(num value) {
    if (value < 1000) return value.toStringAsFixed(0);

    const suffixes = ['K', 'M', 'B', 'T', 'Qa', 'Qi'];
    double shortened = value.toDouble();
    int suffixIndex = -1;

    while (shortened >= 1000 && suffixIndex < suffixes.length - 1) {
      shortened /= 1000;
      suffixIndex++;
    }

    String text;
    if (shortened >= 100) {
      text = shortened.toStringAsFixed(0);
    } else if (shortened >= 10) {
      text = shortened.toStringAsFixed(1);
    } else {
      text = shortened.toStringAsFixed(2);
    }

    text = text.replaceAll(RegExp(r'0+$'), '');
    text = text.replaceAll(RegExp(r'\.$'), '');

    return '$text${suffixes[suffixIndex]}';
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: const Color(0xFFFFD166)),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.75),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFFD166)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }

  Widget _buildShopCard(ShopItem item) {
    final bool canAfford = coins >= item.cost;

    return Container(
      width: 200,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: canAfford
              ? [const Color(0xFF1B2440), const Color(0xFF283A6A)]
              : [const Color(0xFF1A1D28), const Color(0xFF202534)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: canAfford
              ? const Color(0xFFFFD166).withOpacity(0.35)
              : Colors.white.withOpacity(0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFFFD166).withOpacity(0.18),
            child: Icon(item.icon, color: const Color(0xFFFFD166), size: 26),
          ),
          const SizedBox(height: 12),
          Text(
            item.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            item.subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          Text(
            '${formatNumber(item.cost)} Coins',
            style: TextStyle(
              color: Colors.white.withOpacity(0.82),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: canAfford ? () => _buyItem(item) : null,
              icon: const Icon(Icons.shopping_cart),
              label: const Text('Kaufen'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: canAfford
                    ? const Color(0xFFFFB703)
                    : Colors.grey.shade700,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopRow({
    required String title,
    required IconData icon,
    required List<ShopItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title, icon),
        const SizedBox(height: 12),
        SizedBox(
          height: 255,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) => _buildShopCard(items[index]),
          ),
        ),
      ],
    );
  }

  Future<void> _showResetDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Spielstand zurücksetzen?'),
          content: const Text('Alle Coins und Upgrades werden gelöscht.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Abbrechen'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _resetGame();
              },
              child: const Text('Zurücksetzen'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    autoTimer?.cancel();
    musicPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mias Ultra Clicker',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: _toggleMusic,
            icon: Icon(musicEnabled ? Icons.music_note : Icons.music_off),
            tooltip: 'Musik',
          ),
          IconButton(
            onPressed: _showResetDialog,
            icon: const Icon(Icons.restart_alt),
            tooltip: 'Reset',
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0B1020), Color(0xFF101935), Color(0xFF1A2452)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: Colors.white.withOpacity(0.07),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Coins',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white.withOpacity(0.78),
                        ),
                      ),
                      const SizedBox(height: 8),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: child,
                          );
                        },
                        child: Text(
                          formatNumber(coins),
                          key: ValueKey(coins),
                          style: const TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFFFD166),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    _buildStatCard(
                      icon: Icons.ads_click,
                      label: 'Pro Klick',
                      value: '+${formatNumber(clickPerTap)}',
                    ),
                    const SizedBox(width: 10),
                    _buildStatCard(
                      icon: Icons.timer,
                      label: 'Pro Sekunde',
                      value: '+${formatNumber(autoPerSecond)}',
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildStatCard(
                      icon: Icons.trending_up,
                      label: 'Klick Multi',
                      value: 'x${formatNumber(clickMultiplier)}',
                    ),
                    const SizedBox(width: 10),
                    _buildStatCard(
                      icon: Icons.dns,
                      label: 'Auto Multi',
                      value: 'x${formatNumber(autoMultiplier)}',
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                AnimatedScale(
                  scale: clickButtonScale,
                  duration: const Duration(milliseconds: 90),
                  curve: Curves.easeOut,
                  child: GestureDetector(
                    onTap: _tapMainButton,
                    child: Container(
                      width: 210,
                      height: 210,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const RadialGradient(
                          colors: [
                            Color(0xFFFFE08A),
                            Color(0xFFFFB703),
                            Color(0xFFFB8500),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFB703).withOpacity(0.40),
                            blurRadius: 30,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.touch_app, size: 54, color: Colors.black),
                          SizedBox(height: 10),
                          Text(
                            'KLICK',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: ListView(
                    children: [
                      _buildShopRow(
                        title: 'Klick-Upgrades',
                        icon: Icons.flash_on,
                        items: clickUpgrades,
                      ),
                      const SizedBox(height: 18),
                      _buildShopRow(
                        title: 'Auto-Clicker',
                        icon: Icons.smart_toy,
                        items: autoUpgrades,
                      ),
                      const SizedBox(height: 18),
                      _buildShopRow(
                        title: 'Klick-Multiplikatoren',
                        icon: Icons.bolt,
                        items: clickMultiplierUpgrades,
                      ),
                      const SizedBox(height: 18),
                      _buildShopRow(
                        title: 'Auto-Multiplikatoren',
                        icon: Icons.storage,
                        items: autoMultiplierUpgrades,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
