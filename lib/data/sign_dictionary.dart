class SignCategory {
  final String name;
  final String icon;
  final List<SignEntry> signs;

  const SignCategory({
    required this.name,
    required this.icon,
    required this.signs,
  });
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
    SignCategory(
      name: 'Alphabet',
      icon: '🔤',
      signs: [
        SignEntry(
          word: 'A',
          description: 'Make a fist with thumb on the side',
          emoji: '🤟',
          steps: [
            'Make a fist',
            'Place thumb alongside index finger',
            'Hold still',
          ],
          category: 'Alphabet',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'B',
          description: 'Flat hand, fingers together, thumb across palm',
          emoji: '✋',
          steps: [
            'Hold hand flat',
            'Fingers together pointing up',
            'Fold thumb across palm',
          ],
          category: 'Alphabet',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'C',
          description: 'Curve hand into C shape',
          emoji: '👌',
          steps: [
            'Curve fingers',
            'Shape like the letter C',
            'Thumb below fingers',
          ],
          category: 'Alphabet',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'D',
          description: 'Index finger up, other fingers touch thumb',
          emoji: '☝️',
          steps: [
            'Point index finger up',
            'Touch middle, ring, pinky to thumb',
            'Form a circle with remaining fingers',
          ],
          category: 'Alphabet',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'E',
          description: 'Curl all fingertips down to touch thumb',
          emoji: '✊',
          steps: [
            'Curl all fingers down',
            'Fingertips touch the thumb',
            'Thumb tucked under fingers',
          ],
          category: 'Alphabet',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'F',
          description: 'Touch index finger to thumb, other fingers up',
          emoji: '👌',
          steps: [
            'Touch index to thumb making circle',
            'Extend middle, ring, pinky fingers',
            'Hold upright',
          ],
          category: 'Alphabet',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'G',
          description: 'Point index finger and thumb sideways',
          emoji: '👉',
          steps: [
            'Extend index finger',
            'Extend thumb parallel',
            'Point sideways',
          ],
          category: 'Alphabet',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'H',
          description: 'Extend index and middle finger sideways',
          emoji: '✌️',
          steps: [
            'Extend index and middle finger',
            'Hold them together horizontally',
            'Point sideways',
          ],
          category: 'Alphabet',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'I',
          description: 'Extend pinky finger up',
          emoji: '🤙',
          steps: ['Make a fist', 'Extend pinky finger up', 'Hold still'],
          category: 'Alphabet',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'J',
          description: 'Extend pinky, draw J shape in air',
          emoji: '🤙',
          steps: [
            'Extend pinky finger',
            'Trace the letter J in the air',
            'Move downward and curve',
          ],
          category: 'Alphabet',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'K',
          description: 'Index and middle finger up, thumb between',
          emoji: '✌️',
          steps: [
            'Raise index and middle finger',
            'Place thumb between them',
            'Hold upright',
          ],
          category: 'Alphabet',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'L',
          description: 'Extend thumb and index to form L',
          emoji: '👍',
          steps: [
            'Extend index finger up',
            'Extend thumb to the side',
            'Form an L shape',
          ],
          category: 'Alphabet',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'M',
          description: 'Place thumb under three fingers',
          emoji: '✊',
          steps: [
            'Tuck thumb under index, middle, ring fingers',
            'Fingers drape over thumb',
            'Hold facing forward',
          ],
          category: 'Alphabet',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'N',
          description: 'Place thumb under two fingers',
          emoji: '✊',
          steps: [
            'Tuck thumb under index and middle fingers',
            'Fingers drape over thumb',
            'Hold facing forward',
          ],
          category: 'Alphabet',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'O',
          description: 'Curve all fingers to touch thumb, forming O',
          emoji: '👌',
          steps: [
            'Curve all fingers',
            'Touch fingertips to thumb',
            'Form circular O shape',
          ],
          category: 'Alphabet',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'P',
          description: 'Like K but pointing downward',
          emoji: '👇',
          steps: [
            'Form K handshape',
            'Point fingers downward',
            'Wrist drops forward',
          ],
          category: 'Alphabet',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'Q',
          description: 'Like G but pointing downward',
          emoji: '👇',
          steps: [
            'Form G handshape',
            'Point fingers downward',
            'Index and thumb point down',
          ],
          category: 'Alphabet',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'R',
          description: 'Cross index and middle finger',
          emoji: '🤞',
          steps: [
            'Extend index and middle finger',
            'Cross them',
            'Hold upright',
          ],
          category: 'Alphabet',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'S',
          description: 'Make a fist with thumb over fingers',
          emoji: '✊',
          steps: [
            'Make a fist',
            'Place thumb over curled fingers',
            'Hold facing forward',
          ],
          category: 'Alphabet',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'T',
          description: 'Place thumb between index and middle finger',
          emoji: '✊',
          steps: [
            'Make a fist',
            'Tuck thumb between index and middle',
            'Hold facing forward',
          ],
          category: 'Alphabet',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'U',
          description: 'Extend index and middle fingers together pointing up',
          emoji: '✌️',
          steps: [
            'Extend index and middle finger',
            'Hold them together',
            'Point upward',
          ],
          category: 'Alphabet',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'V',
          description: 'Extend index and middle fingers apart',
          emoji: '✌️',
          steps: [
            'Extend index and middle finger',
            'Spread them apart',
            'Form a V shape',
          ],
          category: 'Alphabet',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'W',
          description: 'Extend index, middle, and ring fingers apart',
          emoji: '🖖',
          steps: [
            'Extend three fingers',
            'Spread them apart',
            'Thumb holds pinky',
          ],
          category: 'Alphabet',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'X',
          description: 'Hook index finger',
          emoji: '☝️',
          steps: [
            'Extend index finger',
            'Bend it into a hook',
            'Other fingers in fist',
          ],
          category: 'Alphabet',
          difficulty: 'Advanced',
        ),
        SignEntry(
          word: 'Y',
          description: 'Extend thumb and pinky',
          emoji: '🤙',
          steps: ['Extend thumb', 'Extend pinky', 'Curl other fingers'],
          category: 'Alphabet',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'Z',
          description: 'Trace Z in air with index finger',
          emoji: '☝️',
          steps: [
            'Extend index finger',
            'Trace the letter Z in the air',
            'Move right, diagonal, right',
          ],
          category: 'Alphabet',
          difficulty: 'Advanced',
        ),
      ],
    ),

    // ── GREETINGS & BASICS ──
    SignCategory(
      name: 'Greetings & Basics',
      icon: '👋',
      signs: [
        SignEntry(
          word: 'Hello',
          description: 'Wave your open hand side to side',
          emoji: '👋',
          steps: [
            'Open your hand',
            'Raise it to forehead level',
            'Wave side to side',
          ],
          category: 'Greetings',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'Goodbye',
          description: 'Open hand, fold fingers down repeatedly',
          emoji: '👋',
          steps: [
            'Open your hand palm out',
            'Bend fingers down',
            'Repeat like waving bye',
          ],
          category: 'Greetings',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'Thank You',
          description:
              'Touch your chin with fingertips, then move hand forward',
          emoji: '🙏',
          steps: [
            'Touch your chin with fingertips',
            'Move hand forward',
            'Lower it gently as a sign of gratitude',
          ],
          category: 'Greetings',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'Please',
          description: 'Rub your chest in a circular motion',
          emoji: '🤲',
          steps: [
            'Place flat hand on chest',
            'Rub in a circular motion',
            'Keep gentle expression',
          ],
          category: 'Greetings',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'Sorry',
          description: 'Make fist and rub it in circles on chest',
          emoji: '😔',
          steps: [
            'Make an A handshape (fist)',
            'Place on chest',
            'Rub in circular motion',
          ],
          category: 'Greetings',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'Yes',
          description: 'Make a fist and nod it up and down',
          emoji: '✅',
          steps: [
            'Make a fist (S hand)',
            'Move it up and down',
            'Like a nodding head',
          ],
          category: 'Greetings',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'No',
          description: 'Snap index and middle finger against thumb',
          emoji: '❌',
          steps: [
            'Extend index and middle finger',
            'Snap them against thumb',
            'Quick closing motion',
          ],
          category: 'Greetings',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'Good Morning',
          description: 'Sign "good" then "morning"',
          emoji: '🌅',
          steps: [
            'Touch chin with flat hand and move forward (good)',
            'Place non-dominant hand in front like horizon',
            'Raise dominant hand like rising sun',
          ],
          category: 'Greetings',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'Good Night',
          description: 'Sign "good" then "night"',
          emoji: '🌙',
          steps: [
            'Touch chin with flat hand and move forward (good)',
            'Place non-dominant hand in front',
            'Lower dominant hand below like setting sun',
          ],
          category: 'Greetings',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'Excuse Me',
          description: 'Brush fingertips along opposite palm',
          emoji: '🙋',
          steps: [
            'Place fingertips on opposite palm',
            'Brush forward gently',
            'Repeat once',
          ],
          category: 'Greetings',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'How Are You',
          description: 'Point thumbs up with both hands, move outward',
          emoji: '🤔',
          steps: [
            'Both hands in thumbs-up',
            'Touch chest',
            'Move outward while pointing at person',
          ],
          category: 'Greetings',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'Nice to Meet You',
          description: 'Point at the person then bring index fingers together',
          emoji: '🤝',
          steps: [
            'Point at the other person',
            'Bring both index fingers together',
            'Like two people meeting',
          ],
          category: 'Greetings',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'My Name Is',
          description: 'Tap H fingers on each other then point',
          emoji: '📛',
          steps: [
            'Extend index and middle on both hands',
            'Tap them together twice (name)',
            'Then fingerspell your name',
          ],
          category: 'Greetings',
          difficulty: 'Advanced',
        ),
      ],
    ),

    // ── NUMBERS ──
    SignCategory(
      name: 'Numbers',
      icon: '🔢',
      signs: [
        SignEntry(
          word: '0 (Zero)',
          description: 'Form an O shape with hand',
          emoji: '0️⃣',
          steps: [
            'Curve fingers to touch thumb',
            'Form an O shape',
            'Hold facing forward',
          ],
          category: 'Numbers',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: '1 (One)',
          description: 'Hold up index finger',
          emoji: '1️⃣',
          steps: ['Make a fist', 'Raise index finger', 'Hold up'],
          category: 'Numbers',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: '2 (Two)',
          description: 'Hold up index and middle finger',
          emoji: '2️⃣',
          steps: [
            'Make a fist',
            'Raise index and middle finger',
            'Spread them apart',
          ],
          category: 'Numbers',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: '3 (Three)',
          description: 'Hold up thumb, index, and middle finger',
          emoji: '3️⃣',
          steps: [
            'Extend thumb',
            'Extend index and middle finger',
            'Hold spread apart',
          ],
          category: 'Numbers',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: '4 (Four)',
          description: 'Hold up four fingers, thumb folded',
          emoji: '4️⃣',
          steps: [
            'Extend all four fingers',
            'Fold thumb across palm',
            'Hold spread apart',
          ],
          category: 'Numbers',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: '5 (Five)',
          description: 'Open hand with all five fingers spread',
          emoji: '5️⃣',
          steps: [
            'Open hand fully',
            'Spread all five fingers',
            'Hold palm forward',
          ],
          category: 'Numbers',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: '6 (Six)',
          description: 'Touch thumb to pinky, other fingers up',
          emoji: '6️⃣',
          steps: [
            'Extend index, middle, ring fingers up',
            'Touch thumb to pinky',
            'Hold upright',
          ],
          category: 'Numbers',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: '7 (Seven)',
          description: 'Touch thumb to ring finger, others up',
          emoji: '7️⃣',
          steps: [
            'Extend index, middle, pinky up',
            'Touch thumb to ring finger',
            'Hold upright',
          ],
          category: 'Numbers',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: '8 (Eight)',
          description: 'Touch thumb to middle finger, others up',
          emoji: '8️⃣',
          steps: [
            'Extend index, ring, pinky up',
            'Touch thumb to middle finger',
            'Hold upright',
          ],
          category: 'Numbers',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: '9 (Nine)',
          description: 'Touch thumb to index finger, others up',
          emoji: '9️⃣',
          steps: [
            'Extend middle, ring, pinky up',
            'Touch thumb to index finger',
            'Hold upright',
          ],
          category: 'Numbers',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: '10 (Ten)',
          description: 'Shake A-hand (thumb up) back and forth',
          emoji: '🔟',
          steps: [
            'Make thumbs-up shape',
            'Shake hand back and forth',
            'Twist at the wrist',
          ],
          category: 'Numbers',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: '11 (Eleven)',
          description: 'Flick index finger up twice from fist',
          emoji: '1️⃣1️⃣',
          steps: [
            'Start with index finger bent',
            'Flick it upward',
            'Repeat twice quickly',
          ],
          category: 'Numbers',
          difficulty: 'Advanced',
        ),
        SignEntry(
          word: '20 (Twenty)',
          description: 'Sign 2 then 0, or bend/close L-hand',
          emoji: '2️⃣0️⃣',
          steps: [
            'Form L-hand (index + thumb)',
            'Open and close fingers twice',
            'Like snapping L',
          ],
          category: 'Numbers',
          difficulty: 'Advanced',
        ),
        SignEntry(
          word: '100 (Hundred)',
          description: 'Sign 1 then C-hand',
          emoji: '💯',
          steps: [
            'Hold up index finger (1)',
            'Then form C-hand',
            'Like 1 century',
          ],
          category: 'Numbers',
          difficulty: 'Advanced',
        ),
      ],
    ),

    // ── FAMILY ──
    SignCategory(
      name: 'Family',
      icon: '👨‍👩‍👧‍👦',
      signs: [
        SignEntry(
          word: 'Mother',
          description: 'Open hand, thumb taps chin',
          emoji: '👩',
          steps: ['Spread open hand', 'Place thumb on chin', 'Tap twice'],
          category: 'Family',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'Father',
          description: 'Open hand, thumb taps forehead',
          emoji: '👨',
          steps: ['Spread open hand', 'Place thumb on forehead', 'Tap twice'],
          category: 'Family',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'Baby',
          description: 'Cradle arms and rock side to side',
          emoji: '👶',
          steps: [
            'Place one arm on top of the other',
            'As if holding a baby',
            'Rock side to side',
          ],
          category: 'Family',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'Friend',
          description: 'Hook index fingers together twice',
          emoji: '🤝',
          steps: [
            'Hook right index over left',
            'Reverse and hook left over right',
            'Like linking together',
          ],
          category: 'Family',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'Sister',
          description: 'Trace jaw then sign "same"',
          emoji: '👧',
          steps: [
            'Make L-hand at chin (girl)',
            'Move down',
            'Then bring both index fingers together',
          ],
          category: 'Family',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'Brother',
          description: 'Tap forehead then sign "same"',
          emoji: '👦',
          steps: [
            'Make L-hand at forehead (boy)',
            'Move down',
            'Then bring both index fingers together',
          ],
          category: 'Family',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'Grandma',
          description: 'Sign mother but with two bounces away from chin',
          emoji: '👵',
          steps: [
            'Open hand at chin (mother)',
            'Bounce forward twice',
            'Moving away from face',
          ],
          category: 'Family',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'Grandpa',
          description: 'Sign father but with two bounces away from forehead',
          emoji: '👴',
          steps: [
            'Open hand at forehead (father)',
            'Bounce forward twice',
            'Moving away from face',
          ],
          category: 'Family',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'Family',
          description: 'Both F-hands circle to form a circle',
          emoji: '👨‍👩‍👧‍👦',
          steps: [
            'Form F with both hands',
            'Touch thumbs and index fingers',
            'Circle outward until pinkies touch',
          ],
          category: 'Family',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'Husband',
          description: 'Sign "man" then clasp hands',
          emoji: '💑',
          steps: [
            'Touch forehead with open hand (male)',
            'Move down',
            'Clasp both hands together (married)',
          ],
          category: 'Family',
          difficulty: 'Advanced',
        ),
        SignEntry(
          word: 'Wife',
          description: 'Sign "woman" then clasp hands',
          emoji: '💑',
          steps: [
            'Touch chin with open hand (female)',
            'Move down',
            'Clasp both hands together (married)',
          ],
          category: 'Family',
          difficulty: 'Advanced',
        ),
        SignEntry(
          word: 'Neighbor',
          description: 'Sign "near" + "person"',
          emoji: '🏘️',
          steps: [
            'Curve both hands facing each other',
            'Move dominant hand close to non-dominant (near)',
            'Then sign person: flat hands move down body sides',
          ],
          category: 'Family',
          difficulty: 'Advanced',
        ),
      ],
    ),

    // ── EMOTIONS & FEELINGS ──
    SignCategory(
      name: 'Emotions',
      icon: '😊',
      signs: [
        SignEntry(
          word: 'Happy',
          description: 'Brush chest upward with flat hand repeatedly',
          emoji: '😊',
          steps: [
            'Place flat hand on chest',
            'Brush upward',
            'Repeat with upward energy',
          ],
          category: 'Emotions',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'Sad',
          description: 'Pull both hands down the face',
          emoji: '😢',
          steps: [
            'Hold both open hands near face',
            'Pull downward',
            'Make sad expression',
          ],
          category: 'Emotions',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'Love',
          description: 'Cross arms over chest like a hug',
          emoji: '❤️',
          steps: [
            'Cross both arms over chest',
            'Fists closed',
            'Like hugging yourself',
          ],
          category: 'Emotions',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'Tired',
          description: 'Both hands on chest, let them drop/rotate down',
          emoji: '😴',
          steps: [
            'Place both bent hands on chest',
            'Let them rotate downward',
            'Like energy draining',
          ],
          category: 'Emotions',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'Angry',
          description: 'Claw hand in front of face, pull outward',
          emoji: '😠',
          steps: [
            'Hold claw hand near face',
            'Pull outward firmly',
            'Show angry expression',
          ],
          category: 'Emotions',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'Scared',
          description: 'Both fists open suddenly in front of chest',
          emoji: '😨',
          steps: [
            'Hold both fists near chest',
            'Open them suddenly',
            'As if startled',
          ],
          category: 'Emotions',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'Excited',
          description: 'Both hands brush up chest alternately',
          emoji: '🤩',
          steps: [
            'Place open hands on chest',
            'Brush upward alternately',
            'Quick energetic motions',
          ],
          category: 'Emotions',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'Bored',
          description: 'Place index finger on side of nose, twist',
          emoji: '😑',
          steps: [
            'Touch side of nose with index finger',
            'Twist slightly',
            'Neutral expression',
          ],
          category: 'Emotions',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'Surprised',
          description: 'Flick index fingers and thumbs near eyes',
          emoji: '😲',
          steps: [
            'Place pinched fingers near eyes',
            'Flick open suddenly',
            'Widen eyes',
          ],
          category: 'Emotions',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'Confused',
          description: 'Both claw hands near head, twist alternately',
          emoji: '😕',
          steps: [
            'Hold claw hands near temples',
            'Twist them alternately',
            'Like thoughts spinning',
          ],
          category: 'Emotions',
          difficulty: 'Advanced',
        ),
        SignEntry(
          word: 'Jealous',
          description: 'Hook index finger at corner of mouth and twist',
          emoji: '😒',
          steps: [
            'Place bent index finger at corner of mouth',
            'Twist outward',
            'Like biting your cheek',
          ],
          category: 'Emotions',
          difficulty: 'Advanced',
        ),
        SignEntry(
          word: 'Proud',
          description: 'Thumb moves upward on chest',
          emoji: '😤',
          steps: [
            'Make thumbs-up hand',
            'Place thumb on stomach',
            'Move upward along chest',
          ],
          category: 'Emotions',
          difficulty: 'Advanced',
        ),
      ],
    ),

    // ── FOOD & DRINK ──
    SignCategory(
      name: 'Food & Drink',
      icon: '🍽️',
      signs: [
        SignEntry(
          word: 'Food/Eat',
          description: 'Bunch fingertips together and tap them to mouth',
          emoji: '🍽️',
          steps: [
            'Bunch all fingertips together',
            'Bring to your mouth',
            'Tap twice',
          ],
          category: 'Food & Drink',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'Water',
          description: 'W-hand taps chin',
          emoji: '💧',
          steps: [
            'Form W with three fingers',
            'Tap index finger on chin',
            'Tap twice',
          ],
          category: 'Food & Drink',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'Hungry',
          description: 'Claw hand moves down from throat to stomach',
          emoji: '😋',
          steps: [
            'Place C-hand at throat',
            'Move downward to stomach',
            'Like hunger moving through you',
          ],
          category: 'Food & Drink',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'Thirsty',
          description: 'Drag index finger down throat',
          emoji: '🥤',
          steps: [
            'Extend index finger',
            'Place at top of throat',
            'Drag downward',
          ],
          category: 'Food & Drink',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'Drink',
          description: 'Cup hand near mouth and tilt',
          emoji: '🥤',
          steps: [
            'Form C-hand like holding cup',
            'Bring to mouth',
            'Tilt as if drinking',
          ],
          category: 'Food & Drink',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'Milk',
          description: 'Squeeze fist like milking a cow',
          emoji: '🥛',
          steps: [
            'Hold hand in C shape',
            'Squeeze into fist',
            'Repeat like milking',
          ],
          category: 'Food & Drink',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'Fruit',
          description: 'F-hand on cheek, twist',
          emoji: '🍎',
          steps: [
            'Form F at cheek',
            'Twist wrist forward',
            'Like picking fruit',
          ],
          category: 'Food & Drink',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'Bread',
          description: 'Slice back of non-dominant hand with other hand',
          emoji: '🍞',
          steps: [
            'Hold non-dominant hand flat',
            'Slice along the back with dominant fingers',
            'Like cutting bread slices',
          ],
          category: 'Food & Drink',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'Coffee',
          description: 'Place one S-hand on the other, grind in circles',
          emoji: '☕',
          steps: [
            'Place one fist on top of the other',
            'Rotate top fist in circles',
            'Like grinding coffee',
          ],
          category: 'Food & Drink',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'Cook',
          description: 'Flip hand on opposite palm like flipping pancake',
          emoji: '👨‍🍳',
          steps: [
            'Place flat hand on opposite palm',
            'Flip over',
            'Like flipping food in pan',
          ],
          category: 'Food & Drink',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'Restaurant',
          description: 'R-hand taps both sides of mouth alternately',
          emoji: '🍴',
          steps: [
            'Form R-hand (crossed index+middle)',
            'Touch one corner of mouth',
            'Then the other side',
          ],
          category: 'Food & Drink',
          difficulty: 'Advanced',
        ),
        SignEntry(
          word: 'Delicious',
          description: 'Touch middle finger to chin then flick away',
          emoji: '😋',
          steps: [
            'Touch chin with bent middle finger',
            'Move away and flick',
            'Show pleasure on face',
          ],
          category: 'Food & Drink',
          difficulty: 'Advanced',
        ),
      ],
    ),

    // ── MEDICAL & HEALTH ──
    SignCategory(
      name: 'Medical & Health',
      icon: '🏥',
      signs: [
        SignEntry(
          word: 'Doctor',
          description: 'Tap wrist with fingertips like taking pulse',
          emoji: '👨‍⚕️',
          steps: [
            'Hold non-dominant wrist up',
            'Tap with dominant fingertips',
            'Like checking a pulse',
          ],
          category: 'Medical',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'Medicine',
          description: 'Rock middle finger in palm of other hand',
          emoji: '💊',
          steps: [
            'Extend middle finger',
            'Place in opposite palm',
            'Rock back and forth',
          ],
          category: 'Medical',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'Pain/Hurt',
          description: 'Point both index fingers at each other, twist',
          emoji: '🤕',
          steps: [
            'Extend both index fingers',
            'Point at each other',
            'Twist in opposite directions',
          ],
          category: 'Medical',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'Help',
          description: 'Place fist on open palm and raise together',
          emoji: '🆘',
          steps: [
            'Make a fist with dominant hand',
            'Place on open non-dominant palm',
            'Raise both upward together',
          ],
          category: 'Medical',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'Sick',
          description: 'Middle finger taps forehead, other taps stomach',
          emoji: '🤒',
          steps: [
            'Touch forehead with dominant middle finger',
            'Touch stomach with non-dominant middle finger',
            'Both at the same time',
          ],
          category: 'Medical',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'Fever',
          description: 'Place back of hand on forehead',
          emoji: '🤒',
          steps: [
            'Place back of dominant hand',
            'On forehead',
            'Hold as if checking temperature',
          ],
          category: 'Medical',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'Hospital',
          description: 'Draw cross on upper arm with H-hand',
          emoji: '🏥',
          steps: [
            'Form H-hand (index + middle)',
            'Draw a cross on upper arm',
            'Like a medical cross symbol',
          ],
          category: 'Medical',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'Allergy',
          description: 'Touch nose with index, then pull away',
          emoji: '🤧',
          steps: [
            'Touch nose with index finger',
            'Pull finger away',
            'Like a reaction',
          ],
          category: 'Medical',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'Blood',
          description: 'Flick fingers down from back of opposite hand',
          emoji: '🩸',
          steps: [
            'Touch back of non-dominant hand',
            'Wiggle fingers as you move down',
            'Like blood flowing',
          ],
          category: 'Medical',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'Ambulance',
          description: 'Rotate fist in circles (like siren light)',
          emoji: '🚑',
          steps: [
            'Make a fist above head',
            'Rotate in circles',
            'Like an ambulance siren light',
          ],
          category: 'Medical',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'Surgery',
          description: 'Drag thumb across stomach area',
          emoji: '🔪',
          steps: [
            'Extend thumb',
            'Place at one side of stomach',
            'Drag across like an incision',
          ],
          category: 'Medical',
          difficulty: 'Advanced',
        ),
        SignEntry(
          word: 'Prescription',
          description: 'Write on opposite palm with P-hand',
          emoji: '📋',
          steps: [
            'Form P-hand (index + middle down)',
            'Move across opposite palm',
            'Like writing a prescription',
          ],
          category: 'Medical',
          difficulty: 'Advanced',
        ),
      ],
    ),

    // ── EMERGENCY ──
    SignCategory(
      name: 'Emergency',
      icon: '🚨',
      signs: [
        SignEntry(
          word: 'Emergency',
          description: 'Wave hand rapidly above head',
          emoji: '🚨',
          steps: [
            'Raise hand above head',
            'Wave back and forth rapidly',
            'Show urgency',
          ],
          category: 'Emergency',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'Help',
          description: 'Place fist on open palm and raise together',
          emoji: '🆘',
          steps: [
            'Make a fist with dominant hand',
            'Place on open non-dominant palm',
            'Raise both upward together',
          ],
          category: 'Emergency',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'Stop',
          description: 'Chop dominant hand down onto non-dominant palm',
          emoji: '🛑',
          steps: [
            'Hold non-dominant palm flat',
            'Bring dominant hand down firmly',
            'Like chopping onto palm',
          ],
          category: 'Emergency',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'Danger',
          description:
              'Push A-hand (thumb up) upward against other palm repeatedly',
          emoji: '⚠️',
          steps: [
            'Make fist with thumb up',
            'Push upward against opposite flat palm',
            'Repeat urgently',
          ],
          category: 'Emergency',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'Fire',
          description: 'Wiggle fingers while moving hands upward',
          emoji: '🔥',
          steps: [
            'Hold both hands low',
            'Wiggle all fingers',
            'Move hands upward like flames',
          ],
          category: 'Emergency',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'Police',
          description: 'C-hand taps upper chest like badge',
          emoji: '👮',
          steps: [
            'Form C-hand',
            'Tap upper left chest',
            'Where a badge would be',
          ],
          category: 'Emergency',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'Accident',
          description: 'Both fists collide in front of body',
          emoji: '💥',
          steps: [
            'Hold both fists up',
            'Move them toward each other',
            'Collide in the middle',
          ],
          category: 'Emergency',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'Call 911',
          description: 'Fingerspell 911 then phone sign',
          emoji: '📞',
          steps: [
            'Sign 9, then 1, then 1',
            'Then hold Y-hand to ear',
            'Like making a phone call',
          ],
          category: 'Emergency',
          difficulty: 'Advanced',
        ),
        SignEntry(
          word: 'Escape',
          description: 'Shoot index finger out from between other fingers',
          emoji: '🏃',
          steps: [
            'Place dominant index between non-dominant fingers',
            'Pull out quickly forward',
            'Like escaping from grasp',
          ],
          category: 'Emergency',
          difficulty: 'Advanced',
        ),
      ],
    ),

    // ── EVERYDAY ACTIONS ──
    SignCategory(
      name: 'Everyday Actions',
      icon: '🏃',
      signs: [
        SignEntry(
          word: 'Go',
          description: 'Both index fingers point and move forward',
          emoji: '👉',
          steps: [
            'Point both index fingers',
            'Move them forward',
            'In an arc together',
          ],
          category: 'Actions',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'Come',
          description: 'Beckon with index finger toward yourself',
          emoji: '🫳',
          steps: [
            'Extend index finger',
            'Point away from you',
            'Curl toward yourself',
          ],
          category: 'Actions',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'Sleep',
          description: 'Place hand on cheek and tilt head',
          emoji: '😴',
          steps: [
            'Spread open hand',
            'Place on cheek',
            'Tilt head toward hand, close eyes',
          ],
          category: 'Actions',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'Think',
          description: 'Touch index finger to forehead',
          emoji: '🤔',
          steps: [
            'Extend index finger',
            'Touch to forehead/temple',
            'Hold briefly',
          ],
          category: 'Actions',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'Wait',
          description: 'Hold both open hands up, wiggle fingers',
          emoji: '⏳',
          steps: [
            'Hold both hands up palms facing up',
            'Wiggle all fingers',
            'Show patience',
          ],
          category: 'Actions',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'Walk',
          description: 'Two fingers walk on opposite palm',
          emoji: '🚶',
          steps: [
            'Extend index and middle on one hand',
            'Walk them along opposite palm',
            'Like little legs walking',
          ],
          category: 'Actions',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'Work',
          description: 'Tap S-fist on top of other S-fist',
          emoji: '💼',
          steps: [
            'Make fists with both hands',
            'Tap dominant on top of non-dominant',
            'Tap twice like hammering',
          ],
          category: 'Actions',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'Understand',
          description: 'Flick index finger up near temple',
          emoji: '💡',
          steps: [
            'Place index finger near temple',
            'Flick upward',
            'Like a light bulb turning on',
          ],
          category: 'Actions',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'Learn',
          description: 'Pull fingertips from palm to forehead',
          emoji: '📚',
          steps: [
            'Place fingertips on opposite palm',
            'Pull up to forehead',
            'Like pulling knowledge into head',
          ],
          category: 'Actions',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'Read',
          description: 'V-hand scans across opposite palm',
          emoji: '📖',
          steps: [
            'Form V with dominant hand',
            'Point at opposite flat palm',
            'Move downward like reading lines',
          ],
          category: 'Actions',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'Write',
          description: 'Pinch fingers and write on opposite palm',
          emoji: '✍️',
          steps: [
            'Pinch dominant thumb and index',
            'Move across opposite flat palm',
            'Like writing with a pen',
          ],
          category: 'Actions',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'Run',
          description: 'Hook index fingers and move them fast in L-hands',
          emoji: '🏃',
          steps: [
            'Extend L with both hands',
            'Hook index of one around thumb of other',
            'Move forward quickly, wiggling',
          ],
          category: 'Actions',
          difficulty: 'Advanced',
        ),
        SignEntry(
          word: 'Drive',
          description: 'Both fists grip and steer like a wheel',
          emoji: '🚗',
          steps: [
            'Hold both fists in front',
            'Twist as if steering',
            'Move hands alternately',
          ],
          category: 'Actions',
          difficulty: 'Advanced',
        ),
      ],
    ),

    // ── PLACES ──
    SignCategory(
      name: 'Places',
      icon: '🏠',
      signs: [
        SignEntry(
          word: 'Home',
          description: 'Touch bunched fingertips from mouth to cheek',
          emoji: '🏠',
          steps: [
            'Bunch fingertips together',
            'Touch near mouth',
            'Move to touch cheek',
          ],
          category: 'Places',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'School',
          description: 'Clap hands twice',
          emoji: '🏫',
          steps: [
            'Hold both hands flat',
            'Clap twice',
            'Like getting attention in class',
          ],
          category: 'Places',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'Bathroom',
          description: 'Shake T-hand side to side',
          emoji: '🚻',
          steps: [
            'Form T (thumb between index and middle)',
            'Shake side to side',
            'Quick motion',
          ],
          category: 'Places',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'Store/Shop',
          description: 'Flat O hands move outward from body',
          emoji: '🏪',
          steps: [
            'Bunch fingertips together',
            'Hold near body',
            'Flick outward twice',
          ],
          category: 'Places',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'Church',
          description: 'C-hand taps back of S-hand',
          emoji: '⛪',
          steps: [
            'Form C with dominant hand',
            'Tap on back of non-dominant fist',
            'Like a building with a cross',
          ],
          category: 'Places',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'Outside',
          description: 'Pull cupped hand away from body twice',
          emoji: '🌳',
          steps: [
            'Hold cupped hand near body',
            'Pull away outward',
            'Repeat closing fingers twice',
          ],
          category: 'Places',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'Library',
          description: 'L-hand circles in space',
          emoji: '📚',
          steps: ['Form L-hand', 'Move in small circles', 'In neutral space'],
          category: 'Places',
          difficulty: 'Advanced',
        ),
        SignEntry(
          word: 'Hospital',
          description: 'Draw cross on upper arm with H-hand',
          emoji: '🏥',
          steps: [
            'Form H-hand',
            'Draw a cross shape on upper arm',
            'Like a red cross symbol',
          ],
          category: 'Places',
          difficulty: 'Advanced',
        ),
        SignEntry(
          word: 'Airport',
          description: 'Sign "fly" + "place"',
          emoji: '✈️',
          steps: [
            'Extend hand flat like a plane (fly)',
            'Move it forward',
            'Then sign "place": P-hands circle back to touch',
          ],
          category: 'Places',
          difficulty: 'Advanced',
        ),
      ],
    ),

    // ── COMMON PHRASES ──
    SignCategory(
      name: 'Common Phrases',
      icon: '💬',
      signs: [
        SignEntry(
          word: 'I Love You',
          description: 'Extend thumb, index, and pinky finger',
          emoji: '🤟',
          steps: [
            'Extend thumb out',
            'Extend index finger up',
            'Extend pinky up',
            'Keep middle and ring folded',
          ],
          category: 'Phrases',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'I\'m Deaf',
          description: 'Point to ear, then to mouth, then to self',
          emoji: '🧏',
          steps: [
            'Point index finger to ear',
            'Move to touch near mouth',
            'Point to self',
          ],
          category: 'Phrases',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'Can You Help Me?',
          description: 'Sign "help" + point at person',
          emoji: '🙏',
          steps: [
            'Fist on open palm, raise up (help)',
            'Point at the person',
            'Show questioning expression',
          ],
          category: 'Phrases',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'What\'s Your Name?',
          description: 'Sign "name" + point at person with questioning face',
          emoji: '❓',
          steps: [
            'Tap H-fingers together twice (name)',
            'Point at the person',
            'Show questioning expression',
          ],
          category: 'Phrases',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'I Don\'t Understand',
          description: 'Touch temple with index and flick away',
          emoji: '🤷',
          steps: [
            'Touch temple with index finger',
            'Flick finger away/down',
            'Shake head no',
          ],
          category: 'Phrases',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'Do You Sign?',
          description: 'Both index fingers circle alternately toward person',
          emoji: '🤟',
          steps: [
            'Extend both index fingers',
            'Circle them alternately',
            'Direct toward the person',
          ],
          category: 'Phrases',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'Where Is The Bathroom?',
          description: 'Sign "bathroom" + "where"',
          emoji: '🚻',
          steps: [
            'Shake T-hand (bathroom)',
            'Then hold both palms up',
            'Shake side to side with questioning face (where)',
          ],
          category: 'Phrases',
          difficulty: 'Advanced',
        ),
        SignEntry(
          word: 'How Much?',
          description: 'Both cupped hands face up and bounce',
          emoji: '💰',
          steps: [
            'Hold both cupped hands palms up',
            'Bounce upward',
            'Questioning expression',
          ],
          category: 'Phrases',
          difficulty: 'Advanced',
        ),
        SignEntry(
          word: 'Slow Down Please',
          description: 'Drag hand slowly across opposite arm + "please"',
          emoji: '🐢',
          steps: [
            'Place dominant hand on opposite forearm',
            'Drag slowly toward wrist',
            'Then rub chest in circle (please)',
          ],
          category: 'Phrases',
          difficulty: 'Advanced',
        ),
        SignEntry(
          word: 'Thank You Very Much',
          description: 'Sign "thank you" with emphasis',
          emoji: '🙏',
          steps: [
            'Touch chin with fingertips',
            'Move hand far forward',
            'Use both hands for emphasis',
          ],
          category: 'Phrases',
          difficulty: 'Advanced',
        ),
        SignEntry(
          word: 'Nice to Meet You',
          description: 'Point at person then bring index fingers together',
          emoji: '🤝',
          steps: [
            'Point at the other person',
            'Bring both index fingers together',
            'Like two people meeting',
          ],
          category: 'Phrases',
          difficulty: 'Advanced',
        ),
      ],
    ),

    // ── TIME & DAYS ──
    SignCategory(
      name: 'Time & Days',
      icon: '📅',
      signs: [
        SignEntry(
          word: 'Today',
          description: 'Drop both Y-hands down in front',
          emoji: '📅',
          steps: [
            'Hold both Y-hands up',
            'Drop them down in front of body',
            'Land at waist level',
          ],
          category: 'Time',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'Tomorrow',
          description: 'A-hand thumb on cheek, arc forward',
          emoji: '➡️',
          steps: [
            'Touch thumb to cheek',
            'Arc hand forward',
            'Like moving to the next day',
          ],
          category: 'Time',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'Now',
          description: 'Drop both bent hands down slightly',
          emoji: '⏰',
          steps: [
            'Hold both bent hands at chest level',
            'Drop slightly downward',
            'Quick firm movement',
          ],
          category: 'Time',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'Yesterday',
          description: 'A-hand thumb touches cheek, then back of jaw',
          emoji: '⬅️',
          steps: [
            'Touch thumb to chin',
            'Move back to touch ear area',
            'Like going back a day',
          ],
          category: 'Time',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'Later',
          description: 'L-hand pivots forward from thumb on palm',
          emoji: '🔜',
          steps: [
            'Form L with dominant hand',
            'Place thumb on non-dominant palm',
            'Pivot index finger forward',
          ],
          category: 'Time',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'Week',
          description: 'Slide index across opposite palm',
          emoji: '📆',
          steps: [
            'Hold non-dominant hand flat',
            'Slide dominant index finger across',
            'From base to fingertips',
          ],
          category: 'Time',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'Month',
          description: 'Slide index down the back of opposite index',
          emoji: '📆',
          steps: [
            'Hold non-dominant index up',
            'Slide dominant index down the back',
            'From top to bottom',
          ],
          category: 'Time',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'Morning',
          description: 'Non-dominant arm as horizon, raise dominant hand',
          emoji: '🌅',
          steps: [
            'Place non-dominant arm across body',
            'Place dominant bent hand below',
            'Raise it like a rising sun',
          ],
          category: 'Time',
          difficulty: 'Advanced',
        ),
        SignEntry(
          word: 'Afternoon',
          description: 'Non-dominant arm as horizon, dominant arm at 45°',
          emoji: '☀️',
          steps: [
            'Lay non-dominant arm flat',
            'Place dominant forearm on it at 45 degrees',
            'Like the afternoon sun position',
          ],
          category: 'Time',
          difficulty: 'Advanced',
        ),
        SignEntry(
          word: 'Night',
          description: 'Dominant bent hand drops over non-dominant flat arm',
          emoji: '🌙',
          steps: [
            'Hold non-dominant arm flat',
            'Hold dominant bent hand above',
            'Drop it over like the sun going down',
          ],
          category: 'Time',
          difficulty: 'Advanced',
        ),
      ],
    ),

    // ── COLORS ──
    SignCategory(
      name: 'Colors',
      icon: '🎨',
      signs: [
        SignEntry(
          word: 'Red',
          description: 'Stroke index finger down from lips',
          emoji: '🔴',
          steps: [
            'Touch lips with index finger',
            'Stroke downward',
            'Repeat once',
          ],
          category: 'Colors',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'Blue',
          description: 'Shake B-hand side to side',
          emoji: '🔵',
          steps: [
            'Form B-hand',
            'Shake/twist side to side',
            'In space to the right',
          ],
          category: 'Colors',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'Green',
          description: 'Shake G-hand side to side',
          emoji: '🟢',
          steps: [
            'Form G-hand',
            'Shake/twist side to side',
            'In space to the right',
          ],
          category: 'Colors',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'Yellow',
          description: 'Shake Y-hand side to side',
          emoji: '🟡',
          steps: [
            'Form Y-hand (thumb + pinky out)',
            'Shake/twist side to side',
            'In space to the right',
          ],
          category: 'Colors',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'Black',
          description: 'Drag index finger across forehead',
          emoji: '⚫',
          steps: [
            'Extend index finger',
            'Place at one side of forehead',
            'Drag across to other side',
          ],
          category: 'Colors',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'White',
          description: 'Pull open hand away from chest, closing fingers',
          emoji: '⚪',
          steps: [
            'Place open hand on chest',
            'Pull away from body',
            'Close fingers as you pull',
          ],
          category: 'Colors',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'Orange',
          description: 'Squeeze fist at chin like squeezing an orange',
          emoji: '🟠',
          steps: [
            'Hold C-hand at chin',
            'Squeeze into fist',
            'Repeat like squeezing citrus',
          ],
          category: 'Colors',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'Pink',
          description: 'Brush middle finger down from lips',
          emoji: '🩷',
          steps: [
            'Touch lips with middle finger',
            'Brush downward',
            'Like "red" but with P-hand',
          ],
          category: 'Colors',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'Purple',
          description: 'Shake P-hand side to side',
          emoji: '🟣',
          steps: [
            'Form P-hand (index + middle down)',
            'Shake/twist side to side',
            'In neutral space',
          ],
          category: 'Colors',
          difficulty: 'Advanced',
        ),
        SignEntry(
          word: 'Brown',
          description: 'B-hand slides down cheek',
          emoji: '🟤',
          steps: [
            'Form B-hand',
            'Place at cheekbone',
            'Slide downward along cheek',
          ],
          category: 'Colors',
          difficulty: 'Advanced',
        ),
      ],
    ),

    // ── SCHOOL & WORK ──
    SignCategory(
      name: 'School & Work',
      icon: '🎒',
      signs: [
        SignEntry(
          word: 'Teacher',
          description: 'Spread fingertips from temples outward + person sign',
          emoji: '👩‍🏫',
          steps: [
            'Place both O-hands at temples',
            'Move outward spreading fingers',
            'Then flat hands down sides (person)',
          ],
          category: 'School & Work',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'Student',
          description: 'Sign "learn" then "person"',
          emoji: '🎓',
          steps: [
            'Pull fingertips from palm to forehead (learn)',
            'Then flat hands move down body sides (person)',
            'Combining both signs',
          ],
          category: 'School & Work',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'Book',
          description: 'Open flat hands like opening a book',
          emoji: '📖',
          steps: [
            'Place palms together',
            'Open them outward',
            'Like opening a book',
          ],
          category: 'School & Work',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'Paper',
          description: 'Brush non-dominant palm with dominant',
          emoji: '📄',
          steps: [
            'Hold non-dominant palm up',
            'Brush dominant hand across twice',
            'Like smoothing paper',
          ],
          category: 'School & Work',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'Computer',
          description: 'C-hand circles on non-dominant forearm',
          emoji: '💻',
          steps: [
            'Form C-hand',
            'Circle it on opposite forearm',
            'Like a mouse on a pad',
          ],
          category: 'School & Work',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'Job/Work',
          description: 'Tap S-fist on top of other S-fist',
          emoji: '💼',
          steps: [
            'Make fists with both hands',
            'Tap dominant on top of non-dominant',
            'Tap twice firmly',
          ],
          category: 'School & Work',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'Office',
          description: 'O-hands slide apart from each other',
          emoji: '🏢',
          steps: [
            'Form O with both hands touching',
            'Slide them apart horizontally',
            'Like defining a space',
          ],
          category: 'School & Work',
          difficulty: 'Advanced',
        ),
        SignEntry(
          word: 'Meeting',
          description: 'Bring both flat hands together',
          emoji: '🤝',
          steps: [
            'Hold both flat hands apart',
            'Bring them together',
            'Fingers pointing up when they meet',
          ],
          category: 'School & Work',
          difficulty: 'Advanced',
        ),
        SignEntry(
          word: 'Business',
          description: 'B-hand on wrist of other hand, shake',
          emoji: '💼',
          steps: [
            'Form B-hand',
            'Place on opposite wrist',
            'Shake up and down slightly',
          ],
          category: 'School & Work',
          difficulty: 'Advanced',
        ),
      ],
    ),

    // ── SPORTS & HOBBIES ──
    SignCategory(
      name: 'Sports & Hobbies',
      icon: '⚽',
      signs: [
        SignEntry(
          word: 'Play',
          description: 'Y-hands shake at wrists',
          emoji: '🎮',
          steps: [
            'Form Y-hand with both hands',
            'Shake both wrists',
            'Loose relaxed motion',
          ],
          category: 'Sports & Hobbies',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'Music',
          description: 'Wave flat hand over non-dominant forearm',
          emoji: '🎵',
          steps: [
            'Hold non-dominant forearm flat',
            'Wave dominant flat hand over it',
            'Like conducting to a beat',
          ],
          category: 'Sports & Hobbies',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'Soccer',
          description: 'Kick non-dominant fist with dominant hand',
          emoji: '⚽',
          steps: [
            'Make non-dominant fist',
            'Swing dominant flat hand',
            'Kick the fist like a ball',
          ],
          category: 'Sports & Hobbies',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'Basketball',
          description: 'Both hands dribble an imaginary ball',
          emoji: '🏀',
          steps: [
            'Hold both hands slightly cupped',
            'Bounce them downward alternately',
            'Like dribbling a basketball',
          ],
          category: 'Sports & Hobbies',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'Swimming',
          description: 'Both arms do freestyle stroke',
          emoji: '🏊',
          steps: [
            'Extend both arms forward',
            'Alternate pulling back like freestyle',
            'Fluid motion',
          ],
          category: 'Sports & Hobbies',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'Dance',
          description: 'V-hand sways over non-dominant flat palm',
          emoji: '💃',
          steps: [
            'Hold non-dominant palm up',
            'Form V with dominant hand',
            'Sway V back and forth over palm',
          ],
          category: 'Sports & Hobbies',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'Art/Draw',
          description: 'Pinky finger traces wavy line on opposite palm',
          emoji: '🎨',
          steps: [
            'Extend pinky finger',
            'Place on opposite flat palm',
            'Trace wavy lines like drawing',
          ],
          category: 'Sports & Hobbies',
          difficulty: 'Advanced',
        ),
        SignEntry(
          word: 'Cook/Chef',
          description: 'Flip hand on opposite palm like flipping food',
          emoji: '👨‍🍳',
          steps: [
            'Place flat hand on opposite palm',
            'Flip over',
            'Repeat like flipping food in a pan',
          ],
          category: 'Sports & Hobbies',
          difficulty: 'Advanced',
        ),
      ],
    ),

    // ── TRANSPORTATION ──
    SignCategory(
      name: 'Transportation',
      icon: '🚗',
      signs: [
        SignEntry(
          word: 'Car',
          description: 'Both fists steer an imaginary wheel',
          emoji: '🚗',
          steps: [
            'Hold both fists up',
            'Twist as if turning a steering wheel',
            'Back and forth',
          ],
          category: 'Transportation',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'Bus',
          description: 'B-hands pull apart like holding bus bar',
          emoji: '🚌',
          steps: [
            'Hold B-hands facing each other',
            'Pull apart horizontally',
            'Like holding overhead bus bar',
          ],
          category: 'Transportation',
          difficulty: 'Beginner',
        ),
        SignEntry(
          word: 'Train',
          description: 'Slide H-fingers back and forth on other H-fingers',
          emoji: '🚆',
          steps: [
            'Form H with both hands',
            'Place dominant on top of non-dominant',
            'Slide back and forth like train on rails',
          ],
          category: 'Transportation',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'Airplane',
          description: 'Extend thumb, index, and pinky — move forward',
          emoji: '✈️',
          steps: [
            'Form Y-hand (or ILY shape)',
            'Extend forward and upward',
            'Glide like a plane',
          ],
          category: 'Transportation',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'Bicycle',
          description: 'Rotate both fists in circles like pedaling',
          emoji: '🚲',
          steps: [
            'Hold both fists near waist',
            'Rotate in alternating circles',
            'Like pedaling a bike',
          ],
          category: 'Transportation',
          difficulty: 'Intermediate',
        ),
        SignEntry(
          word: 'Boat',
          description: 'Cupped hands move forward with a wave',
          emoji: '⛵',
          steps: [
            'Cup both hands together',
            'Move forward with a slight wave',
            'Like a boat on water',
          ],
          category: 'Transportation',
          difficulty: 'Advanced',
        ),
      ],
    ),
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
