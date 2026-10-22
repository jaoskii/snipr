enum PlatformCategory { discord, social, messaging, custom }

class PlatformPreset {
  final String id;
  final String title;
  final String subtitle;
  final int targetSizeBytes; // in bytes
  final int defaultFps;
  final String recommendedResolution; // e.g., '1280x720', '1920x1080'
  final PlatformCategory category;

  const PlatformPreset({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.targetSizeBytes,
    this.defaultFps = 30,
    this.recommendedResolution = '1280x720',
    required this.category,
  });

  static const List<PlatformPreset> videoPresets = [
    PlatformPreset(
      id: 'discord_free',
      title: 'Discord Free',
      subtitle: '25 MB Limit',
      targetSizeBytes: 25 * 1024 * 1024,
      defaultFps: 30,
      recommendedResolution: '1280x720',
      category: PlatformCategory.discord,
    ),
    PlatformPreset(
      id: 'discord_legacy',
      title: 'Discord Mobile (10MB)',
      subtitle: 'Guaranteed 10 MB Safe Upload',
      targetSizeBytes: 9500 * 1024,
      defaultFps: 30,
      recommendedResolution: '1280x720',
      category: PlatformCategory.discord,
    ),
    PlatformPreset(
      id: 'discord_nitro',
      title: 'Discord Nitro',
      subtitle: '100 MB Limit (High Bitrate)',
      targetSizeBytes: 98 * 1024 * 1024,
      defaultFps: 60,
      recommendedResolution: '1920x1080',
      category: PlatformCategory.discord,
    ),
    PlatformPreset(
      id: 'twitter_x',
      title: 'Twitter / X',
      subtitle: 'Crisp 1080p Web Clip',
      targetSizeBytes: 45 * 1024 * 1024,
      defaultFps: 60,
      recommendedResolution: '1920x1080',
      category: PlatformCategory.social,
    ),
    PlatformPreset(
      id: 'whatsapp_quick',
      title: 'WhatsApp / Telegram',
      subtitle: '16 MB Quick Share',
      targetSizeBytes: 15 * 1024 * 1024,
      defaultFps: 30,
      recommendedResolution: '1280x720',
      category: PlatformCategory.messaging,
    ),
    PlatformPreset(
      id: 'discord_emote_gif',
      title: 'Discord Emote/GIF',
      subtitle: 'Under 500 KB Animated Clip',
      targetSizeBytes: 500 * 1024,
      defaultFps: 20,
      recommendedResolution: '320x180',
      category: PlatformCategory.discord,
    ),
  ];
}
