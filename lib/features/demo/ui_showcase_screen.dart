import 'package:flutter/material.dart';
import '../../core/theme/modern_theme.dart';
import '../../shared/widgets/gradient_card.dart';

/// UI展示页面 - 演示新的现代化组件
class UIShowcaseScreen extends StatelessWidget {
  const UIShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新UI预览'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Text(
              '🎨 现代化UI组件',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '全新设计风格，灵感来自 Duolingo',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),

            // 1. 渐变卡片展示
            Text(
              '渐变卡片 (GradientCard)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GradientCard(
                    gradient: ModernTheme.primaryGradient,
                    child: const Column(
                      children: [
                        Icon(Icons.book, color: Colors.white, size: 40),
                        SizedBox(height: 8),
                        Text(
                          '学习',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GradientCard(
                    gradient: ModernTheme.secondaryGradient,
                    child: const Column(
                      children: [
                        Icon(Icons.school, color: Colors.white, size: 40),
                        SizedBox(height: 8),
                        Text(
                          '语法',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // 2. 统计卡片
            Text(
              '统计卡片 (StatCard)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: '连续学习',
                    value: '15',
                    icon: Icons.local_fire_department,
                    gradient: ModernTheme.accentGradient,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    label: '已学单词',
                    value: '520',
                    icon: Icons.check_circle,
                    gradient: ModernTheme.secondaryGradient,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // 3. 渐变按钮
            Text(
              '渐变按钮 (GradientButton)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Center(
              child: GradientButton(
                text: '开始学习',
                icon: Icons.play_arrow,
                gradient: ModernTheme.primaryGradient,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('按钮已点击！')),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: GradientButton(
                text: '查看统计',
                icon: Icons.bar_chart,
                gradient: ModernTheme.secondaryGradient,
                onPressed: () {},
              ),
            ),
            const SizedBox(height: 32),

            // 4. 浮动卡片
            Text(
              '浮动卡片 (FloatingCard)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            FloatingCard(
              onTap: () {},
              child: const Row(
                children: [
                  Icon(Icons.volume_up, size: 32, color: ModernTheme.primaryColor),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TTS 语音设置',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '选择意大利语发音',
                          style: TextStyle(
                            fontSize: 14,
                            color: ModernTheme.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: ModernTheme.textLight),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 5. 玻璃态卡片
            Text(
              '玻璃态卡片 (GlassCard)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            GlassCard(
              backgroundColor: ModernTheme.primaryColor,
              child: const Row(
                children: [
                  Icon(Icons.lightbulb, size: 32, color: Colors.white),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      '半透明玻璃效果，适合叠加在图片上',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 6. 渐变进度条
            Text(
              '渐变进度条 (GradientProgressBar)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('今日目标', style: TextStyle(fontWeight: FontWeight.w600)),
                    Text('15 / 20 词', style: TextStyle(color: ModernTheme.textLight)),
                  ],
                ),
                SizedBox(height: 8),
                GradientProgressBar(
                  progress: 0.75,
                  height: 12,
                  gradient: ModernTheme.primaryGradient,
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('本周学习', style: TextStyle(fontWeight: FontWeight.w600)),
                    Text('4 / 7 天', style: TextStyle(color: ModernTheme.textLight)),
                  ],
                ),
                SizedBox(height: 8),
                GradientProgressBar(
                  progress: 0.57,
                  height: 12,
                  gradient: ModernTheme.secondaryGradient,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // 对比说明
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ModernTheme.backgroundColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ModernTheme.primaryColor.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info, color: ModernTheme.primaryColor),
                      SizedBox(width: 8),
                      Text(
                        '新UI特点',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildFeature('✅ 渐变色增加视觉层次'),
                  _buildFeature('✅ 24dp大圆角更柔和'),
                  _buildFeature('✅ 多层阴影增加深度感'),
                  _buildFeature('✅ 现代化字体排版'),
                  _buildFeature('✅ 淡紫灰背景更护眼'),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFeature(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 15, height: 1.5),
      ),
    );
  }
}
