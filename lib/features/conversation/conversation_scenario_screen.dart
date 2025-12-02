import 'package:flutter/material.dart';
import '../../shared/models/conversation.dart';
import 'ai_conversation_screen.dart';
import '../../core/theme/openai_theme.dart';
import '../../shared/widgets/gradient_card.dart';

/// Screen for selecting conversation scenarios
class ConversationScenarioScreen extends StatelessWidget {
  const ConversationScenarioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 对话练习'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '选择对话场景',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '与AI扮演的角色进行真实场景对话，提升意大利语口语能力',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: ConversationScenario.all.length,
                itemBuilder: (context, index) {
                  final scenario = ConversationScenario.all[index];
                  return _ScenarioCard(
                    scenario: scenario,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AIConversationScreen(
                            scenario: scenario,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScenarioCard extends StatelessWidget {
  final ConversationScenario scenario;
  final VoidCallback onTap;

  const _ScenarioCard({
    required this.scenario,
    required this.onTap,
  });

  Gradient _getScenarioGradient(String id) {
    // 根据场景ID返回不同的渐变
    switch (id) {
      case 'restaurant':
        return LinearGradient(colors: [OpenAITheme.warning, Color(0xFFD97706)]);
      case 'airport':
        return LinearGradient(colors: [OpenAITheme.info, Color(0xFF2563EB)]);
      case 'shopping':
        return LinearGradient(colors: [OpenAITheme.openaiGreen, OpenAITheme.openaiGreenDark]);
      case 'doctor':
        return LinearGradient(colors: [OpenAITheme.error, Color(0xFFDC2626)]);
      case 'interview':
        return const LinearGradient(
          colors: [Color(0xFF9C27B0), Color(0xFF673AB7)],
        );
      case 'friend':
        return const LinearGradient(
          colors: [Color(0xFFFF8A65), Color(0xFFFF6F00)],
        );
      default:
        return LinearGradient(colors: [OpenAITheme.openaiGreen, OpenAITheme.openaiGreenDark]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      gradient: _getScenarioGradient(scenario.id),
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon and level badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  scenario.icon,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  scenario.level,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Italian name
          Text(
            scenario.nameIt,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          // Chinese name
          Text(
            scenario.nameZh,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          // Description
          Text(
            scenario.description,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.85),
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
