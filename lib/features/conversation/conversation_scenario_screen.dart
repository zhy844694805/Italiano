import 'package:flutter/material.dart';
import '../../shared/models/conversation.dart';
import 'ai_conversation_screen.dart';
import '../../core/theme/openai_theme.dart';

/// Screen for selecting conversation scenarios - OpenAI Style
class ConversationScenarioScreen extends StatelessWidget {
  const ConversationScenarioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OpenAITheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: OpenAITheme.bgPrimary,
        title: const Text('AI 对话练习'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              '选择对话场景',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '与AI扮演的角色进行真实场景对话，提升意大利语口语能力',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),

            // Scenario Cards - List Style
            ...ConversationScenario.all.map((scenario) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ScenarioCard(
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
              ),
            )),
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

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: OpenAITheme.floatingCardDecoration(),
          child: Row(
            children: [
              // Icon Container
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: OpenAITheme.bgSecondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    scenario.icon,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Italian name + Level badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            scenario.nameIt,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: OpenAITheme.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: OpenAITheme.openaiGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            scenario.level,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: OpenAITheme.openaiGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Chinese name
                    Text(
                      scenario.nameZh,
                      style: const TextStyle(
                        fontSize: 14,
                        color: OpenAITheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Description
                    Text(
                      scenario.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: OpenAITheme.textTertiary,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Arrow indicator
              const SizedBox(width: 12),
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: OpenAITheme.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
