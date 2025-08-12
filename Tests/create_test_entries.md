# 🧪 Groq AI Testing Plan - Practical Version

Since we need to test the actual Groq integration functionality, here's a step-by-step plan to create test entries and validate the system:

## **Phase 1: Setup and Basic Testing**

### Step 1: Configure Groq API
1. **Get API Key** from [console.groq.com/keys](https://console.groq.com/keys)
2. **Open Gaslight app**
3. **Go to Settings** → AI Engine
4. **Add API Key** → Paste your key
5. **Test Connection** → Should show "✅ Groq connection successful"

### Step 2: Basic Generation Testing
**Create 5 test entries** with these prompts:

**Test Entry 1:**
- Prompt: "Today I woke up feeling"
- Reality Level: 50%
- Tap "Write for Me"
- Save as "Groq Test 1"

**Test Entry 2:**
- Prompt: "Something unexpected happened when I" 
- Reality Level: 30%
- Tap "Edit for Me"
- Save as "Groq Test 2"

**Test Entry 3:**
- Prompt: "I've been thinking about"
- Reality Level: 70%
- Tap "Write for Me"
- Save as "Groq Test 3"

**Test Entry 4:**
- Prompt: "The strangest thing occurred while I was"
- Reality Level: 20%
- Tap "Write for Me" 
- Save as "Groq Test 4"

**Test Entry 5:**
- Prompt: "Walking home tonight, I noticed"
- Reality Level: 80%
- Tap "Edit for Me"
- Save as "Groq Test 5"

## **Phase 2: Reality Level Testing**

### Step 3: Test Reality Level Intelligence
**Low Reality Testing (Creative/Imaginative):**

**Test Entry 6:**
- Prompt: "I discovered something impossible today"
- Reality Level: 10%
- Tap "Write for Me"
- Save as "Low Reality Test"
- **Expected**: Creative, surreal, imaginative content

**Test Entry 7:**
- Prompt: "My morning routine took an unexpected turn"
- Reality Level: 20%
- Tap "Write for Me"
- Save as "Low Reality Test 2"

**High Reality Testing (Grounded/Realistic):**

**Test Entry 8:**
- Prompt: "I had a normal day at work"
- Reality Level: 90%
- Tap "Write for Me"
- Save as "High Reality Test"
- **Expected**: Realistic, grounded, everyday experiences

**Test Entry 9:**
- Prompt: "Went grocery shopping this afternoon"
- Reality Level: 80%
- Tap "Write for Me"
- Save as "High Reality Test 2"

**Medium Reality Testing (Balanced):**

**Test Entry 10:**
- Prompt: "Something made me wonder about life"
- Reality Level: 50%
- Tap "Write for Me"
- Save as "Medium Reality Test"
- **Expected**: Balanced mix of realistic and creative elements

## **Phase 3: Model Comparison Testing**

### Step 4: Test Different Groq Models
1. **Go to Settings** → AI Engine
2. **Test each model with the same prompt:**

**Prompt**: "Today was one of those days that makes you think"

**Mixtral Test:**
- Select "Mixtral 8x7B" model
- Reality Level: 50%
- Generate entry
- Save as "Mixtral Test"

**Llama 3 70B Test:**
- Select "Llama 3 70B" model
- Reality Level: 50%
- Generate entry
- Save as "Llama 70B Test"

**Llama 3 8B Test:**
- Select "Llama 3 8B" model
- Reality Level: 50%
- Generate entry
- Save as "Llama 8B Test"

**Gemma Test:**
- Select "Gemma 7B" model
- Reality Level: 50%
- Generate entry
- Save as "Gemma Test"

## **Phase 4: Performance and Error Testing**

### Step 5: Test Error Handling
1. **Network Test:**
   - Turn off WiFi/cellular
   - Try to generate entry
   - Should show informative error message

2. **Invalid API Key Test:**
   - Go to Settings → Delete API Key
   - Try to generate entry
   - Should prompt to add API key

3. **Rate Limit Test:**
   - Generate many entries quickly
   - Should handle any rate limiting gracefully

## **Phase 5: Comparison and Analysis**

### Step 6: Review All Entries
1. **Go to Entries tab**
2. **Review all test entries**
3. **Compare and analyze:**

### Expected Results:

**🎯 Reality Level Adaptation:**
- **Low Reality (10-30%)**: Creative, imaginative, surreal content
- **Medium Reality (40-60%)**: Balanced realistic/creative mix
- **High Reality (70-90%)**: Grounded, realistic, everyday experiences

**🤖 Model Differences:**
- **Mixtral**: Creative, flowing writing style
- **Llama 3 70B**: Most sophisticated and nuanced
- **Llama 3 8B**: Faster, still high quality
- **Gemma**: Good balance of speed and quality

**⚡ Performance Indicators:**
- **Speed**: 2-3 seconds per generation
- **Quality**: Natural, human-like journal entries
- **Variety**: No repetitive patterns
- **Context**: Adapts to reality level appropriately

## **Troubleshooting Guide**

### If Generation Fails:
- Check internet connection
- Verify API key is correctly entered
- Test connection in Settings
- Check Groq API status at status.groq.com

### If Quality is Poor:
- Try different models (Mixtral vs Llama)
- Adjust reality levels
- Check if prompts are too short or vague

### If Entries Look Similar:
- Use more varied prompts
- Test across different reality levels
- Try different models for comparison

## **Success Metrics**

✅ **High Quality Content**: Natural, contextual journal entries
✅ **Reality Level Intelligence**: Appropriate adaptation to creativity vs realism
✅ **Model Variety**: Different styles and capabilities across models
✅ **Performance**: Consistent 2-3 second generation times
✅ **Error Handling**: Informative messages for network/API issues
✅ **Security**: API keys stored securely in Keychain

## **Documentation**

After testing, you'll have:
- 15+ test entries across all reality levels
- Model comparison data
- Performance benchmarks
- Error handling validation
- Evidence of context-aware generation

This gives you a comprehensive validation of the Groq AI integration!