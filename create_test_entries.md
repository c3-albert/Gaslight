# 🧪 AI Mode Testing Plan - Practical Version

Since we need to test the actual app functionality, here's a step-by-step plan to create test entries in all three modes:

## **Phase 1: Setup and Template Mode Testing**

### Step 1: Generate Template Entries
1. **Open Gaslight app**
2. **Go to Settings** → Ensure "Templates Only" is selected
3. **Return to Write tab**
4. **Create 5 test entries** with these prompts:

**Test Entry 1:**
- Prompt: "Today I woke up feeling"
- Reality Level: 50%
- Tap "Write for Me"
- Save as "Template Test 1"

**Test Entry 2:**
- Prompt: "Something unexpected happened when I" 
- Reality Level: 30%
- Tap "Edit for Me"
- Save as "Template Test 2"

**Test Entry 3:**
- Prompt: "I've been thinking about"
- Reality Level: 70%
- Tap "Write for Me"
- Save as "Template Test 3"

**Test Entry 4:**
- Prompt: "The strangest thing occurred while I was"
- Reality Level: 20%
- Tap "Write for Me" 
- Save as "Template Test 4"

**Test Entry 5:**
- Prompt: "Walking home tonight, I noticed"
- Reality Level: 80%
- Tap "Edit for Me"
- Save as "Template Test 5"

## **Phase 2: Core ML Mode Testing**

### Step 2: Load Core ML Model
1. **Go to Settings**
2. **Switch to "Core ML Only"**
3. **Tap "Load GPT-2 Model"**
4. **Wait for loading** (progress bar should show)
5. **Confirm status shows "GPT-2 model ready"**

### Step 3: Generate Core ML Entries
**Use the exact same prompts as Phase 1:**

**Test Entry 6:**
- Prompt: "Today I woke up feeling"
- Reality Level: 50%
- Tap "Write for Me"
- **Note the 2-second delay**
- Save as "Core ML Test 1"

**Test Entry 7:**
- Prompt: "Something unexpected happened when I"
- Reality Level: 30%
- Tap "Edit for Me"
- Save as "Core ML Test 2"

**Test Entry 8:**
- Prompt: "I've been thinking about"
- Reality Level: 70%
- Tap "Write for Me"
- Save as "Core ML Test 3"

**Test Entry 9:**
- Prompt: "The strangest thing occurred while I was"
- Reality Level: 20%
- Tap "Write for Me"
- Save as "Core ML Test 4"

**Test Entry 10:**
- Prompt: "Walking home tonight, I noticed"
- Reality Level: 80%
- Tap "Edit for Me"
- Save as "Core ML Test 5"

## **Phase 3: Hybrid Mode Testing**

### Step 4: Test Hybrid Intelligence
1. **Go to Settings**
2. **Switch to "Hybrid Mode"**
3. **Test with different reality levels:**

**Low Reality Test (Should use Core ML):**
- Prompt: "I discovered something impossible today"
- Reality Level: 10%
- Tap "Write for Me"
- Save as "Hybrid Low Reality"

**High Reality Test (Should use Templates):**
- Prompt: "I had a normal day at work"
- Reality Level: 90%
- Tap "Write for Me"
- Save as "Hybrid High Reality"

**Medium Reality Test (Could go either way):**
- Prompt: "Something made me wonder about life"
- Reality Level: 50%
- Tap "Write for Me"
- Save as "Hybrid Medium Reality"

## **Phase 4: Comparison and Analysis**

### Step 5: Review All Entries
1. **Go to Entries tab**
2. **Scroll through all test entries**
3. **Compare side-by-side:**

### Expected Differences:

**🔧 Template Entries Should Show:**
- Whimsical, absurdist content
- Objects doing unexpected things
- Short, punchy responses
- Instant generation

**🤖 Core ML Entries Should Show:**
- Deep, philosophical content
- Introspective language
- Longer, more thoughtful responses
- 2-3 second generation delay

**🎯 Hybrid Entries Should Show:**
- Low reality → Core ML style responses
- High reality → Template style responses
- Smart adaptation based on context

## **Troubleshooting Guide**

### If Core ML Mode Doesn't Work:
- Check Xcode console for error messages
- Ensure model loading completed successfully
- Try restarting the app
- Check "Core ML Model Status" in settings

### If Hybrid Mode Seems Random:
- Remember: < 50% reality = Core ML
- Remember: ≥ 50% reality = Templates
- Test with extreme values (10% vs 90%) first

### If Text Looks the Same:
- Double-check which mode is selected in Settings
- Make sure you're testing with identical prompts
- Look for subtle differences in style and length

## **Success Metrics**

✅ **Template Mode**: Quick, creative, object-based humor
✅ **Core ML Mode**: Thoughtful, philosophical, introspective
✅ **Hybrid Mode**: Intelligently switches based on reality level
✅ **Performance**: Core ML shows loading delay, Templates are instant
✅ **Quality**: Core ML produces noticeably more sophisticated text

## **Documentation**

After testing, you'll have:
- 15+ test entries showing all three modes
- Direct comparison of identical prompts
- Evidence of hybrid intelligence working
- Performance and quality differences documented

This gives you a comprehensive dataset to evaluate the Core ML integration!