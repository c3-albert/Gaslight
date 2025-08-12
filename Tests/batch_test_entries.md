# 🚀 Automated Batch Testing for Groq AI

Since manual testing takes time, here's how to use the built-in testing features:

## **Quick Automated Testing**

### Method 1: Use Settings "Generate Test Entry" Button

1. **Add your Groq API key** from [console.groq.com/keys](https://console.groq.com/keys)
2. **Open Settings in the app**
3. **Scroll to "Testing" section**
4. **You'll see two buttons:**
   - "Generate Test Entry" (creates 1 entry)
   - "Generate 30 Days of Entries" (creates many entries)

### Testing Groq Generation:

**Basic Test:**
1. Settings → Add API Key → Test Connection
2. Tap "Generate Test Entry" 5 times
3. Each creates a unique, high-quality journal entry
4. Should take 2-3 seconds per generation

**Reality Level Testing:**
1. Generate entries at different reality levels:
   - Low (10%) → Creative, imaginative content
   - Medium (50%) → Balanced realistic/creative  
   - High (90%) → Grounded, realistic experiences

**Model Comparison:**
1. Try different models in Settings:
   - Mixtral 8x7B (best for creative writing)
   - Llama 3 70B (most capable)
   - Llama 3 8B (fastest)
   - Gemma 7B (good balance)

### Method 2: Bulk Generation Test

**For comprehensive testing:**
1. **Bulk Test:**
   - Tap "Generate 30 Days of Entries"
   - Wait for completion (may take several minutes)
   - Creates diverse entries across different dates/times

2. **Review in Entries tab:**
   - You'll see entries marked with AI type indicators
   - Check variety and quality across different reality levels
   - Verify no duplicate or repetitive content

## **What to Look For**

### Groq Entries Should Show:
- **High Quality**: Natural, contextual journal content
- **Variety**: No repetitive patterns or templates
- **Context Awareness**: Adapts to your recent writing style
- **Appropriate Length**: 100-150 words typically

### Performance Indicators:
- **Speed**: 2-3 seconds per generation
- **Reliability**: Consistent quality without errors
- **Network**: Requires internet connection
- **Security**: API key stored securely in Keychain

## **Expected Results Summary**

After running these tests, you should see:

📊 **High Quality Content:**
- Natural, human-like journal entries
- Contextually appropriate for reality level
- No repetitive or template-like patterns

⚡ **Consistent Performance:**
- Reliable 2-3 second generation time
- Proper error handling for network issues
- Graceful fallback messages when API fails

🎯 **Reality Level Intelligence:**
- Low reality → Creative, imaginative entries
- High reality → Realistic, grounded content
- Smooth gradation between levels

🔧 **Technical Validation:**
- API key storage in Keychain works
- Progress bars function correctly
- No crashes during generation
- Proper error messages for API issues

This approach lets you generate dozens of test entries quickly and validate the Groq integration systematically!