class SignCategory {
  final String name;
  final String icon;
  final List<SignEntry> signs;

  const SignCategory({required this.name, required this.icon, required this.signs});
}

class SignEntry {
  final String word;
  final String description;
  final String emoji;
  final List<String> steps;
  final String category;
  final String difficulty;

  const SignEntry({
    required this.word,
    required this.description,
    required this.emoji,
    required this.steps,
    required this.category,
    this.difficulty = 'Beginner',
  });
}

class SignDictionary {
  static const List<SignCategory> categories = [
    // ── ALPHABET ──
    SignCategory(name: 'Alphabet', icon: '🔤', signs: [
      SignEntry(word: 'A', description: 'Make a fist with thumb on the side', emoji: '🤟', steps: ['Make a fist', 'Place thumb alongside index finger', 'Hold still'], category: 'Alphabet'),
      SignEntry(word: 'B', description: 'Flat hand, fingers together, thumb across palm', emoji: '✋', steps: ['Hold hand flat', 'Fingers together pointing up', 'Fold thumb across palm'], category: 'Alphabet'),
      SignEntry(word: 'C', description: 'Curve hand into C shape', emoji: '👌', steps: ['Curve fingers', 'Shape like the letter C', 'Thumb below fingers'], category: 'Alphabet'),
      SignEntry(word: 'D', description: 'Index finger up, other fingers touch thumb', emoji: '☝️', steps: ['Point index finger up', 'Touch middle, ring, pinky to thumb', 'Form a circle with remaining fingers'], category: 'Alphabet'),
      SignEntry(word: 'E', description: 'Curl all fingertips down to touch thumb', emoji: '✊', steps: ['Curl all fingers down', 'Fingertips touch the thumb', 'Thumb tucked under fingers'], category: 'Alphabet'),
      SignEntry(word: 'F', description: 'Touch index finger to thumb, other fingers up', emoji: '👌', steps: ['Touch index to thumb making circle', 'Extend middle, ring, pinky fingers', 'Hold upright'], category: 'Alphabet'),
      SignEntry(word: 'G', description: 'Point index finger and thumb sideways', emoji: '👉', steps: ['Extend index finger', 'Extend thumb parallel', 'Point sideways'], category: 'Alphabet'),
      SignEntry(word: 'H', description: 'Extend index and middle finger sideways', emoji: '✌️', steps: ['Extend index and middle finger', 'Hold them together horizontally', 'Point sideways'], category: 'Alphabet'),
      SignEntry(word: 'I', description: 'Extend pinky finger up', emoji: '🤙', steps: ['Make a fist', 'Extend pinky finger up', 'Hold still'], category: 'Alphabet'),
      SignEntry(word: 'J', description: 'Extend pinky, draw J shape in air', emoji: '🤙', steps: ['Extend pinky finger', 'Trace the letter J in the air', 'Move downward and curve'], category: 'Alphabet'),
      SignEntry(word: 'K', description: 'Index and middle finger up, thumb between', emoji: '✌️', steps: ['Raise index and middle finger', 'Place thumb between them', 'Hold upright'], category: 'Alphabet'),
      SignEntry(word: 'L', description: 'Extend thumb and index to form L', emoji: '👍', steps: ['Extend index finger up', 'Extend thumb to the side', 'Form an L shape'], category: 'Alphabet'),
      SignEntry(word: 'M', description: 'Place thumb under three fingers', emoji: '✊', steps: ['Tuck thumb under index, middle, ring fingers', 'Fingers drape over thumb', 'Hold facing forward'], category: 'Alphabet'),
      SignEntry(word: 'N', description: 'Place thumb under two fingers', emoji: '✊', steps: ['Tuck thumb under index and middle fingers', 'Fingers drape over thumb', 'Hold facing forward'], category: 'Alphabet'),
      SignEntry(word: 'O', description: 'Curve all fingers to touch thumb, forming O', emoji: '👌', steps: ['Curve all fingers', 'Touch fingertips to thumb', 'Form circular O shape'], category: 'Alphabet'),
      SignEntry(word: 'P', description: 'Like K but pointing downward', emoji: '👇', steps: ['Form K handshape', 'Point fingers downward', 'Wrist drops forward'], category: 'Alphabet'),
      SignEntry(word: 'Q', description: 'Like G but pointing downward', emoji: '👇', steps: ['Form G handshape', 'Point fingers downward', 'Index and thumb point down'], category: 'Alphabet'),
      SignEntry(word: 'R', description: 'Cross index and middle finger', emoji: '🤞', steps: ['Extend index and middle finger', 'Cross them', 'Hold upright'], category: 'Alphabet'),
      SignEntry(word: 'S', description: 'Make a fist with thumb over fingers', emoji: '✊', steps: ['Make a fist', 'Place thumb over curled fingers', 'Hold facing forward'], category: 'Alphabet'),
      SignEntry(word: 'T', description: 'Place thumb between index and middle finger', emoji: '✊', steps: ['Make a fist', 'Tuck thumb between index and middle', 'Hold facing forward'], category: 'Alphabet'),
      SignEntry(word: 'U', description: 'Extend index and middle fingers together pointing up', emoji: '✌️', steps: ['Extend index and middle finger', 'Hold them together', 'Point upward'], category: 'Alphabet'),
      SignEntry(word: 'V', description: 'Extend index and middle fingers apart', emoji: '✌️', steps: ['Extend index and middle finger', 'Spread them apart', 'Form a V shape'], category: 'Alphabet'),
      SignEntry(word: 'W', description: 'Extend index, middle, and ring fingers apart', emoji: '🖖', steps: ['Extend three fingers', 'Spread them apart', 'Thumb holds pinky'], category: 'Alphabet'),
      SignEntry(word: 'X', description: 'Hook index finger', emoji: '☝️', steps: ['Extend index finger', 'Bend it into a hook', 'Other fingers in fist'], category: 'Alphabet'),
      SignEntry(word: 'Y', description: 'Extend thumb and pinky', emoji: '🤙', steps: ['Extend thumb', 'Extend pinky', 'Curl other fingers'], category: 'Alphabet'),
      SignEntry(word: 'Z', description: 'Trace Z in air with index finger', emoji: '☝️', steps: ['Extend index finger', 'Trace the letter Z in the air', 'Move right, diagonal, right'], category: 'Alphabet'),
    ]),

    // ── GREETINGS & BASICS ──
    SignCategory(name: 'Greetings & Basics', icon: '👋', signs: [
      SignEntry(word: 'Hello', description: 'Wave your open hand side to side', emoji: '👋', steps: ['Open your hand', 'Raise it to forehead level', 'Wave side to side'], category: 'Greetings'),
      SignEntry(word: 'Goodbye', description: 'Open hand, fold fingers down repeatedly', emoji: '👋', steps: ['Open your hand palm out', 'Bend fingers down', 'Repeat like waving bye'], category: 'Greetings'),
      SignEntry(word: 'Good Morning', description: 'Sign "good" then "morning"', emoji: '🌅', steps: ['Touch chin with flat hand and move forward (good)', 'Place non-dominant hand in front like horizon', 'Raise dominant hand like rising sun'], category: 'Greetings'),
      SignEntry(word: 'Good Night', description: 'Sign "good" then "night"', emoji: '🌙', steps: ['Touch chin with flat hand and move forward (good)', 'Place non-dominant hand in front', 'Lower dominant hand below like setting sun'], category: 'Greetings'),
      SignEntry(word: 'Thank You', description: 'Touch your chin with fingertips, then move hand forward', emoji: '🙏', steps: ['Touch your chin with fingertips', 'Move hand forward', 'Lower it gently as a sign of gratitude'], category: 'Greetings'),
      SignEntry(word: 'Please', description: 'Rub your chest in a circular motion', emoji: '🤲', steps: ['Place flat hand on chest', 'Rub in a circular motion', 'Keep gentle expression'], category: 'Greetings'),
      SignEntry(word: 'Sorry', description: 'Make fist and rub it in circles on chest', emoji: '😔', steps: ['Make an A handshape (fist)', 'Place on chest', 'Rub in circular motion'], category: 'Greetings'),
      SignEntry(word: 'Excuse Me', description: 'Brush fingertips along opposite palm', emoji: '🙋', steps: ['Place fingertips on opposite palm', 'Brush forward gently', 'Repeat once'], category: 'Greetings'),
      SignEntry(word: 'Nice to Meet You', description: 'Point at the person then bring index fingers together', emoji: '🤝', steps: ['Point at the other person', 'Bring both index fingers together', 'Like two people meeting'], category: 'Greetings'),
      SignEntry(word: 'Yes', description: 'Make a fist and nod it up and down', emoji: '✅', steps: ['Make a fist (S hand)', 'Move it up and down', 'Like a nodding head'], category: 'Greetings'),
      SignEntry(word: 'No', description: 'Snap index and middle finger against thumb', emoji: '❌', steps: ['Extend index and middle finger', 'Snap them against thumb', 'Quick closing motion'], category: 'Greetings'),
      SignEntry(word: 'How Are You', description: 'Point thumbs up with both hands, move outward', emoji: '🤔', steps: ['Both hands in thumbs-up', 'Touch chest', 'Move outward while pointing at person'], category: 'Greetings'),
      SignEntry(word: 'My Name Is', description: 'Tap H fingers on each other then point', emoji: '📛', steps: ['Extend index and middle on both hands', 'Tap them together twice (name)', 'Then fingerspell your name'], category: 'Greetings'),
    ]),

    // ── NUMBERS ──
    SignCategory(name: 'Numbers', icon: '🔢', signs: [
      SignEntry(word: '0 (Zero)', description: 'Form an O shape with hand', emoji: '0️⃣', steps: ['Curve fingers to touch thumb', 'Form an O shape', 'Hold facing forward'], category: 'Numbers'),
      SignEntry(word: '1 (One)', description: 'Hold up index finger', emoji: '1️⃣', steps: ['Make a fist', 'Raise index finger', 'Hold up'], category: 'Numbers'),
      SignEntry(word: '2 (Two)', description: 'Hold up index and middle finger', emoji: '2️⃣', steps: ['Make a fist', 'Raise index and middle finger', 'Spread them apart'], category: 'Numbers'),
      SignEntry(word: '3 (Three)', description: 'Hold up thumb, index, and middle finger', emoji: '3️⃣', steps: ['Extend thumb', 'Extend index and middle finger', 'Hold spread apart'], category: 'Numbers'),
      SignEntry(word: '4 (Four)', description: 'Hold up four fingers, thumb folded', emoji: '4️⃣', steps: ['Extend all four fingers', 'Fold thumb across palm', 'Hold spread apart'], category: 'Numbers'),
      SignEntry(word: '5 (Five)', description: 'Open hand with all five fingers spread', emoji: '5️⃣', steps: ['Open hand fully', 'Spread all five fingers', 'Hold palm forward'], category: 'Numbers'),
      SignEntry(word: '6 (Six)', description: 'Touch thumb to pinky, other fingers up', emoji: '6️⃣', steps: ['Extend index, middle, ring fingers up', 'Touch thumb to pinky', 'Hold upright'], category: 'Numbers'),
      SignEntry(word: '7 (Seven)', description: 'Touch thumb to ring finger, others up', emoji: '7️⃣', steps: ['Extend index, middle, pinky up', 'Touch thumb to ring finger', 'Hold upright'], category: 'Numbers'),
      SignEntry(word: '8 (Eight)', description: 'Touch thumb to middle finger, others up', emoji: '8️⃣', steps: ['Extend index, ring, pinky up', 'Touch thumb to middle finger', 'Hold upright'], category: 'Numbers'),
      SignEntry(word: '9 (Nine)', description: 'Touch thumb to index finger, others up', emoji: '9️⃣', steps: ['Extend middle, ring, pinky up', 'Touch thumb to index finger', 'Hold upright'], category: 'Numbers'),
      SignEntry(word: '10 (Ten)', description: 'Shake A-hand (thumb up) back and forth', emoji: '🔟', steps: ['Make thumbs-up shape', 'Shake hand back and forth', 'Twist at the wrist'], category: 'Numbers'),
    ]),

    // ── FAMILY ──
    SignCategory(name: 'Family', icon: '👨‍👩‍👧‍👦', signs: [
      SignEntry(word: 'Mother', description: 'Open hand, thumb taps chin', emoji: '👩', steps: ['Spread open hand', 'Place thumb on chin', 'Tap twice'], category: 'Family'),
      SignEntry(word: 'Father', description: 'Open hand, thumb taps forehead', emoji: '👨', steps: ['Spread open hand', 'Place thumb on forehead', 'Tap twice'], category: 'Family'),
      SignEntry(word: 'Sister', description: 'Trace jaw then sign "same"', emoji: '👧', steps: ['Make L-hand at chin (girl)', 'Move down', 'Then bring both index fingers together'], category: 'Family'),
      SignEntry(word: 'Brother', description: 'Tap forehead then sign "same"', emoji: '👦', steps: ['Make L-hand at forehead (boy)', 'Move down', 'Then bring both index fingers together'], category: 'Family'),
      SignEntry(word: 'Baby', description: 'Cradle arms and rock side to side', emoji: '👶', steps: ['Place one arm on top of the other', 'As if holding a baby', 'Rock side to side'], category: 'Family'),
      SignEntry(word: 'Family', description: 'Both F-hands circle to form a circle', emoji: '👨‍👩‍👧‍👦', steps: ['Form F with both hands', 'Touch thumbs and index fingers', 'Circle outward until pinkies touch'], category: 'Family'),
      SignEntry(word: 'Friend', description: 'Hook index fingers together twice', emoji: '🤝', steps: ['Hook right index over left', 'Reverse and hook left over right', 'Like linking together'], category: 'Family'),
      SignEntry(word: 'Husband', description: 'Sign "man" then clasp hands', emoji: '💑', steps: ['Touch forehead with open hand (male)', 'Move down', 'Clasp both hands together (married)'], category: 'Family'),
      SignEntry(word: 'Wife', description: 'Sign "woman" then clasp hands', emoji: '💑', steps: ['Touch chin with open hand (female)', 'Move down', 'Clasp both hands together (married)'], category: 'Family'),
      SignEntry(word: 'Grandma', description: 'Sign mother but with two bounces away from chin', emoji: '👵', steps: ['Open hand at chin (mother)', 'Bounce forward twice', 'Moving away from face'], category: 'Family'),
      SignEntry(word: 'Grandpa', description: 'Sign father but with two bounces away from forehead', emoji: '👴', steps: ['Open hand at forehead (father)', 'Bounce forward twice', 'Moving away from face'], category: 'Family'),
    ]),

    // ── EMOTIONS & FEELINGS ──
    SignCategory(name: 'Emotions', icon: '😊', signs: [
      SignEntry(word: 'Happy', description: 'Brush chest upward with flat hand repeatedly', emoji: '😊', steps: ['Place flat hand on chest', 'Brush upward', 'Repeat with upward energy'], category: 'Emotions'),
      SignEntry(word: 'Sad', description: 'Pull both hands down the face', emoji: '😢', steps: ['Hold both open hands near face', 'Pull downward', 'Make sad expression'], category: 'Emotions'),
      SignEntry(word: 'Angry', description: 'Claw hand in front of face, pull outward', emoji: '😠', steps: ['Hold claw hand near face', 'Pull outward firmly', 'Show angry expression'], category: 'Emotions'),
      SignEntry(word: 'Scared', description: 'Both fists open suddenly in front of chest', emoji: '😨', steps: ['Hold both fists near chest', 'Open them suddenly', 'As if startled'], category: 'Emotions'),
      SignEntry(word: 'Tired', description: 'Both hands on chest, let them drop/rotate down', emoji: '😴', steps: ['Place both bent hands on chest', 'Let them rotate downward', 'Like energy draining'], category: 'Emotions'),
      SignEntry(word: 'Love', description: 'Cross arms over chest like a hug', emoji: '❤️', steps: ['Cross both arms over chest', 'Fists closed', 'Like hugging yourself'], category: 'Emotions'),
      SignEntry(word: 'Confused', description: 'Both claw hands near head, twist alternately', emoji: '😕', steps: ['Hold claw hands near temples', 'Twist them alternately', 'Like thoughts spinning'], category: 'Emotions'),
      SignEntry(word: 'Surprised', description: 'Flick index fingers and thumbs near eyes', emoji: '😲', steps: ['Place pinched fingers near eyes', 'Flick open suddenly', 'Widen eyes'], category: 'Emotions'),
      SignEntry(word: 'Excited', description: 'Both hands brush up chest alternately', emoji: '🤩', steps: ['Place open hands on chest', 'Brush upward alternately', 'Quick energetic motions'], category: 'Emotions'),
      SignEntry(word: 'Bored', description: 'Place index finger on side of nose, twist', emoji: '😑', steps: ['Touch side of nose with index finger', 'Twist slightly', 'Neutral expression'], category: 'Emotions'),
    ]),

    // ── FOOD & DRINK ──
    SignCategory(name: 'Food & Drink', icon: '🍽️', signs: [
      SignEntry(word: 'Food/Eat', description: 'Bunch fingertips together and tap them to mouth', emoji: '🍽️', steps: ['Bunch all fingertips together', 'Bring to your mouth', 'Tap twice'], category: 'Food & Drink'),
      SignEntry(word: 'Water', description: 'W-hand taps chin', emoji: '💧', steps: ['Form W with three fingers', 'Tap index finger on chin', 'Tap twice'], category: 'Food & Drink'),
      SignEntry(word: 'Milk', description: 'Squeeze fist like milking a cow', emoji: '🥛', steps: ['Hold hand in C shape', 'Squeeze into fist', 'Repeat like milking'], category: 'Food & Drink'),
      SignEntry(word: 'Coffee', description: 'Place one S-hand on the other, grind in circles', emoji: '☕', steps: ['Place one fist on top of the other', 'Rotate top fist in circles', 'Like grinding coffee'], category: 'Food & Drink'),
      SignEntry(word: 'Bread', description: 'Slice back of non-dominant hand with other hand', emoji: '🍞', steps: ['Hold non-dominant hand flat', 'Slice along the back with dominant fingers', 'Like cutting bread slices'], category: 'Food & Drink'),
      SignEntry(word: 'Fruit', description: 'F-hand on cheek, twist', emoji: '🍎', steps: ['Form F at cheek', 'Twist wrist forward', 'Like picking fruit'], category: 'Food & Drink'),
      SignEntry(word: 'Hungry', description: 'Claw hand moves down from throat to stomach', emoji: '😋', steps: ['Place C-hand at throat', 'Move downward to stomach', 'Like hunger moving through you'], category: 'Food & Drink'),
      SignEntry(word: 'Thirsty', description: 'Drag index finger down throat', emoji: '🥤', steps: ['Extend index finger', 'Place at top of throat', 'Drag downward'], category: 'Food & Drink'),
      SignEntry(word: 'Drink', description: 'Cup hand near mouth and tilt', emoji: '🥤', steps: ['Form C-hand like holding cup', 'Bring to mouth', 'Tilt as if drinking'], category: 'Food & Drink'),
      SignEntry(word: 'Cook', description: 'Flip hand on opposite palm like flipping pancake', emoji: '👨‍🍳', steps: ['Place flat hand on opposite palm', 'Flip over', 'Like flipping food in pan'], category: 'Food & Drink'),
    ]),

    // ── MEDICAL & HEALTH ──
    SignCategory(name: 'Medical & Health', icon: '🏥', signs: [
      SignEntry(word: 'Doctor', description: 'Tap wrist with fingertips like taking pulse', emoji: '👨‍⚕️', steps: ['Hold non-dominant wrist up', 'Tap with dominant fingertips', 'Like checking a pulse'], category: 'Medical'),
      SignEntry(word: 'Medicine', description: 'Rock middle finger in palm of other hand', emoji: '💊', steps: ['Extend middle finger', 'Place in opposite palm', 'Rock back and forth'], category: 'Medical'),
      SignEntry(word: 'Pain/Hurt', description: 'Point both index fingers at each other, twist', emoji: '🤕', steps: ['Extend both index fingers', 'Point at each other', 'Twist in opposite directions'], category: 'Medical'),
      SignEntry(word: 'Hospital', description: 'Draw cross on upper arm with H-hand', emoji: '🏥', steps: ['Form H-hand (index + middle)', 'Draw a cross on upper arm', 'Like a medical cross symbol'], category: 'Medical'),
      SignEntry(word: 'Sick', description: 'Middle finger taps forehead, other taps stomach', emoji: '🤒', steps: ['Touch forehead with dominant middle finger', 'Touch stomach with non-dominant middle finger', 'Both at the same time'], category: 'Medical'),
      SignEntry(word: 'Allergy', description: 'Touch nose with index, then pull away', emoji: '🤧', steps: ['Touch nose with index finger', 'Pull finger away', 'Like a reaction'], category: 'Medical'),
      SignEntry(word: 'Blood', description: 'Flick fingers down from back of opposite hand', emoji: '🩸', steps: ['Touch back of non-dominant hand', 'Wiggle fingers as you move down', 'Like blood flowing'], category: 'Medical'),
      SignEntry(word: 'Fever', description: 'Place back of hand on forehead', emoji: '🤒', steps: ['Place back of dominant hand', 'On forehead', 'Hold as if checking temperature'], category: 'Medical'),
      SignEntry(word: 'Help', description: 'Place fist on open palm and raise together', emoji: '🆘', steps: ['Make a fist with dominant hand', 'Place on open non-dominant palm', 'Raise both upward together'], category: 'Medical'),
      SignEntry(word: 'Ambulance', description: 'Rotate fist in circles (like siren light)', emoji: '🚑', steps: ['Make a fist above head', 'Rotate in circles', 'Like an ambulance siren light'], category: 'Medical'),
    ]),

    // ── EMERGENCY ──
    SignCategory(name: 'Emergency', icon: '🚨', signs: [
      SignEntry(word: 'Emergency', description: 'Wave hand rapidly above head', emoji: '🚨', steps: ['Raise hand above head', 'Wave back and forth rapidly', 'Show urgency'], category: 'Emergency'),
      SignEntry(word: 'Fire', description: 'Wiggle fingers while moving hands upward', emoji: '🔥', steps: ['Hold both hands low', 'Wiggle all fingers', 'Move hands upward like flames'], category: 'Emergency'),
      SignEntry(word: 'Police', description: 'C-hand taps upper chest like badge', emoji: '👮', steps: ['Form C-hand', 'Tap upper left chest', 'Where a badge would be'], category: 'Emergency'),
      SignEntry(word: 'Danger', description: 'Push A-hand (thumb up) upward against other palm repeatedly', emoji: '⚠️', steps: ['Make fist with thumb up', 'Push upward against opposite flat palm', 'Repeat urgently'], category: 'Emergency'),
      SignEntry(word: 'Stop', description: 'Chop dominant hand down onto non-dominant palm', emoji: '🛑', steps: ['Hold non-dominant palm flat', 'Bring dominant hand down firmly', 'Like chopping onto palm'], category: 'Emergency'),
      SignEntry(word: 'Call 911', description: 'Fingerspell 911 then phone sign', emoji: '📞', steps: ['Sign 9, then 1, then 1', 'Then hold Y-hand to ear', 'Like making a phone call'], category: 'Emergency'),
      SignEntry(word: 'Accident', description: 'Both fists collide in front of body', emoji: '💥', steps: ['Hold both fists up', 'Move them toward each other', 'Collide in the middle'], category: 'Emergency'),
      SignEntry(word: 'Escape', description: 'Shoot index finger out from between other fingers', emoji: '🏃', steps: ['Place dominant index between non-dominant fingers', 'Pull out quickly forward', 'Like escaping from grasp'], category: 'Emergency'),
    ]),

    // ── EVERYDAY ACTIONS ──
    SignCategory(name: 'Everyday Actions', icon: '🏃', signs: [
      SignEntry(word: 'Go', description: 'Both index fingers point and move forward', emoji: '👉', steps: ['Point both index fingers', 'Move them forward', 'In an arc together'], category: 'Actions'),
      SignEntry(word: 'Come', description: 'Beckon with index finger toward yourself', emoji: '🫳', steps: ['Extend index finger', 'Point away from you', 'Curl toward yourself'], category: 'Actions'),
      SignEntry(word: 'Walk', description: 'Two fingers walk on opposite palm', emoji: '🚶', steps: ['Extend index and middle on one hand', 'Walk them along opposite palm', 'Like little legs walking'], category: 'Actions'),
      SignEntry(word: 'Run', description: 'Hook index fingers and move them fast in L-hands', emoji: '🏃', steps: ['Extend L with both hands', 'Hook index of one around thumb of other', 'Move forward quickly, wiggling'], category: 'Actions'),
      SignEntry(word: 'Sleep', description: 'Place hand on cheek and tilt head', emoji: '😴', steps: ['Spread open hand', 'Place on cheek', 'Tilt head toward hand, close eyes'], category: 'Actions'),
      SignEntry(word: 'Work', description: 'Tap S-fist on top of other S-fist', emoji: '💼', steps: ['Make fists with both hands', 'Tap dominant on top of non-dominant', 'Tap twice like hammering'], category: 'Actions'),
      SignEntry(word: 'Learn', description: 'Pull fingertips from palm to forehead', emoji: '📚', steps: ['Place fingertips on opposite palm', 'Pull up to forehead', 'Like pulling knowledge into head'], category: 'Actions'),
      SignEntry(word: 'Understand', description: 'Flick index finger up near temple', emoji: '💡', steps: ['Place index finger near temple', 'Flick upward', 'Like a light bulb turning on'], category: 'Actions'),
      SignEntry(word: 'Think', description: 'Touch index finger to forehead', emoji: '🤔', steps: ['Extend index finger', 'Touch to forehead/temple', 'Hold briefly'], category: 'Actions'),
      SignEntry(word: 'Wait', description: 'Hold both open hands up, wiggle fingers', emoji: '⏳', steps: ['Hold both hands up palms facing up', 'Wiggle all fingers', 'Show patience'], category: 'Actions'),
      SignEntry(word: 'Read', description: 'V-hand scans across opposite palm', emoji: '📖', steps: ['Form V with dominant hand', 'Point at opposite flat palm', 'Move downward like reading lines'], category: 'Actions'),
      SignEntry(word: 'Write', description: 'Pinch fingers and write on opposite palm', emoji: '✍️', steps: ['Pinch dominant thumb and index', 'Move across opposite flat palm', 'Like writing with a pen'], category: 'Actions'),
    ]),

    // ── PLACES ──
    SignCategory(name: 'Places', icon: '🏠', signs: [
      SignEntry(word: 'Home', description: 'Touch bunched fingertips from mouth to cheek', emoji: '🏠', steps: ['Bunch fingertips together', 'Touch near mouth', 'Move to touch cheek'], category: 'Places'),
      SignEntry(word: 'School', description: 'Clap hands twice', emoji: '🏫', steps: ['Hold both hands flat', 'Clap twice', 'Like getting attention in class'], category: 'Places'),
      SignEntry(word: 'Store/Shop', description: 'Flat O hands move outward from body', emoji: '🏪', steps: ['Bunch fingertips together', 'Hold near body', 'Flick outward twice'], category: 'Places'),
      SignEntry(word: 'Church', description: 'C-hand taps back of S-hand', emoji: '⛪', steps: ['Form C with dominant hand', 'Tap on back of non-dominant fist', 'Like a building with a cross'], category: 'Places'),
      SignEntry(word: 'Bathroom', description: 'Shake T-hand side to side', emoji: '🚻', steps: ['Form T (thumb between index and middle)', 'Shake side to side', 'Quick motion'], category: 'Places'),
      SignEntry(word: 'Outside', description: 'Pull cupped hand away from body twice', emoji: '🌳', steps: ['Hold cupped hand near body', 'Pull away outward', 'Repeat closing fingers twice'], category: 'Places'),
    ]),

    // ── COMMON PHRASES ──
    SignCategory(name: 'Common Phrases', icon: '💬', signs: [
      SignEntry(word: 'I Love You', description: 'Extend thumb, index, and pinky finger', emoji: '🤟', steps: ['Extend thumb out', 'Extend index finger up', 'Extend pinky up', 'Keep middle and ring folded'], category: 'Phrases'),
      SignEntry(word: 'What\'s Your Name?', description: 'Sign "name" + point at person with questioning face', emoji: '❓', steps: ['Tap H-fingers together twice (name)', 'Point at the person', 'Show questioning expression'], category: 'Phrases'),
      SignEntry(word: 'Where Is The Bathroom?', description: 'Sign "bathroom" + "where"', emoji: '🚻', steps: ['Shake T-hand (bathroom)', 'Then hold both palms up', 'Shake side to side with questioning face (where)'], category: 'Phrases'),
      SignEntry(word: 'I Don\'t Understand', description: 'Touch temple with index and flick away', emoji: '🤷', steps: ['Touch temple with index finger', 'Flick finger away/down', 'Shake head no'], category: 'Phrases'),
      SignEntry(word: 'Can You Help Me?', description: 'Sign "help" + point at person', emoji: '🙏', steps: ['Fist on open palm, raise up (help)', 'Point at the person', 'Show questioning expression'], category: 'Phrases'),
      SignEntry(word: 'How Much?', description: 'Both cupped hands face up and bounce', emoji: '💰', steps: ['Hold both cupped hands palms up', 'Bounce upward', 'Questioning expression'], category: 'Phrases'),
      SignEntry(word: 'I\'m Deaf', description: 'Point to ear, then to mouth, then to self', emoji: '🧏', steps: ['Point index finger to ear', 'Move to touch near mouth', 'Point to self'], category: 'Phrases'),
      SignEntry(word: 'Do You Sign?', description: 'Both index fingers circle alternately toward person', emoji: '🤟', steps: ['Extend both index fingers', 'Circle them alternately', 'Direct toward the person'], category: 'Phrases'),
      SignEntry(word: 'Slow Down Please', description: 'Drag hand slowly across opposite arm + "please"', emoji: '🐢', steps: ['Place dominant hand on opposite forearm', 'Drag slowly toward wrist', 'Then rub chest in circle (please)'], category: 'Phrases'),
      SignEntry(word: 'Thank You Very Much', description: 'Sign "thank you" with emphasis', emoji: '🙏', steps: ['Touch chin with fingertips', 'Move hand far forward', 'Use both hands for emphasis'], category: 'Phrases'),
    ]),

    // ── TIME & DAYS ──
    SignCategory(name: 'Time & Days', icon: '📅', signs: [
      SignEntry(word: 'Today', description: 'Drop both Y-hands down in front', emoji: '📅', steps: ['Hold both Y-hands up', 'Drop them down in front of body', 'Land at waist level'], category: 'Time'),
      SignEntry(word: 'Tomorrow', description: 'A-hand thumb on cheek, arc forward', emoji: '➡️', steps: ['Touch thumb to cheek', 'Arc hand forward', 'Like moving to the next day'], category: 'Time'),
      SignEntry(word: 'Yesterday', description: 'A-hand thumb touches cheek, then back of jaw', emoji: '⬅️', steps: ['Touch thumb to chin', 'Move back to touch ear area', 'Like going back a day'], category: 'Time'),
      SignEntry(word: 'Week', description: 'Slide index across opposite palm', emoji: '📆', steps: ['Hold non-dominant hand flat', 'Slide dominant index finger across', 'From base to fingertips'], category: 'Time'),
      SignEntry(word: 'Month', description: 'Slide index down the back of opposite index', emoji: '📆', steps: ['Hold non-dominant index up', 'Slide dominant index down the back', 'From top to bottom'], category: 'Time'),
      SignEntry(word: 'Now', description: 'Drop both bent hands down slightly', emoji: '⏰', steps: ['Hold both bent hands at chest level', 'Drop slightly downward', 'Quick firm movement'], category: 'Time'),
      SignEntry(word: 'Later', description: 'L-hand pivots forward from thumb on palm', emoji: '🔜', steps: ['Form L with dominant hand', 'Place thumb on non-dominant palm', 'Pivot index finger forward'], category: 'Time'),
    ]),

    // ── COLORS ──
    SignCategory(name: 'Colors', icon: '🎨', signs: [
      SignEntry(word: 'Red', description: 'Stroke index finger down from lips', emoji: '🔴', steps: ['Touch lips with index finger', 'Stroke downward', 'Repeat once'], category: 'Colors'),
      SignEntry(word: 'Blue', description: 'Shake B-hand side to side', emoji: '🔵', steps: ['Form B-hand', 'Shake/twist side to side', 'In space to the right'], category: 'Colors'),
      SignEntry(word: 'Green', description: 'Shake G-hand side to side', emoji: '🟢', steps: ['Form G-hand', 'Shake/twist side to side', 'In space to the right'], category: 'Colors'),
      SignEntry(word: 'Yellow', description: 'Shake Y-hand side to side', emoji: '🟡', steps: ['Form Y-hand (thumb + pinky out)', 'Shake/twist side to side', 'In space to the right'], category: 'Colors'),
      SignEntry(word: 'Black', description: 'Drag index finger across forehead', emoji: '⚫', steps: ['Extend index finger', 'Place at one side of forehead', 'Drag across to other side'], category: 'Colors'),
      SignEntry(word: 'White', description: 'Pull open hand away from chest, closing fingers', emoji: '⚪', steps: ['Place open hand on chest', 'Pull away from body', 'Close fingers as you pull'], category: 'Colors'),
    ]),
  ];

