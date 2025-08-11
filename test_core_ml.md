# Core ML Integration Testing Guide

## Test 1: Basic Functionality ✅

### Settings UI Test
1. **Open Gaslight app** (should be running in simulator)
2. **Navigate to Settings tab** (bottom right)
3. **Scroll to "AI Engine" section**
4. **Verify you see:**
   - Segmented control: "Templates Only | Core ML Only | Hybrid Mode"
   - Default selection should be "Templates Only"

### Expected Results:
- Settings UI displays correctly
- Segmented control is responsive
- No crashes when switching modes

## Test 2: Core ML Model Loading ⏳

### Model Loading Test
1. **In Settings, select "Core ML Only" mode**
2. **Look for "Core ML Model Status" section**
3. **Should show:** "Model not loaded"
4. **Tap "Load GPT-2 Model" button**
5. **Watch for:**
   - Progress bar appearing
   - Text changing to "Loading model... (X%)"
   - Eventually: "GPT-2 model ready" (after ~10-30 seconds)

### Expected Results:
- Progress bar shows loading progression
- No crashes during model loading
- Status updates correctly

## Test 3: AI Text Generation Quality 📝

### Templates vs Core ML Comparison
1. **Write a simple journal entry:** "Today I went for a walk and"
2. **Set Reality Level to 50%**
3. **Test with Templates Only mode:**
   - Tap "Write for Me"
   - Note the generated text style
4. **Switch to Core ML Only mode (ensure model is loaded):**
   - Tap "Write for Me" again
   - Note the different, more sophisticated text
   - Should take ~2 seconds to generate (simulated processing time)

### Expected Results:
- Core ML mode produces more thoughtful, journal-like continuations
- Processing delay indicates "AI thinking"
- Text quality feels more natural than templates

## Test 4: Hybrid Mode Intelligence 🎯

### Reality Level Testing
1. **Switch to Hybrid Mode**
2. **Test Low Reality (0-30%):**
   - Set slider to 10%
   - Write: "Something strange happened today"
   - Tap "Write for Me"
   - Should use Core ML (more surreal content)
3. **Test High Reality (70-100%):**
   - Set slider to 90%
   - Write: "Had a normal day at work"
   - Tap "Write for Me"
   - Should use Templates (faster, more structured)

### Expected Results:
- Hybrid mode intelligently chooses between Core ML and Templates
- Low reality = Core ML (thoughtful, introspective)
- High reality = Templates (quick, structured)

## Test 5: Error Handling 🛡️

### Fallback Testing
1. **Force an error condition:**
   - Switch to Core ML mode without loading model
   - Try to generate text
2. **Expected behavior:**
   - Should gracefully fall back to templates
   - Console should show: "Core ML generation failed, falling back to templates"
   - User sees generated text (not an error)

## Test 6: User Experience Flow 👤

### Complete User Journey
1. **Fresh app state** (restart if needed)
2. **Write a journal entry** in default Templates mode
3. **Go to Settings** → Switch to Core ML mode
4. **Load the model** (watch progress)
5. **Return to writing** → Test "Edit for Me" and "Write for Me"
6. **Compare experiences** between modes

### Expected Results:
- Smooth transitions between modes
- Clear feedback on model status
- No confusion about what mode is active

## Console Debugging 🔍

### What to look for in Xcode Console:
- `✅ Core ML GPT-2 model loaded successfully`
- `Core ML generation failed, falling back to templates: [error]`
- Loading progress messages
- No crash logs or memory warnings

## Performance Monitoring 📊

### Things to watch:
- **App startup time:** Should be unchanged (model loads on-demand)
- **Memory usage:** Will increase by ~650MB when model loads
- **Generation speed:** Templates = instant, Core ML = 2-3 seconds
- **Battery impact:** Core ML mode will use more power

---

## Quick Test Checklist ✓

- [ ] Settings UI displays AI Engine section
- [ ] Can switch between all three modes
- [ ] "Load GPT-2 Model" button works
- [ ] Progress bar shows during loading
- [ ] Model status updates correctly
- [ ] Core ML mode generates different text than Templates
- [ ] Hybrid mode changes behavior based on reality level
- [ ] Fallback to templates works when Core ML fails
- [ ] No crashes or freezes during any operation
- [ ] App feels responsive throughout testing

Run through this checklist and let me know what you discover!