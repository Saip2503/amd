import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../providers.dart';

class AssistantScreen extends ConsumerWidget {
  const AssistantScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(chatProvider);
    final textController = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
          child: Text('AI Assistant', style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.bold, color: kOnSurface)),
        ),
        
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final msg = messages[index];
              return _ChatBubble(msg: msg);
            },
          ),
        ),
        
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: textController,
                  decoration: InputDecoration(
                    hintText: "What are you craving?",
                    hintStyle: GoogleFonts.inter(color: kOnSurfaceVariant),
                    filled: true,
                    fillColor: kSurface,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                  ),
                  onSubmitted: (val) {
                    if (val.trim().isNotEmpty) {
                      ref.read(chatProvider.notifier).sendMessage(val.trim());
                      textController.clear();
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 28,
                backgroundColor: kPrimary,
                child: IconButton(
                  icon: const Icon(Icons.send, color: kOnPrimary),
                  onPressed: () {
                    if (textController.text.trim().isNotEmpty) {
                      ref.read(chatProvider.notifier).sendMessage(textController.text.trim());
                    }
                  },
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage msg;
  const _ChatBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: msg.isUser ? kPrimary : kSurface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: msg.isUser ? [] : [const BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0,4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              msg.text,
              style: GoogleFonts.inter(fontSize: 15, height: 1.5, color: msg.isUser ? kOnPrimary : kOnSurface),
            ),
            if (msg.recipe != null) ...[
               const SizedBox(height: 12),
               Container(
                 padding: const EdgeInsets.all(16),
                 decoration: BoxDecoration(
                   color: kBackground, 
                   borderRadius: BorderRadius.circular(12),
                   border: Border.all(color: kSurfaceContainer)
                 ),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Row(
                       children: [
                         const Icon(Icons.restaurant, size: 16, color: kPrimary),
                         const SizedBox(width: 6),
                         Expanded(child: Text(msg.recipe!['name'], style: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: kOnSurface))),
                       ],
                     ),
                     const SizedBox(height: 8),
                     Text("Prep time: ${msg.recipe!['prep_time']} • ${msg.recipe!['calories']} kcal", style: GoogleFonts.inter(fontSize: 12, color: kOnSurfaceVariant)),
                     const SizedBox(height: 6),
                     Text("M: ${msg.recipe!['protein']}g P / ${msg.recipe!['carbs']}g C / ${msg.recipe!['fats']}g F", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: kTertiary)),
                   ]
                 ),
               )
            ]
          ],
        ),
      ),
    );
  }
}