  /// Get all signs as a flat list
  static List<SignEntry> get allSigns =>
      categories.expand((c) => c.signs).toList();

  /// Search across all signs
  static List<SignEntry> search(String query) {
    if (query.isEmpty) return allSigns;
    final q = query.toLowerCase();
    return allSigns.where((s) {
      return s.word.toLowerCase().contains(q) ||
          s.description.toLowerCase().contains(q) ||
          s.category.toLowerCase().contains(q);
    }).toList();
  }

  /// Get sign entry by word (for translation)
  static SignEntry? findByWord(String word) {
    final w = word.toLowerCase();
    try {
      return allSigns.firstWhere((s) => s.word.toLowerCase() == w);
    } catch (_) {
      return null;
    }
  }

  /// Translate a sentence to sign language steps
  static List<SignEntry> translateSentence(String sentence) {
    final words = sentence.toLowerCase().split(RegExp(r'\s+'));
    List<SignEntry> results = [];

    // Try multi-word matches first, then single words
    for (final sign in allSigns) {
      if (sentence.toLowerCase().contains(sign.word.toLowerCase()) &&
          sign.word.split(' ').length > 1) {
        results.add(sign);
      }
    }

    for (final word in words) {
      final cleaned = word.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
      if (cleaned.isEmpty) continue;
      final match = findByWord(cleaned);
      if (match != null && !results.contains(match)) {
        results.add(match);
      }
    }

    return results;
  }
}
