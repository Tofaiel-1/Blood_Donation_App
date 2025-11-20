# 🤖 AI Assistant Setup Guide

## Overview
The Blood Donation App includes a powerful AI Assistant powered by Google's Gemini API. It can help users with donation guidance, eligibility checks, finding centers, emergency requests, and more.

## ✨ Features

### 🎯 Core Capabilities
- **Eligibility Checks**: Ask about donation requirements and timing
- **Find Centers**: Locate nearby blood banks and donation centers
- **Smart Matching**: Find donors based on blood type, location, and urgency
- **Schedule Donations**: Book appointments at convenient times
- **Emergency Assistance**: Create urgent blood requests with conversational flow
- **Health Dashboard**: Access your donation history and health metrics
- **Awareness & Stories**: Get inspired by donor stories and campaigns

### 🌐 Online & Offline Modes
- **Online Mode**: Uses Google Gemini API for intelligent, context-aware responses
- **Offline Mode**: Falls back to rule-based responses with cached data
- **/offline-mode**: Switch to offline mode manually
- **/update-cache**: Update cached content for offline use

### 📝 Slash Commands
Power users can leverage slash commands for quick actions:

- `/search [topic]` - Search for specific blood donation information
- `/news` - Get latest verified news from trusted health sources
- `/trends` - View trending topics in blood donation
- `/feedback [topic]` - Community feedback on specific topics
- `/donor-match` - Quick access to donor matching
- `/drives` - View upcoming blood drives
- `/alerts on/off` - Toggle emergency alert notifications
- `/widgets` - Customize your home dashboard
- `/profile` - Quick access to your profile
- `/update-cache` - Refresh cached content
- `/offline-mode` - Switch to offline operation

### 🎨 UI Features
- **Smart Suggestions**: Context-aware quick reply buttons
- **Typing Indicators**: Beautiful animated dots while AI responds
- **Gradient Design**: Matches app's blood-themed color palette
- **Dark Mode Support**: Seamless light/dark theme integration
- **Voice Input**: Coming soon - placeholder for voice commands

## 🔧 Setup Instructions

### Step 1: Get Your Gemini API Key

1. Visit [Google AI Studio](https://aistudio.google.com/app/apikey)
2. Sign in with your Google account
3. Click **"Get API Key"** or **"Create API Key"**
4. Select or create a project
5. Copy your API key (starts with `AIza...`)

### Step 2: Configure Environment Variables

1. **Create `.env` file** in the project root:
   ```bash
   cd /Users/khan/Downloads/Blood_Donation_App
   cp .env.example .env
   ```

2. **Edit `.env` file** and add your API key:
   ```bash
   # Google Gemini API key (required for chatbot)
   GEMINI_API_KEY=AIzaSyYourActualAPIKeyHere

   # Default Gemini model to use
   GEMINI_MODEL=gemini-1.5-flash

   # Optional system prompt to guide the assistant
   GEMINI_SYSTEM_PROMPT=You are a helpful blood donation assistant. Provide concise, accurate information about blood donation, eligibility, health, and safety. Always encourage saving lives while prioritizing donor health and safety.
   ```

3. **Important**: Never commit your `.env` file to version control!
   - The `.gitignore` already includes `.env`
   - Use `.env.example` as a template for others

### Step 3: Install Dependencies

Make sure `flutter_dotenv` and `google_generative_ai` are in your `pubspec.yaml`:

```yaml
dependencies:
  flutter_dotenv: ^5.1.0
  google_generative_ai: ^0.4.6
```

Run:
```bash
flutter pub get
```

### Step 4: Load Environment in Main

The app already loads the `.env` file in `main.dart`:

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env"); // Load environment variables
  runApp(const MyApp());
}
```

### Step 5: Test the AI Assistant

1. **Run the app**:
   ```bash
   flutter run
   ```

2. **Access the AI Assistant**:
   - Tap the **"AI Assistant"** floating action button (red button with robot icon)
   - Or navigate to `/chatbot` route

3. **Try these test prompts**:
   - "Am I eligible to donate blood?"
   - "Find nearby donation centers"
   - "I need emergency help"
   - "Schedule a donation"
   - "/news" (slash command)
   - "/trends" (slash command)

## 🎯 Customization

### Customize System Prompt

Edit the `GEMINI_SYSTEM_PROMPT` in `.env`:

```bash
GEMINI_SYSTEM_PROMPT=You are Dr. Bloodwise, a compassionate blood donation expert with 20 years of experience. You provide warm, encouraging guidance while ensuring medical accuracy. Always prioritize donor safety and well-being.
```

### Adjust Temperature

Temperature controls response creativity (0.0 = focused, 1.0 = creative):

```bash
GEMINI_TEMPERATURE=0.3
```

### Change Model

Switch between Gemini models:

```bash
# Faster, lightweight responses
GEMINI_MODEL=gemini-1.5-flash

# More detailed, thoughtful responses
GEMINI_MODEL=gemini-1.5-pro
```

### Extend Conversation Logic

Edit `lib/screens/chatbot/chatbot_screen.dart`:

1. **Add new intents** in `ConversationIntent` enum
2. **Add response patterns** in `_generateAIResponse()` method
3. **Add new actions** in `ChatAction` enum
4. **Handle actions** in `_handleChatAction()` method

Example - Add "Tips" Intent:

```dart
enum ConversationIntent { 
  none, 
  emergency, 
  schedule, 
  tips  // New
}

