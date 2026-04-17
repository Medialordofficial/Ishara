"""One-time script to build the expanded ASL training dataset."""
import json
import pathlib

SYS = (
    'You are an expert ASL (American Sign Language) interpreter. '
    'Given a description of a hand gesture or image observation, '
    'identify the sign being made and respond ONLY with a JSON object: '
    '{"sign": "...", "confidence": 0.0}'
)


def ex(user: str, sign: str, conf: float) -> dict:
    return {
        "messages": [
            {"role": "system", "content": SYS},
            {"role": "user", "content": user},
            {"role": "assistant", "content": json.dumps({"sign": sign, "confidence": conf})},
        ]
    }


EXAMPLES = [
    # ── GREETINGS ──────────────────────────────────────────────────────────
    ex("Open hand at face level, fingers spread, palm facing outward, slight wave motion.", "Hello", 0.96),
    ex("Flat hand, fingers together, touches forehead then sweeps outward in a salute-like motion.", "Hello", 0.95),
    ex("Right hand open, palm outward at head level, fingers slightly spread — casual greeting wave.", "Hello", 0.94),
    ex("Open hand waves side to side at shoulder height, palm facing out — a farewell gesture.", "Goodbye", 0.95),
    ex("Four fingers wave up and down with palm facing out — common departure sign.", "Goodbye", 0.93),
    # ── POLITENESS ────────────────────────────────────────────────────────
    ex("Open hand, fingers together, flat palm moves away from forehead in a downward arc.", "Thank you", 0.97),
    ex("Fingertips touch lips then sweep forward and down — expressing gratitude.", "Thank you", 0.96),
    ex("Flat hand, palm up, moves upward in front of chest with a slight circular motion.", "Please", 0.94),
    ex("Open hand, palm in, rubs circular clockwise motion on chest.", "Please", 0.95),
    ex("Closed fist circles over heart clockwise — expressing regret or apology.", "Sorry", 0.96),
    ex("A-handshape rotates in a circle over the chest — apologetic body language.", "Sorry", 0.94),
    ex("Open hand at forehead, palm facing body, moves outward and downward — showing respect.", "Sorry", 0.92),
    # ── AFFIRMATIVE / NEGATIVE ────────────────────────────────────────────
    ex("Both hands form fists, thumbs pointing up, move upward simultaneously from chest height.", "Good", 0.95),
    ex("Open hand at chin, palm in, moves forward and slightly down — positive affirmation.", "Good", 0.93),
    ex("Thumb points downward, hand moves slightly down — negative evaluation.", "Bad", 0.94),
    ex("Bent hand, palm down at chin level, flicks outward and downward — expressing something negative.", "Bad", 0.91),
    ex("Thumb and index finger form a circle, other three fingers extended upward — agreement.", "Yes", 0.94),
    ex("S-handshape nods up and down twice at wrist — affirming or agreeing.", "Yes", 0.95),
    ex("Both hands open, palms down, move side to side in front of body — refusing or negating.", "No", 0.95),
    ex("Index and middle fingers press together against thumb and close — sharp closing motion indicating refusal.", "No", 0.93),
    # ── HELP / EMERGENCY ─────────────────────────────────────────────────
    ex("Both hands cross in front of chest, then separate outward to sides — urgent assistance sign.", "Help", 0.92),
    ex("Dominant hand thumb up on closed fist, placed on non-dominant flat palm, both move upward together.", "Help", 0.96),
    ex("Person seems distressed; both hands at chest area clenching and opening rapidly, face showing urgency.", "Help", 0.88),
    ex("Open flat hand, palm facing outward at chest height, holds steady — halt signal.", "Stop", 0.96),
    ex("Dominant flat hand slaps down onto non-dominant flat palm — sharp stopping motion.", "Stop", 0.95),
    ex("Open hand at head level moves back toward body — pause or wait sign.", "Wait", 0.89),
    ex("Both hands with curved fingers wiggle slightly while held up — pause and hold on.", "Wait", 0.91),
    # ── I LOVE YOU ───────────────────────────────────────────────────────
    ex("Handshape I-Love-You: thumb, index, and pinky extended, ring and middle folded — held still.", "I love you", 0.99),
    ex("ILY handshape — thumb, index, and pinky fully extended — shakes slightly toward the viewer.", "I love you", 0.98),
    # ── PRONOUNS ─────────────────────────────────────────────────────────
    ex("Index finger points to chest, then taps chest twice.", "Me", 0.97),
    ex("Index finger points directly at the signer's own chest — self-reference.", "Me", 0.98),
    ex("Index finger points to signer, then to the intended recipient.", "You", 0.98),
    ex("Index finger extends and points directly at the person being addressed.", "You", 0.97),
    ex("Index finger points to a third person off to the side — not at signer, not at viewer.", "He / She / They", 0.92),
    ex("Open hand sweeps horizontally from one side to the other, pointing to a group of people.", "We / Us", 0.91),
    ex("Both hands form B handshapes, held at chest with palms toward body — referring to self.", "My / Mine", 0.92),
    ex("Flat hand, palm down, pushes toward viewer — indicating possession by the viewer.", "Your / Yours", 0.91),
    # ── QUESTION WORDS ───────────────────────────────────────────────────
    ex("Bent index finger hooks under chin and flicks outward.", "What", 0.90),
    ex("Both open hands, palms up, move side to side with a shrug-like expression — questioning.", "What", 0.89),
    ex("Index finger points upward and moves in a circle (rotational motion at wrist).", "Where", 0.89),
    ex("Index finger wags back and forth horizontally — location-questioning gesture.", "Where", 0.91),
    ex("Flat hand, palm down, moves forward from mouth.", "When", 0.88),
    ex("Both index fingers tap together — asking about time or sequence.", "When", 0.87),
    ex("Index finger taps temple twice then moves outward in a questioning arc.", "Why", 0.90),
    ex("Y-handshape near forehead, shakes forward slightly — causal questioning.", "Why", 0.88),
    ex("Open bent hand moves in an arc from side to side near chest — asking about manner.", "How", 0.91),
    ex("Both bent hands, backs touching, rotate outward — method or manner question.", "How", 0.93),
    ex("Index finger points at a person then moves in a circular motion pointing out identity.", "Who", 0.89),
    ex("Bent L handshape taps chin — identity question.", "Who", 0.87),
    # ── SOCIAL / RELATIONSHIPS ────────────────────────────────────────────
    ex("Both index fingers point toward each other and circle around each other.", "Friend", 0.94),
    ex("Both index fingers hook together and switch positions — linked fingers indicating friendship.", "Friend", 0.95),
    ex("Both index fingers point at each other and cross — meeting or encountering someone.", "Meet", 0.91),
    ex("Both open hands, palms facing each other, move toward the signer and upward — welcoming someone.", "Welcome", 0.91),
    # ── ACTIONS / VERBS ──────────────────────────────────────────────────
    ex("Hand shaped like C at mouth, opens and closes twice like eating.", "Eat", 0.95),
    ex("Flat O handshape taps mouth twice — food/eating motion.", "Eat", 0.94),
    ex("Curved hand shape at mouth mimes drinking from a cup, tipping motion.", "Drink", 0.96),
    ex("C-handshape at lips tilts back as if drinking from a glass or bottle.", "Drink", 0.95),
    ex("Both hands flat, palms facing each other, one slides under the other — sleep gesture near cheek.", "Sleep", 0.93),
    ex("Open fingers spread then close as hand moves down in front of face — eyes closing/sleeping motion.", "Sleep", 0.94),
    ex("Both H handshapes, dominant hand taps on back of non-dominant hand twice.", "Work", 0.93),
    ex("Both fists, dominant wrist taps the back of the non-dominant wrist twice — job or labor sign.", "Work", 0.94),
    ex("Both flat hands, palms down, tap downward twice in front of body.", "Sit", 0.93),
    ex("Both H handshapes, dominant fingers rest on top of non-dominant — seated posture representation.", "Sit", 0.91),
    ex("Both flat hands, palms down at waist, push upward — rising from seated position.", "Stand", 0.90),
    ex("V-handshape fingertips stand on flat non-dominant palm — person standing.", "Stand", 0.92),
    ex("Both V-handshapes walk fingers forward on a flat surface — walking motion mimicry.", "Walk", 0.93),
    ex("Both hands form flat B-shapes, alternate moving forward in walking rhythm.", "Walk", 0.91),
    ex("Dominant index finger points and sweeps in direction of movement — directional sign for going.", "Go", 0.92),
    ex("Both index fingers point forward simultaneously and move in that direction.", "Go", 0.91),
    ex("Dominant index finger curls and beckons toward the signer — come here.", "Come", 0.93),
    ex("Both index fingers arc toward the body — beckoning someone to approach.", "Come", 0.94),
    ex("Both hands form fists, one on top of the other, twisting motion like turning a steering wheel.", "Drive", 0.94),
    ex("Both hands grip an imaginary steering wheel and turn it — vehicle operation.", "Drive", 0.95),
    ex("Dominant hand writes in air, miming a pen on paper — writing motion.", "Write", 0.94),
    ex("G-handshape moves across non-dominant flat palm — written communication.", "Write", 0.93),
    ex("Both hands open, one above the other, V-handshape acts as eyes scanning a surface — reading.", "Read", 0.92),
    ex("V-handshape moves back and forth along non-dominant flat palm — reading lines of text.", "Read", 0.93),
    ex("Dominant A-shape moves toward the body — taking or receiving something.", "Take", 0.90),
    ex("Dominant hand open, moves forward from chest — giving or offering.", "Give", 0.91),
    # ── EMOTIONS ─────────────────────────────────────────────────────────
    ex("Fingers spread open then shake at cheeks near mouth — happy face expression.", "Happy", 0.94),
    ex("Open hand brushes upward on chest twice — positive emotion, joy.", "Happy", 0.95),
    ex("Bent index finger draws downward arc from corner of eye — tear falling gesture.", "Sad", 0.94),
    ex("Both open hands move slowly downward from face — heavy, dejected movement.", "Sad", 0.91),
    ex("Claw hand shakes at chest with tense expression — strong negative emotion.", "Angry", 0.92),
    ex("5-handshape claws inward at chest, pulling with tension — frustration or anger.", "Angry", 0.91),
    ex("Both hands open, body slightly recoils backward — fearful body language with hands at chest.", "Scared", 0.90),
    ex("5-handshapes on both hands come together at chest rapidly — startled or afraid.", "Scared", 0.92),
    ex("Open hand at chest, fingers splayed, moves rapidly upward — excited energy.", "Excited", 0.93),
    ex("Both 5-handshapes alternate brushing upward on chest — enthusiasm, excitement.", "Excited", 0.94),
    ex("Open hand at forehead, palm in, brushes down over face closing eyes — fatigue sign.", "Tired", 0.93),
    ex("Both bent hands at shoulders drop downward, shoulders slump — low energy, tired.", "Tired", 0.92),
    ex("Both flat hands, palms alternating, move side to side in a balancing scale motion.", "Maybe", 0.92),
    ex("Both open hands at chest move together then apart in a hugging motion.", "Love", 0.92),
    ex("Both arms cross at chest in self-hug motion — deep affection sign.", "Love", 0.93),
    ex("5-handshape placed over heart then swept outward.", "Feel", 0.89),
    ex("Middle finger brushes upward on chest — emotional sensation.", "Feel", 0.90),
    # ── KNOWLEDGE / COGNITION ────────────────────────────────────────────
    ex("Index finger taps temple twice — indicating thought or knowledge.", "Know", 0.95),
    ex("Open hand waves side to side at face level — dismissing or not knowing.", "Don't know", 0.91),
    ex("Index finger at forehead flicks outward quickly — knowledge absent.", "Don't know", 0.90),
    ex("Index finger at forehead flicks upward — comprehension, light bulb moment.", "Understand", 0.92),
    ex("Index finger at forehead moves up — grasping a concept, understanding.", "Understand", 0.90),
    ex("Bent index finger moves away from forehead — failure to comprehend.", "Don't understand", 0.91),
    # ── POSSESSION / STATE ────────────────────────────────────────────────
    ex("Flat hand, palm in, bounces up and down twice at chest level.", "Have", 0.90),
    ex("Both bent hands move toward the chest and tap — possessing something.", "Have", 0.91),
    ex("Dominant claw hand moves toward the body — wanting, desiring something.", "Want", 0.93),
    ex("Both hands with curved fingers pull toward the body — expressing desire or need.", "Want", 0.94),
    ex("Both hands open, palms up, drop downward — expressing necessity.", "Need", 0.91),
    ex("X-handshape bends toward ground twice — requiring something, must have.", "Need", 0.92),
    ex("Both S-handshapes move downward together — ability, can do it.", "Can", 0.91),
    ex("Dominant hand C-shape at chest sweeps outward — capability or permission.", "Can", 0.90),
    ex("Open hand, palm in, at chest — moves outward while fingers close together.", "Fine", 0.89),
    ex("5-handshape at chin, thumb taps chin once — okay, fine, acceptable.", "Fine", 0.91),
    # ── PERCEPTION ────────────────────────────────────────────────────────
    ex("Bent V handshape at eyes moves forward — observing, seeing.", "See", 0.91),
    ex("V-handshape from eyes moves forward in line of sight — visual perception.", "See", 0.93),
    ex("A handshape with fingers spread, palm facing outward, moves from ear forward.", "Hear", 0.89),
    ex("Index finger points at ear then moves forward — auditory sensing.", "Hear", 0.90),
    # ── TIME ─────────────────────────────────────────────────────────────
    ex("Index finger arcs forward from forehead area — future time, tomorrow.", "Tomorrow", 0.90),
    ex("Open hand moves from front to behind the shoulder in a backward arc.", "Yesterday", 0.91),
    ex("Index finger taps wrist or points downward at ground — present moment, right now.", "Today / Now", 0.91),
    ex("Both Y handshapes drop downward — now, immediately, present.", "Now", 0.92),
    ex("Hand pushes forward at an angle — indicating later or future time.", "Later", 0.90),
    ex("Both hands open, one above the other — upper hand moves forward, lower hand moves back.", "Time", 0.92),
    ex("Index finger traces circle around the wrist — clock, time reference.", "Time", 0.93),
    ex("One hand open at the side of the head, other arm extends horizontally forward — morning.", "Morning", 0.91),
    ex("Non-dominant arm horizontal, dominant hand drops behind it — sunset, nighttime.", "Night", 0.93),
    ex("Dominant index finger slides across non-dominant index finger — one week duration.", "Week", 0.90),
    ex("Dominant hand circular motion toward non-dominant fist — monthly cycle.", "Month", 0.90),
    ex("Non-dominant index finger points up while dominant hand circles around it — year, annual.", "Year", 0.91),
    # ── NUMBERS ──────────────────────────────────────────────────────────
    ex("Index finger extended upward alone — the number one.", "1", 0.99),
    ex("Index and middle fingers extended upward — the number two.", "2", 0.98),
    ex("Thumb, index, and middle fingers extended — the number three.", "3", 0.98),
    ex("Four fingers extended upward, thumb bent into palm — the number four.", "4", 0.98),
    ex("All five fingers spread wide, palm facing viewer — the number five.", "5", 0.97),
    ex("Pinky and thumb touch, index, middle, ring fingers point up — number six.", "6", 0.97),
    ex("Ring finger and thumb touch, other fingers extended — number seven.", "7", 0.97),
    ex("Middle finger and thumb touch, other fingers extended — number eight.", "8", 0.97),
    ex("Index finger and thumb form a circle, other fingers extended — number nine.", "9", 0.97),
    ex("Closed fist with thumb extended sideways, shakes side to side — number ten.", "10", 0.96),
    # ── ALPHABET ─────────────────────────────────────────────────────────
    ex("Closed fist with thumb alongside fingers — letter A.", "A", 0.98),
    ex("Flat hand, all fingers together, thumb bent across palm — letter B.", "B", 0.98),
    ex("Curved hand, fingers and thumb form a C shape, palm facing sideways — letter C.", "C", 0.98),
    ex("Index finger points up, other fingers curl to touch the thumb — letter D.", "D", 0.97),
    ex("All fingers bend/curl toward palm, thumb tucked under — letter E.", "E", 0.97),
    ex("Index finger and thumb touch forming a circle, other three fingers spread upward — letter F.", "F", 0.97),
    ex("Index finger and thumb extend pointing sideways like a gun — letter G.", "G", 0.97),
    ex("Index and middle fingers extend horizontally together, pointing sideways — letter H.", "H", 0.97),
    ex("Only the pinky finger extends upward, other fingers curled — letter I.", "I", 0.98),
    ex("Pinky extends up then traces a J-hook downward in the air — letter J.", "J", 0.97),
    ex("Index finger points up, middle finger angles out, thumb between them — letter K.", "K", 0.97),
    ex("Index finger points up, thumb points out to the side — forming an L shape.", "L", 0.99),
    ex("Three fingers (index, middle, ring) curl over the top of the thumb — letter M.", "M", 0.97),
    ex("Two fingers (index and middle) curl over the top of the thumb — letter N.", "N", 0.97),
    ex("All fingers curve to meet the thumb, forming a complete O or circle — letter O.", "O", 0.98),
    ex("K-handshape rotated so fingers point downward — letter P.", "P", 0.96),
    ex("G-handshape rotated so index finger points downward — letter Q.", "Q", 0.96),
    ex("Index and middle fingers crossed or intertwined, pointing up — letter R.", "R", 0.97),
    ex("Closed fist, thumb wraps over curled fingers on top — letter S.", "S", 0.97),
    ex("Thumb inserted between index and middle fingers in a fist — letter T.", "T", 0.97),
    ex("Index and middle fingers extend upward together (U shape), others curled — letter U.", "U", 0.98),
    ex("Index and middle fingers spread apart in a V shape, pointing up — letter V.", "V", 0.98),
    ex("Index, middle, and ring fingers all spread and extended upward — letter W.", "W", 0.97),
    ex("Index finger bent like a hook or crooked — letter X.", "X", 0.97),
    ex("Thumb and pinky extended outward, other fingers curled — letter Y.", "Y", 0.98),
    ex("Index finger traces a Z shape in the air — letter Z.", "Z", 0.97),
    # ── DEAF CULTURE ─────────────────────────────────────────────────────
    ex("Hand forms the letter D then taps forehead twice — deaf identity sign.", "Deaf", 0.98),
    ex("Index finger touches ear then moves to touch the mouth — deaf (ear to mouth).", "Deaf", 0.97),
    ex("Index finger at mouth moves outward — spoken language or voice gesture.", "Hearing", 0.93),
    ex("Index finger circles near the mouth indicating speech ability — hearing person.", "Hearing", 0.91),
    ex("Both hands form loose fists with index fingers pointing, move in alternate forward circular motions.", "Sign language", 0.95),
    ex("Both index fingers alternate rotating forward at chest level — ASL signing motion.", "Sign language", 0.96),
    ex("Open hand at mouth pushes forward — voicing or interpreting sign.", "Interpret / Interpreter", 0.89),
    ex("Both open hands circle around each other — community or group gathering.", "Community", 0.88),
    ex("C-handshapes on both hands, circle around each other — gathering, community.", "Community", 0.89),
    # ── FAMILY ────────────────────────────────────────────────────────────
    ex("5-handshape, thumb taps chin twice — mother, mom.", "Mother", 0.95),
    ex("Open hand with fingers slightly bent, thumb taps chin — female parent.", "Mother", 0.93),
    ex("5-handshape, thumb taps forehead twice — father, dad.", "Father", 0.95),
    ex("Open hand with thumb at forehead, tapping twice — paternal parent.", "Father", 0.93),
    ex("Index finger at forehead (male marker) then both L-handshapes come together at chest.", "Brother", 0.90),
    ex("Index finger at chin (female marker) then both L-handshapes come together.", "Sister", 0.90),
    ex("Both open hands circle around each other — all together, family unit.", "Family", 0.93),
    ex("F-handshapes on both hands circle outward and come together — family group.", "Family", 0.94),
    # ── PLACES / OBJECTS ─────────────────────────────────────────────────
    ex("Flat O handshape taps cheek twice — shelter, residence, home.", "Home", 0.92),
    ex("Dominant flat hand claps on non-dominant palm twice — school or education.", "School", 0.91),
    ex("Both B handshapes, palms together at sternum, then open outward like a book.", "Book", 0.96),
    ex("Two flat hands open and close like a book being read.", "Book", 0.95),
    ex("Y-handshape at ear and mouth — telephone receiver gesture.", "Phone", 0.97),
    ex("H-handshape taps on the back of the non-dominant hand — hospital or medical facility.", "Hospital", 0.93),
    ex("Cross shape traced on upper arm with dominant index finger — hospital, medical care.", "Hospital", 0.94),
    ex("Both hands at chest with fingers touching, then sweep to sides — broad space or room.", "Room", 0.90),
    # ── MEDICAL ───────────────────────────────────────────────────────────
    ex("M-handshape taps the inside wrist where a pulse is checked — medical professional.", "Doctor", 0.92),
    ex("Index finger arcs forward from forehead area — referring to a doctor or physician.", "Doctor", 0.90),
    ex("Both index fingers rotate toward each other repeatedly — indicating a hurting area.", "Pain", 0.91),
    ex("Index finger taps at chest area with a pained expression — hurt or pain.", "Pain", 0.90),
    ex("Middle finger taps forehead and stomach simultaneously — feeling ill.", "Sick", 0.92),
    ex("Pill-O handshape flicks toward mouth — taking medicine or medication.", "Medicine", 0.93),
    ex("Middle finger rubs on palm of non-dominant hand — pharmacy or medication sign.", "Medicine", 0.91),
    # ── MISC VOCABULARY ───────────────────────────────────────────────────
    ex("W handshape (three fingers extended) taps against chin twice.", "Water", 0.94),
    ex("W-handshape touches chin twice — liquid, hydration, water sign.", "Water", 0.95),
    ex("Fingertips of both hands tap together repeatedly, flat O handshapes meeting at fingertips.", "More", 0.93),
    ex("Both hands form flat O shapes and tap together twice at fingertips — requesting additional.", "More", 0.94),
    ex("Both index fingers point toward each other and circle — best friends.", "Best friend", 0.91),
    ex("Index finger at wrist traces a circle — indicating a watch and the concept of time.", "Watch / Clock", 0.90),
    ex("Dominant hand A-shape moves toward the chest and then the non-dominant hand — bringing.", "Bring", 0.88),
    ex("Both hands form fists, thumbs up, moved upward emphatically from chest — best, excellent.", "Best", 0.90),
    ex("Both index fingers point at each other and circle around each other — same, alike.", "Same", 0.90),
    ex("Both index fingers point outward away from each other — different, opposite.", "Different", 0.90),
    ex("Open hand at forehead area sweeps forward — a thought or idea.", "Think", 0.91),
    ex("Index finger at temple rotates forward and back — thinking or pondering.", "Think", 0.89),
    ex("Dominant hand A-shape moves forward from chest — sending outward.", "Away", 0.87),
    # ── EDGE CASES ────────────────────────────────────────────────────────
    ex("No clear sign is visible — the person's hands are at their sides, no signing posture detected.", "No sign detected", 0.0),
    ex("Blurry image, hands partially out of frame. Cannot determine gesture clearly.", "No sign detected", 0.0),
    ex("The image is very dark and low quality. Hands are not clearly visible.", "No sign detected", 0.0),
    ex("Two people appear to be signing simultaneously, making it unclear which gesture to interpret.", "No sign detected", 0.0),
    ex("Person appears to be gesturing naturally (non-ASL), scratching their head in thought.", "No sign detected", 0.0),
    ex("Only the person's face and shoulders are visible — hands are not in the frame at all.", "No sign detected", 0.0),
    ex("Person is making a recognizable gesture but their hands are partially cut off at the edge of frame.", "No sign detected", 0.0),
    ex("Hands appear to be in motion between signs — transitional movement, no completed sign visible.", "No sign detected", 0.0),
    ex("Gesture is partially formed but ambiguous — could be multiple signs. Confidence too low to determine.", "No sign detected", 0.15),
]

if __name__ == "__main__":
    out = pathlib.Path(__file__).parent / "asl_dataset.jsonl"
    with open(out, "w") as f:
        for e in EXAMPLES:
            f.write(json.dumps(e) + "\n")
    print(f"Written {len(EXAMPLES)} examples to {out}")
    errors = []
    with open(out) as f:
        for i, line in enumerate(f, 1):
            try:
                obj = json.loads(line.strip())
                assert "messages" in obj and len(obj["messages"]) == 3
            except Exception as e:
                errors.append(f"Line {i}: {e}")
    if errors:
        print(f"ERRORS: {errors[:5]}")
    else:
        print(f"Validation: ALL {i} lines OK")