// In _generateAIResponse():
if (message.contains('tips') || message.contains('advice')) {
  _intent = ConversationIntent.tips;
  return AIReply(
    text: 'I can share tips on preparation, recovery, or general health. What would you like to know?',
    suggestions: const ['Preparation tips', 'Recovery tips', 'General health'],
  );
}
```

## 🚨 Troubleshooting

### Issue: "Chatbot not configured: missing API key"

**Solution**:
1. Ensure `.env` file exists in project root
2. Check that `GEMINI_API_KEY` is set correctly
3. Verify the key starts with `AIza`
4. Restart the app after changing `.env`

### Issue: "Chat error: API key not valid"

**Solution**:
1. Verify your API key at [Google AI Studio](https://aistudio.google.com/app/apikey)
2. Check for extra spaces or characters in `.env`
3. Ensure billing is enabled if required
4. Try generating a new API key

### Issue: Offline mode responses only

**Solution**:
1. Check internet connection
2. Verify `GEMINI_API_KEY` is loaded: Add debug print in `GeminiChatService`
3. Look for initialization errors in console
4. Try manual `/update-cache` command

### Issue: AI responses are too generic

**Solution**:
1. Improve `GEMINI_SYSTEM_PROMPT` with more specific instructions
2. Lower `GEMINI_TEMPERATURE` for more focused responses (0.2-0.4)
3. Add more context in user messages
4. Use slash commands for specific queries

### Issue: Slow responses

**Solution**:
1. Switch to `gemini-1.5-flash` model (faster)
2. Keep prompts concise
3. Check network speed
4. Consider implementing response caching

## 📊 Analytics & Monitoring

### Track Usage

Add analytics to monitor AI usage:

```dart
void _sendMessage() {
  // ... existing code ...
  
  // Log AI usage
  FirebaseAnalytics.instance.logEvent(
    name: 'ai_assistant_query',
    parameters: {
      'query_type': _intent.toString(),
      'online_mode': _onlineMode,
    },
  );
}
```

### Monitor Costs

1. Visit [Google Cloud Console](https://console.cloud.google.com/)
2. Navigate to **APIs & Services > Gemini API**
3. View usage and set up billing alerts
4. Free tier: 60 requests per minute

## 🎨 UI Customization

### Theme Integration

The AI Assistant is fully themed with your app's design system:

- **Colors**: Uses `AppColors` for blood-red gradients
- **Typography**: Uses `AppTextStyles` with Poppins/Montserrat fonts
- **Components**: Matches Material 3 design with rounded corners and shadows

### Customize Chat Bubbles

Edit `_buildMessageBubble()` in `chatbot_screen.dart`:

```dart
decoration: BoxDecoration(
  gradient: message.isUser 
    ? AppColors.primaryGradient  // User messages with gradient
    : null,
  color: !message.isUser ? Colors.white : null,
  borderRadius: BorderRadius.circular(20),  // Adjust roundness
  // ... rest of code
)
```

### Add Animations

Enhance with page transition animations:

```dart
Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => ChatbotScreen(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: animation.drive(
          Tween(begin: Offset(1.0, 0.0), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeInOut)),
        ),
        child: child,
      );
    },
  ),
);
```

## 🔐 Privacy & Security

### Data Handling
- User messages are sent to Google Gemini API
- No messages are stored on our servers
- Offline mode uses only local data
- See [Google Gemini Privacy](https://ai.google.dev/terms)

### Best Practices
1. Don't send sensitive personal information (SSN, payment details)
2. Use offline mode for private queries
3. Clear chat history periodically
4. Review Google's data usage policy

### GDPR Compliance
- Inform users about AI usage
- Provide option to disable AI features
- Allow data deletion requests
- Document data processing agreements

## 📱 Integration with Other Features

### Link to Screens

The AI Assistant can navigate to app screens:

```dart
case ChatAction.findCenters:
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => DonateScreen(initialTabIndex: 2)),
  );
  break;
```

### Emergency Flow

The emergency intent creates a guided conversational flow:

1. User: "I need emergency help"
2. AI: "What blood type?" → Buttons: O-, A+, B+, etc.
3. User: "O-"
4. AI: "Which hospital?" → Suggestions shown
5. User: "City Hospital"
6. AI: "How urgent?" → Urgent | Critical
7. User: "Critical"
8. AI: Creates emergency request and navigates to `RequestPostingScreen`

### Health Dashboard

Links to user's profile and health metrics:

```dart
case ChatAction.openHealthDashboard:
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => ProfileScreen()),
  );
  break;
```

## 🚀 Advanced Features

### Multi-turn Conversations

The assistant maintains context through `ConversationIntent`:

```dart
if (_intent == ConversationIntent.emergency) {
  return _handleEmergencyFlow(message);
}
```

### Smart Suggestions

Dynamic suggestions based on user query:

```dart
AIReply(
  text: 'Found 3 nearby centers.',
  suggestions: const [
    'Show on map',
    'Schedule donation',
    'Call center',
  ],
)
```

### Caching for Offline

Update and store content for offline use:

```dart
_cache['news'] = CachedEntry(
  key: 'news',
  title: 'Latest News',
  lines: [...],
  sources: [...],
  updatedAt: DateTime.now(),
);
```

## 📚 Resources

- [Google Gemini API Docs](https://ai.google.dev/docs)
- [Flutter DotEnv Package](https://pub.dev/packages/flutter_dotenv)
- [Google Generative AI Package](https://pub.dev/packages/google_generative_ai)
- [Blood Donation Guidelines (WHO)](https://www.who.int/health-topics/blood-safety)

## 🤝 Contributing

Want to improve the AI Assistant?

1. **Add new conversation patterns** in `_generateAIResponse()`
2. **Create custom commands** in `_handleSlashCommand()`
3. **Enhance UI** with animations and effects
4. **Improve prompts** for better AI responses
5. **Add analytics** to track usage patterns

## 📄 License

The AI Assistant integration is part of the Blood Donation App.
Uses Google Gemini API under their terms of service.

---

**Happy coding! Let's save lives with AI! 🩸🤖**
