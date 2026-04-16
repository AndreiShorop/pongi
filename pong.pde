// ===== PONGI — Modern Arcade Pong with Abilities =====
// 1 Player (vs Bot) or 2 Players | Skins | XP System | Abilities

// ===================== STATES =====================
final int STATE_MENU = 0;
final int STATE_MODE = 1;
final int STATE_DIFFICULTY = 2;
final int STATE_SKINS = 3;
final int STATE_SETTINGS = 4;
final int STATE_SELECT_P1 = 5;
final int STATE_SELECT_P2 = 6;
final int STATE_PLAY = 7;
final int STATE_GAMEOVER = 8;
final int STATE_LEVELUP = 9;
final int STATE_PAUSE = 10;

final String GAME_VERSION = "0.2.0";

// ===================== ABILITIES =====================
final int AB_GROW = 0;
final int AB_SHIELD = 1;
final int AB_SLOW = 2;
final int AB_POWER = 3;
final int AB_CURVE = 4;
final int AB_DASH = 5;
final int AB_BOOST = 6;
final int AB_TELEPORT = 7;
final int AB_COUNT = 8;

final String[] AB_NAMES = {"GROW", "SHIELD", "SLOW", "POWER", "CURVE", "DASH", "BOOST", "TELEPORT"};
final String[] AB_DESC = {"Enlarge paddle", "Block 1 miss", "Slow the ball", "Power shot", "Curve trajectory", "Quick dash", "Fast paddle", "Teleport to ball"};
final String[] AB_CATEGORY = {"DEF", "DEF", "DEF", "ATK", "ATK", "AGI", "AGI", "AGI"};
final float[] AB_COOLDOWN = {8, 15, 7, 6, 5, 4, 6, 8};
final float[] AB_DURATION = {4, 0, 3, 0, 0, 0, 3, 0};

int[][] catColors;

void initCatColors() {
  catColors = new int[][] {
    {80, 180, 255},
    {255, 80, 80},
    {80, 255, 130}
  };
}

int[] getAbilityColor(int ab) {
  if (ab < 0 || ab >= AB_COUNT) return new int[]{255, 255, 255};
  if (ab <= 2) return catColors[0];
  if (ab <= 4) return catColors[1];
  return catColors[2];
}

// ===================== GAME CONFIG =====================
int gameState = STATE_MENU;
int gameMode = 0;
int difficulty = 1;
int winScore = 7;

int ballSpeedSetting = 1;
float[] BALL_SPEEDS = {5.0, 7.0, 9.5};
String[] SPEED_NAMES = {"SLOW", "NORMAL", "FAST"};

// ===================== SKINS =====================
int currentSkin = 0;
final int SKIN_COUNT = 5;
String[] SKIN_NAMES = {"CLASSIC", "NEON", "COSMIC", "RETRO", "MINIMAL"};
final int[] SKIN_UNLOCK_LEVEL = {1, 2, 3, 5, 7};

// Decorations — unlockable titles shown next to the level
final int DECORATION_COUNT = 5;
final String[] DECORATION_NAMES = {"ROOKIE", "STRIKER", "VETERAN", "MASTER", "LEGEND"};
final int[] DECORATION_UNLOCK_LEVEL = {1, 3, 5, 8, 12};
int currentDecoration = 0;
int skinsMenuTab = 0; // 0 = Skins, 1 = Decorations

int[][] skinBG, skinP1, skinP2, skinBall, skinAccent, skinField;

void initSkins() {
  skinBG = new int[][] {
    {12, 8, 25},
    {5, 5, 15},
    {8, 3, 20},
    {0, 0, 0},
    {240, 240, 240}
  };
  skinP1 = new int[][] {
    {80, 180, 255},
    {0, 255, 200},
    {100, 150, 255},
    {255, 255, 255},
    {40, 40, 40}
  };
  skinP2 = new int[][] {
    {255, 80, 80},
    {255, 0, 200},
    {255, 120, 80},
    {255, 255, 255},
    {40, 40, 40}
  };
  skinBall = new int[][] {
    {255, 255, 255},
    {255, 255, 0},
    {255, 200, 100},
    {255, 255, 255},
    {20, 20, 20}
  };
  skinAccent = new int[][] {
    {255, 200, 80},
    {0, 255, 255},
    {180, 100, 255},
    {0, 255, 0},
    {100, 100, 100}
  };
  skinField = new int[][] {
    {40, 30, 70},
    {0, 80, 80},
    {30, 20, 60},
    {0, 100, 0},
    {180, 180, 180}
  };
}

// ===================== XP / LEVEL SYSTEM =====================
int playerXP = 0;
int playerLevel = 1;
int xpToNext = 300;
boolean showLevelUp = false;
boolean xpAwarded = false;
String unlockedItemName = "";
float levelUpTimer = 0;
int levelUpAnimFrame = 0;

int calcXPtoNext(int lvl) {
  return 200 + lvl * 100;
}

void addXP(int amount) {
  if (amount <= 0) { saveProgress(); return; }
  playerXP += amount;
  while (playerXP >= xpToNext) {
    playerXP -= xpToNext;
    playerLevel++;
    xpToNext = calcXPtoNext(playerLevel);
    checkNewUnlocks(playerLevel);
    showLevelUp = true;
    levelUpTimer = 3.0;
    levelUpAnimFrame = 0;
  }
  saveProgress();
}

void checkNewUnlocks(int lvl) {
  unlockedItemName = "";
  for (int i = 0; i < SKIN_COUNT; i++) {
    if (SKIN_UNLOCK_LEVEL[i] == lvl) {
      unlockedItemName = "New Skin: " + SKIN_NAMES[i];
      return;
    }
  }
  for (int i = 0; i < DECORATION_COUNT; i++) {
    if (DECORATION_UNLOCK_LEVEL[i] == lvl) {
      unlockedItemName = "New Title: " + DECORATION_NAMES[i];
      return;
    }
  }
}

void saveProgress() {
  String[] lines = {
    GAME_VERSION,
    str(playerXP),
    str(playerLevel),
    str(currentSkin),
    str(ballSpeedSetting),
    str(currentDecoration)
  };
  saveStrings("pongi_save.txt", lines);
}

void loadProgress() {
  try {
    String[] lines = loadStrings("pongi_save.txt");
    if (lines != null && lines.length >= 6 && lines[0].equals(GAME_VERSION)) {
      playerXP = int(lines[1]);
      playerLevel = int(lines[2]);
      currentSkin = constrain(int(lines[3]), 0, SKIN_COUNT - 1);
      ballSpeedSetting = constrain(int(lines[4]), 0, 2);
      currentDecoration = constrain(int(lines[5]), 0, DECORATION_COUNT - 1);
      xpToNext = calcXPtoNext(playerLevel);
      if (SKIN_UNLOCK_LEVEL[currentSkin] > playerLevel) currentSkin = 0;
      if (DECORATION_UNLOCK_LEVEL[currentDecoration] > playerLevel) currentDecoration = 0;
    } else {
      // Version mismatch or old save — reset all stats for v0.2.0
      playerXP = 0;
      playerLevel = 1;
      currentSkin = 0;
      currentDecoration = 0;
      ballSpeedSetting = 1;
      xpToNext = calcXPtoNext(1);
      saveProgress();
    }
  } catch (Exception e) {
    saveProgress();
  }
}

// ===================== BALL =====================
float ballX, ballY;
float ballDX, ballDY;
float ballSize = 16;
float ballBaseSpeed;
float ballSpeed;
int rallyCount = 0;
boolean ballOnFire = false;
int fireThreshold = 10;
float ballCurve = 0;

float[] trailX = new float[15];
float[] trailY = new float[15];
int trailIdx = 0;

// ===================== PADDLES =====================
float paddleW = 14;
float basePaddleH = 90;
float paddle1H, paddle2H;
float paddle1Y, paddle2Y;
float basePaddleSpeed = 8;
float paddle1Speed, paddle2Speed;

boolean wPressed, sPressed, upPressed, downPressed;

int score1 = 0, score2 = 0;
String winner = "";

// ===================== ABILITIES STATE =====================
int p1Ability = -1, p2Ability = -1;
float p1Cooldown = 0, p2Cooldown = 0;
float p1ActiveTimer = 0, p2ActiveTimer = 0;
boolean p1Shield = false, p2Shield = false;
int abilityMenuSelection = 0;
float botAbilityTimer = 0;

// ===================== BOT =====================
float botTargetY;
float botReactionTimer = 0;
float botMistakeOffset = 0;

// ===================== PARTICLES =====================
int MAX_PARTICLES = 300;
float[] ppx = new float[300], ppy = new float[300];
float[] pvx = new float[300], pvy = new float[300];
float[] pLife = new float[300];
int[] prr = new int[300], pgg = new int[300], pbb = new int[300];
int particleCount = 0;

float shakeAmount = 0;
float flashAlpha = 0;
int flashR = 255, flashG = 255, flashB = 255;

// ===================== MENU =====================
float menuBallX, menuBallY, menuBallDX, menuBallDY;
int menuHover = 0;
float menuAnimT = 0;

// ===================== TRANSITION =====================
float transAlpha = 0;
int transTarget = -1;
boolean transOut = false;

// ===================== SETUP =====================
void setup() {
  size(900, 550);
  textAlign(CENTER, CENTER);
  initSkins();
  initCatColors();
  loadProgress();
  ballBaseSpeed = BALL_SPEEDS[ballSpeedSetting];
  menuBallX = width / 2;
  menuBallY = height / 2;
  menuBallDX = 3;
  menuBallDY = 2;
  resetGame();
}

void resetGame() {
  score1 = 0;
  score2 = 0;
  xpAwarded = false;
  ballBaseSpeed = BALL_SPEEDS[ballSpeedSetting];
  ballSpeed = ballBaseSpeed;
  rallyCount = 0;
  ballOnFire = false;
  ballCurve = 0;
  paddle1H = basePaddleH;
  paddle2H = basePaddleH;
  paddle1Speed = basePaddleSpeed;
  paddle2Speed = basePaddleSpeed;
  paddle1Y = height / 2 - paddle1H / 2;
  paddle2Y = height / 2 - paddle2H / 2;
  p1Cooldown = 0;
  p2Cooldown = 0;
  p1ActiveTimer = 0;
  p2ActiveTimer = 0;
  p1Shield = false;
  p2Shield = false;
  shakeAmount = 0;
  botTargetY = height / 2;
  botReactionTimer = 0;
  botMistakeOffset = 0;
  botAbilityTimer = 0;
  resetBall();
}

void resetBall() {
  ballX = width / 2;
  ballY = height / 2;
  float angle = random(-PI / 4, PI / 4);
  float dir = random(1) > 0.5 ? 1 : -1;
  ballDX = cos(angle) * ballSpeed * dir;
  ballDY = sin(angle) * ballSpeed;
  rallyCount = 0;
  ballOnFire = false;
  ballCurve = 0;
  for (int i = 0; i < trailX.length; i++) {
    trailX[i] = ballX;
    trailY[i] = ballY;
  }
}

// ===================== MAIN DRAW =====================
void draw() {
  float dt = 1.0 / 60.0;
  menuAnimT += dt;

  if (showLevelUp) {
    levelUpTimer -= dt;
    levelUpAnimFrame++;
    if (levelUpTimer <= 0) showLevelUp = false;
  }

  if (gameState == STATE_PLAY) {
    if (p1Cooldown > 0) p1Cooldown -= dt;
    if (p2Cooldown > 0) p2Cooldown -= dt;
    if (p1ActiveTimer > 0) { p1ActiveTimer -= dt; if (p1ActiveTimer <= 0) endAbility(1); }
    if (p2ActiveTimer > 0) { p2ActiveTimer -= dt; if (p2ActiveTimer <= 0) endAbility(2); }
  }

  float sx = 0, sy = 0;
  if (shakeAmount > 0.5) {
    sx = random(-shakeAmount, shakeAmount);
    sy = random(-shakeAmount, shakeAmount);
    shakeAmount *= 0.85;
  } else {
    shakeAmount = 0;
  }

  pushMatrix();
  translate(sx, sy);

  switch (gameState) {
    case STATE_MENU:       drawMainMenu(); break;
    case STATE_MODE:       drawModeSelect(); break;
    case STATE_DIFFICULTY: drawDifficultySelect(); break;
    case STATE_SKINS:      drawSkinsMenu(); break;
    case STATE_SETTINGS:   drawSettingsMenu(); break;
    case STATE_SELECT_P1:  drawAbilitySelect(1); break;
    case STATE_SELECT_P2:  drawAbilitySelect(2); break;
    case STATE_PLAY:       updateGame(); drawGame(); break;
    case STATE_GAMEOVER:   drawGameOverScreen(); break;
    case STATE_LEVELUP:    drawLevelUpScreen(); break;
    case STATE_PAUSE:      drawGame(); drawPauseMenu(); break;
  }

  popMatrix();

  if (showLevelUp && gameState != STATE_LEVELUP) {
    drawLevelUpOverlay();
  }

  if (flashAlpha > 1) {
    noStroke();
    fill(flashR, flashG, flashB, flashAlpha);
    rect(0, 0, width, height);
    flashAlpha *= 0.85;
  }

  if (transAlpha > 0 || transOut) {
    updateTransition();
  }
}

// ===================== TRANSITION =====================
void startTransition(int target) {
  transTarget = target;
  transOut = true;
  transAlpha = 0;
}

void updateTransition() {
  noStroke();
  if (transOut) {
    transAlpha += 12;
    if (transAlpha >= 255) {
      transAlpha = 255;
      transOut = false;
      gameState = transTarget;
      transTarget = -1;
    }
  } else {
    transAlpha -= 12;
    if (transAlpha <= 0) transAlpha = 0;
  }
  fill(0, transAlpha);
  rect(0, 0, width, height);
}

// ===================== MAIN MENU =====================
void drawMainMenu() {
  int[] bg = skinBG[currentSkin];
  background(bg[0], bg[1], bg[2]);

  if (currentSkin == 0 || currentSkin == 2) drawStarfield();
  if (currentSkin == 1) drawNeonGrid();
  if (currentSkin == 3) drawRetroScanlines();

  menuBallX += menuBallDX;
  menuBallY += menuBallDY;
  if (menuBallX < 30 || menuBallX > width - 30) menuBallDX *= -1;
  if (menuBallY < 30 || menuBallY > height - 30) menuBallDY *= -1;

  int[] acc = skinAccent[currentSkin];
  fill(acc[0], acc[1], acc[2]);
  textSize(64);
  text("PONGI", width / 2, 80);

  int[] fl = skinField[currentSkin];
  fill(min(fl[0] + 80, 255), min(fl[1] + 80, 255), min(fl[2] + 80, 255));
  textSize(18);
  text("Modern Arcade Pong", width / 2, 125);

  float t = millis() / 1000.0;
  int[] c1 = skinP1[currentSkin];
  int[] c2 = skinP2[currentSkin];
  noStroke();
  fill(c1[0], c1[1], c1[2]);
  rect(width / 2 - 200, 160 + sin(t * 2) * 12, 12, 60, 4);
  fill(c2[0], c2[1], c2[2]);
  rect(width / 2 + 188, 160 + sin(t * 2 + PI) * 12, 12, 60, 4);

  int[] bc = skinBall[currentSkin];
  fill(bc[0], bc[1], bc[2]);
  ellipse(menuBallX, min(menuBallY, 220), 14, 14);

  drawXPBar(width / 2 - 150, 245, 300, 20);

  float btnY = 290;
  float btnH = 42;
  float btnGap = 8;
  String[] labels = {"PLAY", "SKINS", "SETTINGS", "EXIT"};

  for (int i = 0; i < 4; i++) {
    float by = btnY + i * (btnH + btnGap);
    boolean hovered = (menuHover == i);

    noStroke();
    if (hovered) {
      fill(acc[0], acc[1], acc[2], 40);
      rect(width / 2 - 130, by, 260, btnH, 8);
      stroke(acc[0], acc[1], acc[2]);
      strokeWeight(2);
      noFill();
      rect(width / 2 - 130, by, 260, btnH, 8);
      noStroke();
      fill(255);
    } else {
      fill(40, 40, 60, currentSkin == 4 ? 100 : 180);
      rect(width / 2 - 130, by, 260, btnH, 8);
      fill(180);
    }
    textSize(22);
    text(labels[i], width / 2, by + btnH / 2 - 2);
  }

  fill(currentSkin == 4 ? 120 : 100);
  textSize(13);
  text("UP/DOWN = navigate | ENTER = select", width / 2, height - 25);
}

// ===================== XP BAR =====================
void drawXPBar(float x, float y, float w, float h) {
  noStroke();
  fill(30, 30, 50, 200);
  rect(x, y, w, h, h / 2);

  float pct = (float) playerXP / xpToNext;
  int[] acc = skinAccent[currentSkin];
  fill(acc[0], acc[1], acc[2], 180);
  rect(x + 2, y + 2, max(0, (w - 4) * pct), h - 4, h / 2);

  fill(255);
  textSize(12);
  text("Lv." + playerLevel + " [" + DECORATION_NAMES[currentDecoration] + "]  " + playerXP + "/" + xpToNext + " XP", x + w / 2, y + h / 2 - 1);
}

// ===================== MODE SELECT =====================
void drawModeSelect() {
  int[] bg = skinBG[currentSkin];
  background(bg[0], bg[1], bg[2]);
  if (currentSkin == 0 || currentSkin == 2) drawStarfield();
  if (currentSkin == 1) drawNeonGrid();

  int[] acc = skinAccent[currentSkin];
  fill(acc[0], acc[1], acc[2]);
  textSize(40);
  text("SELECT MODE", width / 2, 80);

  String[] modes = {"1 PLAYER (vs Bot)", "2 PLAYERS (Local)"};
  String[] descs = {"Play against AI with adjustable difficulty", "Two players on the same keyboard"};
  for (int i = 0; i < 2; i++) {
    float by = 180 + i * 120;
    boolean hovered = (menuHover == i);

    noStroke();
    if (hovered) {
      fill(acc[0], acc[1], acc[2], 40);
      rect(width / 2 - 200, by, 400, 80, 10);
      stroke(acc[0], acc[1], acc[2]);
      strokeWeight(2);
      noFill();
      rect(width / 2 - 200, by, 400, 80, 10);
      noStroke();
      fill(255);
    } else {
      fill(40, 40, 60, 180);
      rect(width / 2 - 200, by, 400, 80, 10);
      fill(180);
    }
    textSize(26);
    text(modes[i], width / 2, by + 28);
    fill(hovered ? 200 : 120);
    textSize(14);
    text(descs[i], width / 2, by + 55);
  }

  fill(100);
  textSize(14);
  text("ESC = Back", width / 2, height - 30);
}

// ===================== DIFFICULTY SELECT =====================
void drawDifficultySelect() {
  int[] bg = skinBG[currentSkin];
  background(bg[0], bg[1], bg[2]);
  if (currentSkin == 0 || currentSkin == 2) drawStarfield();
  if (currentSkin == 1) drawNeonGrid();

  int[] acc = skinAccent[currentSkin];
  fill(acc[0], acc[1], acc[2]);
  textSize(40);
  text("DIFFICULTY", width / 2, 80);

  String[] diffs = {"EASY", "MEDIUM", "HARD"};
  String[] descs = {"Bot is slow and makes mistakes", "Balanced bot speed and accuracy", "Bot reacts fast, plays aggressively"};
  int[][] diffColors = {{80, 220, 80}, {255, 200, 60}, {255, 60, 60}};

  for (int i = 0; i < 3; i++) {
    float by = 150 + i * 110;
    boolean hovered = (menuHover == i);

    noStroke();
    if (hovered) {
      fill(diffColors[i][0], diffColors[i][1], diffColors[i][2], 40);
      rect(width / 2 - 200, by, 400, 75, 10);
      stroke(diffColors[i][0], diffColors[i][1], diffColors[i][2]);
      strokeWeight(2);
      noFill();
      rect(width / 2 - 200, by, 400, 75, 10);
      noStroke();
      fill(255);
    } else {
      fill(40, 40, 60, 180);
      rect(width / 2 - 200, by, 400, 75, 10);
      fill(180);
    }
    textSize(26);
    text(diffs[i], width / 2, by + 24);
    fill(hovered ? 200 : 120);
    textSize(14);
    text(descs[i], width / 2, by + 52);
  }

  fill(100);
  textSize(14);
  text("ESC = Back", width / 2, height - 30);
}

// ===================== SKINS MENU =====================
void drawSkinsMenu() {
  int[] bg = skinBG[currentSkin];
  background(bg[0], bg[1], bg[2]);

  int[] acc = skinAccent[currentSkin];
  fill(acc[0], acc[1], acc[2]);
  textSize(36);
  text("CUSTOMIZE", width / 2, 46);

  // Tab buttons
  String[] tabs = {"SKINS", "DECORATIONS"};
  for (int t = 0; t < 2; t++) {
    float tx = (t == 0) ? width / 2 - 178 : width / 2 + 18;
    float tw = 160;
    float tabY = 74;
    float th = 34;
    boolean activeTab = (skinsMenuTab == t);
    noStroke();
    if (activeTab) {
      fill(acc[0], acc[1], acc[2], 60);
      rect(tx, tabY, tw, th, 8);
      stroke(acc[0], acc[1], acc[2]);
      strokeWeight(2);
      noFill();
      rect(tx, tabY, tw, th, 8);
      noStroke();
      fill(255);
    } else {
      fill(40, 40, 60, 180);
      rect(tx, tabY, tw, th, 8);
      fill(150);
    }
    textSize(16);
    text(tabs[t], tx + tw / 2, tabY + th / 2 - 1);
  }

  if (skinsMenuTab == 0) {
    // --- SKINS TAB ---
    for (int i = 0; i < SKIN_COUNT; i++) {
      float bx = 80 + i * 155;
      float by = 122;
      float bw = 140;
      float bh = 278;
      boolean selected = (currentSkin == i);
      boolean hovered = (menuHover == i);
      boolean unlocked = (SKIN_UNLOCK_LEVEL[i] <= playerLevel);

      noStroke();
      fill(unlocked ? skinBG[i][0] : 28, unlocked ? skinBG[i][1] : 28, unlocked ? skinBG[i][2] : 38);
      rect(bx, by, bw, bh, 10);

      if (unlocked) {
        fill(skinP1[i][0], skinP1[i][1], skinP1[i][2]);
        rect(bx + 15, by + bh / 2 - 25, 8, 50, 3);
        fill(skinP2[i][0], skinP2[i][1], skinP2[i][2]);
        rect(bx + bw - 23, by + bh / 2 - 25, 8, 50, 3);
        fill(skinBall[i][0], skinBall[i][1], skinBall[i][2]);
        ellipse(bx + bw / 2, by + bh / 2, 10, 10);
        stroke(skinField[i][0], skinField[i][1], skinField[i][2]);
        strokeWeight(1);
        for (int sy = (int)(by + 10); sy < by + bh - 10; sy += 12) {
          line(bx + bw / 2, sy, bx + bw / 2, sy + 6);
        }
      } else {
        fill(80, 80, 100);
        textSize(26);
        text("LOCK", bx + bw / 2, by + bh / 2 - 10);
        fill(140, 100, 100);
        textSize(14);
        text("Lv." + SKIN_UNLOCK_LEVEL[i], bx + bw / 2, by + bh / 2 + 18);
      }

      if (unlocked && selected) {
        stroke(skinAccent[i][0], skinAccent[i][1], skinAccent[i][2]);
        strokeWeight(3);
        noFill();
        rect(bx, by, bw, bh, 10);
      } else if (hovered) {
        stroke(unlocked ? 180 : 100);
        strokeWeight(2);
        noFill();
        rect(bx, by, bw, bh, 10);
      }

      noStroke();
      fill((hovered || selected) ? (unlocked ? 255 : 160) : 150);
      textSize(15);
      text(SKIN_NAMES[i], bx + bw / 2, by + bh + 20);

      if (!unlocked) {
        fill(200, 80, 80);
        textSize(11);
        text("LOCKED", bx + bw / 2, by + bh + 38);
      } else if (selected) {
        fill(skinAccent[i][0], skinAccent[i][1], skinAccent[i][2]);
        textSize(11);
        text("ACTIVE", bx + bw / 2, by + bh + 38);
      } else {
        fill(80, 200, 80);
        textSize(11);
        text(SKIN_UNLOCK_LEVEL[i] == 1 ? "Default" : "Lv." + SKIN_UNLOCK_LEVEL[i], bx + bw / 2, by + bh + 38);
      }
    }
  } else {
    // --- DECORATIONS TAB ---
    for (int i = 0; i < DECORATION_COUNT; i++) {
      float decX = width / 2 - 200;
      float decY = 122 + i * 62;
      float decW = 400;
      float decH = 52;
      boolean selected = (currentDecoration == i);
      boolean hovered = (menuHover == i);
      boolean unlocked = (DECORATION_UNLOCK_LEVEL[i] <= playerLevel);

      noStroke();
      if (selected && unlocked) {
        fill(acc[0], acc[1], acc[2], 40);
        rect(decX, decY, decW, decH, 10);
        stroke(acc[0], acc[1], acc[2]);
        strokeWeight(2);
        noFill();
        rect(decX, decY, decW, decH, 10);
        noStroke();
      } else if (hovered) {
        fill(60, 60, 80, 180);
        rect(decX, decY, decW, decH, 10);
      } else {
        fill(40, 40, 60, unlocked ? 180 : 90);
        rect(decX, decY, decW, decH, 10);
      }

      fill(unlocked ? acc[0] : 60, unlocked ? acc[1] : 60, unlocked ? acc[2] : 60);
      rect(decX + 10, decY + 8, 36, 36, 6);
      fill(unlocked ? 255 : 120);
      textSize(18);
      text(DECORATION_NAMES[i].charAt(0), decX + 28, decY + 24);

      textAlign(LEFT, CENTER);
      fill(unlocked ? ((hovered || selected) ? 255 : 200) : 100);
      textSize(18);
      text(DECORATION_NAMES[i], decX + 56, decY + 16);

      if (!unlocked) {
        fill(180, 80, 80);
        textSize(12);
        text("Unlock at Level " + DECORATION_UNLOCK_LEVEL[i], decX + 56, decY + 35);
      } else if (selected) {
        fill(acc[0], acc[1], acc[2]);
        textSize(12);
        text("ACTIVE TITLE", decX + 56, decY + 35);
      } else {
        fill(80, 200, 80);
        textSize(12);
        text("Lv." + DECORATION_UNLOCK_LEVEL[i] + (DECORATION_UNLOCK_LEVEL[i] == 1 ? " \u2014 Default" : " \u2014 Unlocked"), decX + 56, decY + 35);
      }

      textAlign(RIGHT, CENTER);
      if (!unlocked) {
        fill(100);
        textSize(13);
        text("LOCKED", decX + decW - 10, decY + decH / 2);
      } else if (selected) {
        fill(acc[0], acc[1], acc[2]);
        textSize(13);
        text("ACTIVE", decX + decW - 10, decY + decH / 2);
      }
      textAlign(CENTER, CENTER);
    }
  }

  fill(100);
  textSize(12);
  text("Q/E = Switch Tab  |  LEFT/RIGHT or UP/DOWN = Browse  |  ENTER = Select  |  ESC = Back", width / 2, height - 16);
}

// ===================== SETTINGS MENU =====================
void drawSettingsMenu() {
  int[] bg = skinBG[currentSkin];
  background(bg[0], bg[1], bg[2]);
  if (currentSkin == 0 || currentSkin == 2) drawStarfield();
  if (currentSkin == 1) drawNeonGrid();

  int[] acc = skinAccent[currentSkin];
  fill(acc[0], acc[1], acc[2]);
  textSize(40);
  text("SETTINGS", width / 2, 80);

  fill(255);
  textSize(22);
  text("BALL SPEED", width / 2, 180);

  for (int i = 0; i < 3; i++) {
    float bx = width / 2 - 180 + i * 130;
    float by = 210;
    boolean selected = (ballSpeedSetting == i);
    boolean hovered = (menuHover == i);

    noStroke();
    if (selected) {
      fill(acc[0], acc[1], acc[2], 60);
      rect(bx, by, 110, 45, 8);
      stroke(acc[0], acc[1], acc[2]);
      strokeWeight(2);
      noFill();
      rect(bx, by, 110, 45, 8);
      noStroke();
    } else if (hovered) {
      fill(60, 60, 80, 180);
      rect(bx, by, 110, 45, 8);
    } else {
      fill(40, 40, 60, 180);
      rect(bx, by, 110, 45, 8);
    }
    fill(selected ? 255 : (hovered ? 220 : 150));
    textSize(18);
    text(SPEED_NAMES[i], bx + 55, by + 20);
  }

  fill(255);
  textSize(22);
  text("WIN SCORE", width / 2, 310);

  noStroke();
  fill(40, 40, 60, 180);
  rect(width / 2 - 80, 340, 160, 50, 8);
  fill(acc[0], acc[1], acc[2]);
  textSize(14);
  text("<", width / 2 - 55, 363);
  text(">", width / 2 + 55, 363);
  fill(255);
  textSize(32);
  text(winScore, width / 2, 362);

  fill(150);
  textSize(14);
  text("LEFT/RIGHT to change", width / 2, 405);

  fill(100);
  textSize(14);
  text("1/2/3 = set speed | ESC = Back", width / 2, height - 30);
}

// ===================== ABILITY SELECT =====================
void drawAbilitySelect(int player) {
  int[] bg = skinBG[currentSkin];
  background(bg[0], bg[1], bg[2]);
  if (currentSkin == 0 || currentSkin == 2) drawStarfield();
  if (currentSkin == 1) drawNeonGrid();

  int[] pc = (player == 1) ? skinP1[currentSkin] : skinP2[currentSkin];
  fill(pc[0], pc[1], pc[2]);
  textSize(32);
  String title = (player == 1) ? "PLAYER 1 — CHOOSE ABILITY" : "PLAYER 2 — CHOOSE ABILITY";
  text(title, width / 2, 40);

  int[] acc = skinAccent[currentSkin];
  fill(min(acc[0]+80,255), min(acc[1]+80,255), min(acc[2]+80,255));
  textSize(13);
  text("UP/DOWN to navigate | ENTER to confirm | ESC = back", width / 2, 70);

  for (int i = 0; i < AB_COUNT; i++) {
    int col2 = i / 4;
    int row = i % 4;
    float cx = width / 2 - 210 + col2 * 420;
    float cy = 100 + row * 100;
    boolean selected = (abilityMenuSelection == i);
    int[] abCol = getAbilityColor(i);

    noStroke();
    if (selected) {
      fill(abCol[0], abCol[1], abCol[2], 50);
      rect(cx - 190, cy, 380, 80, 10);
      stroke(abCol[0], abCol[1], abCol[2]);
      strokeWeight(2);
      noFill();
      rect(cx - 190, cy, 380, 80, 10);
      noStroke();
    } else {
      fill(40, 40, 60, 180);
      rect(cx - 190, cy, 380, 80, 10);
    }

    fill(selected ? abCol[0] : 60, selected ? abCol[1] : 60, selected ? abCol[2] : 60);
    rect(cx - 178, cy + 12, 50, 50, 6);
    fill(255);
    textSize(24);
    textAlign(CENTER, CENTER);
    text(AB_NAMES[i].charAt(0), cx - 153, cy + 35);

    textAlign(LEFT, CENTER);
    fill(selected ? 255 : 180);
    textSize(20);
    text(AB_NAMES[i], cx - 118, cy + 25);
    fill(selected ? 200 : 120);
    textSize(13);
    text(AB_DESC[i] + "  |  CD: " + (int)AB_COOLDOWN[i] + "s", cx - 118, cy + 48);

    textAlign(RIGHT, CENTER);
    fill(abCol[0], abCol[1], abCol[2], selected ? 255 : 150);
    textSize(12);
    text(AB_CATEGORY[i], cx + 178, cy + 25);
    textAlign(CENTER, CENTER);
  }

  int[] selCol = getAbilityColor(abilityMenuSelection);
  fill(selCol[0], selCol[1], selCol[2]);
  textSize(16);
  text(">> " + AB_NAMES[abilityMenuSelection] + " <<", width / 2, height - 20);
}

// ===================== GAME =====================
void updateGame() {
  movePaddles();
  if (gameMode == 1) {
    updateBot();
    updateBotAbility();
  }
  moveBall();
  checkCollisions();
  updateParticles2();
}

void drawGame() {
  int[] bg = skinBG[currentSkin];
  background(bg[0], bg[1], bg[2]);

  if (currentSkin == 1) drawNeonGrid();
  if (currentSkin == 2) drawStarfield();
  if (currentSkin == 3) drawRetroScanlines();

  drawField();
  drawTrail();
  drawBall();
  drawPaddles();
  drawParticles2();
  drawScoreHUD();
  drawAbilityHUD();
}

void drawField() {
  int[] fl = skinField[currentSkin];
  stroke(fl[0], fl[1], fl[2]);
  strokeWeight(2);
  for (int y = 10; y < height - 10; y += 24) {
    line(width / 2, y, width / 2, y + 12);
  }
  if (rallyCount >= fireThreshold) {
    noFill();
    int[] acc = skinAccent[currentSkin];
    stroke(acc[0], acc[1], acc[2], (int)(30 + sin(millis() / 200.0) * 20));
    strokeWeight(4);
    rect(10, 10, width - 20, height - 20, 8);
  }
}

void drawBall() {
  noStroke();
  int[] bc = skinBall[currentSkin];
  if (ballOnFire) {
    fill(255, 80, 0, 40);
    ellipse(ballX, ballY, ballSize * 3, ballSize * 3);
    fill(255, 150, 0, 80);
    ellipse(ballX, ballY, ballSize * 2, ballSize * 2);
    fill(255, 200, 50);
  } else {
    fill(bc[0], bc[1], bc[2], 30);
    ellipse(ballX, ballY, ballSize * 2.5, ballSize * 2.5);
    fill(bc[0], bc[1], bc[2]);
  }
  ellipse(ballX, ballY, ballSize, ballSize);
}

void drawTrail() {
  noStroke();
  int[] bc = skinBall[currentSkin];
  for (int i = 0; i < trailX.length; i++) {
    int idx2 = (trailIdx - i + trailX.length) % trailX.length;
    float a = map(i, 0, trailX.length, 180, 0);
    if (ballOnFire) {
      fill(255, 100 + random(80), 0, a);
    } else {
      fill(bc[0], bc[1], bc[2], a * 0.4);
    }
    float s = map(i, 0, trailX.length, ballSize * 0.9, 2);
    ellipse(trailX[idx2], trailY[idx2], s, s);
  }
}

void drawPaddles() {
  noStroke();

  int[] c1 = skinP1[currentSkin];
  if (p1ActiveTimer > 0) {
    c1 = getAbilityColor(p1Ability);
  }
  fill(c1[0], c1[1], c1[2], 30);
  rect(16, paddle1Y - 4, paddleW + 8, paddle1H + 8, 6);
  fill(c1[0], c1[1], c1[2]);
  rect(20, paddle1Y, paddleW, paddle1H, 4);

  if (p1Shield) {
    stroke(80, 255, 255, 150);
    strokeWeight(3);
    noFill();
    arc(20 + paddleW / 2, paddle1Y + paddle1H / 2, paddle1H + 20, paddle1H + 20, -PI / 2, PI / 2);
    noStroke();
  }

  int[] c2 = skinP2[currentSkin];
  if (p2ActiveTimer > 0) {
    c2 = getAbilityColor(p2Ability);
  }
  float rpx = width - 20 - paddleW;
  fill(c2[0], c2[1], c2[2], 30);
  rect(rpx - 4, paddle2Y - 4, paddleW + 8, paddle2H + 8, 6);
  fill(c2[0], c2[1], c2[2]);
  rect(rpx, paddle2Y, paddleW, paddle2H, 4);

  if (p2Shield) {
    stroke(80, 255, 255, 150);
    strokeWeight(3);
    noFill();
    arc(rpx + paddleW / 2, paddle2Y + paddle2H / 2, paddle2H + 20, paddle2H + 20, PI / 2, 3 * PI / 2);
    noStroke();
  }
}

// ===================== SCORE HUD =====================
void drawScoreHUD() {
  int[] c1 = skinP1[currentSkin];
  int[] c2 = skinP2[currentSkin];

  textAlign(CENTER, TOP);
  fill(c1[0], c1[1], c1[2]);
  textSize(52);
  text(score1, width / 2 - 70, 12);
  fill(c2[0], c2[1], c2[2]);
  text(score2, width / 2 + 70, 12);

  fill(120);
  textSize(30);
  text("-", width / 2, 22);

  if (rallyCount > 2) {
    int[] acc = skinAccent[currentSkin];
    if (ballOnFire) {
      fill(255, 150, 50);
    } else {
      fill(acc[0], acc[1], acc[2]);
    }
    textSize(16);
    text("Rally: " + rallyCount, width / 2, 70);
  }

  textAlign(CENTER, CENTER);
}

// ===================== ABILITY HUD =====================
void drawAbilityHUD() {
  drawAbilityHUDSingle(1, p1Ability, p1Cooldown, p1ActiveTimer, 10, height - 52);
  drawAbilityHUDSingle(2, p2Ability, p2Cooldown, p2ActiveTimer, width - 210, height - 52);
}

void drawAbilityHUDSingle(int player, int ability, float cd, float active, float hx, float hy) {
  if (ability < 0) return;

  noStroke();
  fill(20, 20, 40, 200);
  rect(hx, hy, 200, 42, 6);

  int[] ac = getAbilityColor(ability);
  if (cd > 0) {
    fill(60, 60, 60);
  } else if (active > 0) {
    float pulse = 0.7 + 0.3 * sin(millis() / 150.0);
    fill((int)(ac[0] * pulse), (int)(ac[1] * pulse), (int)(ac[2] * pulse));
  } else {
    fill(ac[0], ac[1], ac[2], 150);
  }
  rect(hx + 4, hy + 4, 34, 34, 4);

  fill(255);
  textSize(18);
  textAlign(CENTER, CENTER);
  text(AB_NAMES[ability].charAt(0), hx + 21, hy + 19);

  textAlign(LEFT, CENTER);
  fill(cd > 0 ? 120 : 255);
  textSize(14);
  text(AB_NAMES[ability], hx + 44, hy + 12);

  float barW = 148;
  noStroke();
  fill(40);
  rect(hx + 44, hy + 26, barW, 8, 3);

  if (cd > 0) {
    float pct = cd / AB_COOLDOWN[ability];
    fill(100, 100, 100);
    rect(hx + 44, hy + 26, barW * (1 - pct), 8, 3);
    fill(160);
    textSize(11);
    textAlign(RIGHT, CENTER);
    text(nf(cd, 1, 1) + "s", hx + 44 + barW - 2, hy + 29);
  } else if (active > 0) {
    float pct = active / AB_DURATION[ability];
    fill(ac[0], ac[1], ac[2]);
    rect(hx + 44, hy + 26, barW * pct, 8, 3);
    fill(255);
    textSize(11);
    textAlign(LEFT, CENTER);
    text("ACTIVE", hx + 46, hy + 29);
  } else {
    fill(80, 255, 80);
    rect(hx + 44, hy + 26, barW, 8, 3);
    fill(0);
    textSize(11);
    textAlign(CENTER, CENTER);
    String keyLabel = (player == 1) ? "[X] READY" : (gameMode == 1 ? "BOT" : "[M] READY");
    text(keyLabel, hx + 44 + barW / 2, hy + 29);
  }

  textAlign(CENTER, CENTER);
}

// ===================== BALL MOVEMENT =====================
void moveBall() {
  ballDY += ballCurve;
  ballCurve *= 0.97;

  ballX += ballDX;
  ballY += ballDY;

  trailIdx = (trailIdx + 1) % trailX.length;
  trailX[trailIdx] = ballX;
  trailY[trailIdx] = ballY;

  int[] fl = skinField[currentSkin];
  if (ballY - ballSize / 2 <= 0) {
    ballDY = abs(ballDY);
    spawnParticles2(ballX, 0, 6, min(fl[0]+80,255), min(fl[1]+80,255), min(fl[2]+80,255));
  }
  if (ballY + ballSize / 2 >= height) {
    ballDY = -abs(ballDY);
    spawnParticles2(ballX, height, 6, min(fl[0]+80,255), min(fl[1]+80,255), min(fl[2]+80,255));
  }

  int[] c2c = skinP2[currentSkin];
  int[] c1c = skinP1[currentSkin];

  if (ballX - ballSize / 2 <= 0) {
    if (p1Shield) {
      p1Shield = false;
      ballDX = abs(ballDX);
      shakeAmount = 10;
      spawnParticles2(ballX, ballY, 20, 80, 255, 255);
      flashScreen(80, 255, 255, 60);
    } else {
      score2++;
      shakeAmount = 15;
      spawnParticles2(ballX, ballY, 30, c2c[0], c2c[1], c2c[2]);
      flashScreen(c2c[0], c2c[1], c2c[2], 80);
      checkWin();
      if (gameState == STATE_PLAY) resetBall();
    }
  }

  if (ballX + ballSize / 2 >= width) {
    if (p2Shield) {
      p2Shield = false;
      ballDX = -abs(ballDX);
      shakeAmount = 10;
      spawnParticles2(ballX, ballY, 20, 80, 255, 255);
      flashScreen(80, 255, 255, 60);
    } else {
      score1++;
      shakeAmount = 15;
      spawnParticles2(ballX, ballY, 30, c1c[0], c1c[1], c1c[2]);
      flashScreen(c1c[0], c1c[1], c1c[2], 80);
      checkWin();
      if (gameState == STATE_PLAY) resetBall();
    }
  }
}

// ===================== PADDLES MOVEMENT =====================
void movePaddles() {
  if (wPressed && paddle1Y > 0) paddle1Y -= paddle1Speed;
  if (sPressed && paddle1Y + paddle1H < height) paddle1Y += paddle1Speed;

  if (gameMode == 2) {
    if (upPressed && paddle2Y > 0) paddle2Y -= paddle2Speed;
    if (downPressed && paddle2Y + paddle2H < height) paddle2Y += paddle2Speed;
  }
}

// ===================== BOT AI =====================
void updateBot() {
  float dt = 1.0 / 60.0;
  botReactionTimer -= dt;

  float botSpeed, reactionDelay, mistakeRange, trackingError;

  if (difficulty == 0) {
    botSpeed = 3.5;
    reactionDelay = 0.4;
    mistakeRange = 80;
    trackingError = 50;
  } else if (difficulty == 1) {
    botSpeed = 5.5;
    reactionDelay = 0.15;
    mistakeRange = 30;
    trackingError = 20;
  } else {
    botSpeed = 7.5;
    reactionDelay = 0.05;
    mistakeRange = 8;
    trackingError = 5;
  }

  if (botReactionTimer <= 0) {
    botReactionTimer = reactionDelay;
    botMistakeOffset = random(-mistakeRange, mistakeRange);

    if (ballDX > 0) {
      float timeToReach = (width - 20 - paddleW - ballX) / max(abs(ballDX), 0.1);
      float predictedY = ballY + ballDY * timeToReach;
      while (predictedY < 0 || predictedY > height) {
        if (predictedY < 0) predictedY = -predictedY;
        if (predictedY > height) predictedY = 2 * height - predictedY;
      }
      botTargetY = predictedY + botMistakeOffset;
    } else {
      botTargetY = height / 2 + botMistakeOffset * 0.5;
    }
    botTargetY += random(-trackingError, trackingError);
  }

  float paddleCenter = paddle2Y + paddle2H / 2;
  float diff2 = botTargetY - paddleCenter;
  float moveAmount = min(abs(diff2), botSpeed);
  if (diff2 > 2) {
    paddle2Y += moveAmount;
  } else if (diff2 < -2) {
    paddle2Y -= moveAmount;
  }
  paddle2Y = constrain(paddle2Y, 0, height - paddle2H);
}

// ===================== BOT ABILITY AI =====================
void updateBotAbility() {
  if (p2Ability < 0 || p2Cooldown > 0) return;

  float dt = 1.0 / 60.0;
  botAbilityTimer -= dt;
  if (botAbilityTimer > 0) return;

  float baseDelay;
  float useChance;
  if (difficulty == 0) { baseDelay = 3.0; useChance = 0.3; }
  else if (difficulty == 1) { baseDelay = 1.5; useChance = 0.6; }
  else { baseDelay = 0.5; useChance = 0.9; }

  botAbilityTimer = baseDelay + random(0.5);

  if (random(1) > useChance) return;

  boolean shouldUse = false;
  float paddleCenter = paddle2Y + paddle2H / 2;
  float distToBall = abs(ballY - paddleCenter);

  switch (p2Ability) {
    case AB_SHIELD:
      shouldUse = !p2Shield && ballDX > 0 && distToBall > paddle2H * 0.8;
      break;
    case AB_GROW:
      shouldUse = ballDX > 0;
      break;
    case AB_SLOW:
      shouldUse = ballDX > 0 && sqrt(ballDX * ballDX + ballDY * ballDY) > ballBaseSpeed * 1.3;
      break;
    case AB_POWER:
      shouldUse = ballDX < 0;
      break;
    case AB_CURVE:
      shouldUse = ballDX < 0;
      break;
    case AB_DASH:
      shouldUse = distToBall > paddle2H * 0.7 && ballDX > 0;
      if (shouldUse) {
        if (ballY < paddleCenter) upPressed = true; else downPressed = true;
      }
      break;
    case AB_BOOST:
      shouldUse = ballDX > 0 && distToBall > paddle2H * 0.5;
      break;
    case AB_TELEPORT:
      shouldUse = ballDX > 0 && distToBall > paddle2H;
      break;
    default:
      shouldUse = true;
      break;
  }

  if (shouldUse) {
    activateAbility(2);
    if (p2Ability == AB_DASH) {
      upPressed = false;
      downPressed = false;
    }
  }
}

// ===================== ABILITY ACTIVATION =====================
void activateAbility(int player) {
  int ability = (player == 1) ? p1Ability : p2Ability;
  float cd = (player == 1) ? p1Cooldown : p2Cooldown;
  if (ability < 0 || cd > 0) return;

  float duration = AB_DURATION[ability];
  float cooldown = AB_COOLDOWN[ability];
  int[] ac = getAbilityColor(ability);

  switch (ability) {
    case AB_GROW:
      if (player == 1) { paddle1H = basePaddleH * 1.8; p1ActiveTimer = duration; }
      else { paddle2H = basePaddleH * 1.8; p2ActiveTimer = duration; }
      spawnParticles2(player == 1 ? 26 : width - 26,
        player == 1 ? paddle1Y + paddle1H / 2 : paddle2Y + paddle2H / 2,
        12, ac[0], ac[1], ac[2]);
      break;

    case AB_SHIELD:
      if (player == 1) p1Shield = true; else p2Shield = true;
      spawnParticles2(player == 1 ? 10 : width - 10, height / 2, 15, 80, 255, 255);
      flashScreen(80, 255, 255, 40);
      break;

    case AB_SLOW:
      ballDX *= 0.4;
      ballDY *= 0.4;
      if (player == 1) p1ActiveTimer = duration; else p2ActiveTimer = duration;
      spawnParticles2(ballX, ballY, 15, ac[0], ac[1], ac[2]);
      break;

    case AB_POWER:
      ballDX *= 2.5;
      shakeAmount = 15;
      spawnParticles2(ballX, ballY, 20, 255, 80, 80);
      flashScreen(255, 50, 50, 80);
      break;

    case AB_CURVE:
      ballCurve = random(-1.2, 1.2);
      spawnParticles2(ballX, ballY, 12, 200, 80, 255);
      break;

    case AB_DASH:
      float dashDir = 0;
      if (player == 1) {
        if (wPressed) dashDir = -1; else if (sPressed) dashDir = 1;
        paddle1Y += dashDir * 120;
        paddle1Y = constrain(paddle1Y, 0, height - paddle1H);
        spawnParticles2(26, paddle1Y + paddle1H / 2, 10, ac[0], ac[1], ac[2]);
      } else {
        if (upPressed) dashDir = -1; else if (downPressed) dashDir = 1;
        paddle2Y += dashDir * 120;
        paddle2Y = constrain(paddle2Y, 0, height - paddle2H);
        spawnParticles2(width - 26, paddle2Y + paddle2H / 2, 10, ac[0], ac[1], ac[2]);
      }
      break;

    case AB_BOOST:
      if (player == 1) { paddle1Speed = basePaddleSpeed * 2.2; p1ActiveTimer = duration; }
      else { paddle2Speed = basePaddleSpeed * 2.2; p2ActiveTimer = duration; }
      break;

    case AB_TELEPORT:
      if (player == 1) {
        paddle1Y = ballY - paddle1H / 2;
        paddle1Y = constrain(paddle1Y, 0, height - paddle1H);
        spawnParticles2(26, paddle1Y + paddle1H / 2, 15, 150, 80, 255);
      } else {
        paddle2Y = ballY - paddle2H / 2;
        paddle2Y = constrain(paddle2Y, 0, height - paddle2H);
        spawnParticles2(width - 26, paddle2Y + paddle2H / 2, 15, 150, 80, 255);
      }
      flashScreen(150, 80, 255, 40);
      break;
  }

  if (player == 1) p1Cooldown = cooldown; else p2Cooldown = cooldown;
}

void endAbility(int player) {
  int ab = (player == 1) ? p1Ability : p2Ability;
  switch (ab) {
    case AB_GROW:
      if (player == 1) paddle1H = basePaddleH; else paddle2H = basePaddleH;
      break;
    case AB_SLOW:
      float spd = sqrt(ballDX * ballDX + ballDY * ballDY);
      if (spd < ballSpeed) {
        ballDX = (ballDX / spd) * ballSpeed;
        ballDY = (ballDY / spd) * ballSpeed;
      }
      break;
    case AB_BOOST:
      if (player == 1) paddle1Speed = basePaddleSpeed; else paddle2Speed = basePaddleSpeed;
      break;
  }
}

// ===================== COLLISIONS =====================
void checkCollisions() {
  if (ballX - ballSize / 2 <= 20 + paddleW &&
      ballX - ballSize / 2 >= 15 &&
      ballY >= paddle1Y && ballY <= paddle1Y + paddle1H &&
      ballDX < 0) {
    handlePaddleHit(1);
  }

  float rpx = width - 20 - paddleW;
  if (ballX + ballSize / 2 >= rpx &&
      ballX + ballSize / 2 <= rpx + paddleW + 5 &&
      ballY >= paddle2Y && ballY <= paddle2Y + paddle2H &&
      ballDX > 0) {
    handlePaddleHit(2);
  }
}

void handlePaddleHit(int player) {
  ballDX *= -1;
  rallyCount++;

  float paddleY = (player == 1) ? paddle1Y : paddle2Y;
  float paddleH2 = (player == 1) ? paddle1H : paddle2H;
  float hitPos = (ballY - paddleY) / paddleH2;
  float angle = map(hitPos, 0, 1, -PI / 3, PI / 3);
  float spd = ballSpeed + rallyCount * 0.12;
  spd = min(spd, 16);
  ballDX = cos(angle) * spd * (player == 1 ? 1 : -1);
  ballDY = sin(angle) * spd;

  if (rallyCount >= fireThreshold && !ballOnFire) {
    ballOnFire = true;
    shakeAmount = 12;
    spawnParticles2(ballX, ballY, 25, 255, 150, 0);
    flashScreen(255, 100, 0, 50);
  }

  int[] hitCol = (player == 1) ? skinP1[currentSkin] : skinP2[currentSkin];
  spawnParticles2(ballX, ballY, 8, hitCol[0], hitCol[1], hitCol[2]);
  shakeAmount = max(shakeAmount, 3 + rallyCount * 0.3);
}

// ===================== PARTICLES =====================
void spawnParticles2(float x2, float y2, int count, int r, int g, int b) {
  for (int i = 0; i < count && particleCount < MAX_PARTICLES; i++) {
    ppx[particleCount] = x2;
    ppy[particleCount] = y2;
    pvx[particleCount] = random(-4, 4);
    pvy[particleCount] = random(-4, 4);
    pLife[particleCount] = 1.0;
    prr[particleCount] = r;
    pgg[particleCount] = g;
    pbb[particleCount] = b;
    particleCount++;
  }
}

void updateParticles2() {
  for (int i = particleCount - 1; i >= 0; i--) {
    ppx[i] += pvx[i];
    ppy[i] += pvy[i];
    pLife[i] -= 0.025;
    pvx[i] *= 0.96;
    pvy[i] *= 0.96;
    if (pLife[i] <= 0) {
      ppx[i] = ppx[particleCount - 1];
      ppy[i] = ppy[particleCount - 1];
      pvx[i] = pvx[particleCount - 1];
      pvy[i] = pvy[particleCount - 1];
      pLife[i] = pLife[particleCount - 1];
      prr[i] = prr[particleCount - 1];
      pgg[i] = pgg[particleCount - 1];
      pbb[i] = pbb[particleCount - 1];
      particleCount--;
    }
  }
}

void drawParticles2() {
  noStroke();
  for (int i = 0; i < particleCount; i++) {
    fill(prr[i], pgg[i], pbb[i], pLife[i] * 200);
    float s = pLife[i] * 6;
    ellipse(ppx[i], ppy[i], s, s);
  }
}

// ===================== SCREEN FX =====================
void flashScreen(int r, int g, int b, float alpha) {
  flashR = r;
  flashG = g;
  flashB = b;
  flashAlpha = alpha;
}

// ===================== WIN CHECK =====================
void checkWin() {
  if (score1 >= winScore) {
    winner = "PLAYER 1";
    handleMatchEnd(true);
  } else if (score2 >= winScore) {
    winner = gameMode == 1 ? "BOT" : "PLAYER 2";
    handleMatchEnd(false);
  }
}

void handleMatchEnd(boolean player1Won) {
  if (xpAwarded) return;
  xpAwarded = true;
  gameState = STATE_GAMEOVER;
  int xpGained = 0;
  if (gameMode == 1) {
    if (player1Won) {
      if (difficulty == 0) xpGained = 100;
      else if (difficulty == 1) xpGained = 200;
      else xpGained = 300;
    }
  } else {
    xpGained = 200;
  }
  addXP(xpGained);
}

// ===================== GAME OVER =====================
void drawGameOverScreen() {
  int[] bg = skinBG[currentSkin];
  background(bg[0], bg[1], bg[2]);
  if (currentSkin == 0 || currentSkin == 2) drawStarfield();

  boolean p1Won = winner.equals("PLAYER 1");
  int[] wc = p1Won ? skinP1[currentSkin] : skinP2[currentSkin];

  float pulse = 0.7 + 0.3 * sin(millis() / 300.0);
  fill(wc[0], wc[1], wc[2], (int)(40 * pulse));
  textSize(70);
  text(winner + " WINS!", width / 2, height / 2 - 60);
  fill(wc[0], wc[1], wc[2]);
  textSize(56);
  text(winner + " WINS!", width / 2, height / 2 - 60);

  fill(200);
  textSize(28);
  text(score1 + " - " + score2, width / 2, height / 2 + 10);

  int[] acc = skinAccent[currentSkin];
  fill(acc[0], acc[1], acc[2]);
  textSize(18);
  String xpMsg;
  if (gameMode == 1) {
    if (p1Won) {
      if (difficulty == 0) xpMsg = "+100 XP  [Easy]";
      else if (difficulty == 1) xpMsg = "+200 XP  [Medium]";
      else xpMsg = "+300 XP  [Hard]";
    } else {
      xpMsg = "+0 XP";
    }
  } else {
    xpMsg = "+200 XP";
  }
  text(xpMsg, width / 2, height / 2 + 50);

  drawXPBar(width / 2 - 120, height / 2 + 70, 240, 18);

  fill(180);
  textSize(20);
  text("SPACE = Rematch | ESC = Menu", width / 2, height / 2 + 125);
}

// ===================== LEVEL UP =====================
void drawLevelUpOverlay() {
  int[] acc = skinAccent[currentSkin];
  float a = min(levelUpTimer * 80, 200);
  fill(acc[0], acc[1], acc[2], a * 0.15);
  noStroke();
  rect(0, 0, width, height);

  float bannerY = 50 + sin(levelUpAnimFrame * 0.05) * 5;
  int bannerH = (unlockedItemName.length() > 0) ? 82 : 50;
  fill(0, 0, 0, a * 0.6);
  rect(width / 2 - 185, bannerY - 5, 370, bannerH, 10);
  fill(acc[0], acc[1], acc[2], a);
  textSize(28);
  text("LEVEL UP! Lv." + playerLevel, width / 2, bannerY + 18);
  if (unlockedItemName.length() > 0) {
    fill(80, 255, 80, a);
    textSize(15);
    text(unlockedItemName + " UNLOCKED!", width / 2, bannerY + 52);
  }
}

void drawLevelUpScreen() {
  int[] bg = skinBG[currentSkin];
  background(bg[0], bg[1], bg[2]);

  int[] acc = skinAccent[currentSkin];
  float scale = 1.0 + 0.1 * sin(millis() / 200.0);
  textSize(80 * scale);
  fill(acc[0], acc[1], acc[2], 40);
  text("Lv." + playerLevel, width / 2, height / 2 - 20);
  textSize(72 * scale);
  fill(acc[0], acc[1], acc[2]);
  text("Lv." + playerLevel, width / 2, height / 2 - 20);

  fill(255);
  textSize(30);
  text("LEVEL UP!", width / 2, height / 2 - 90);

  drawXPBar(width / 2 - 150, height / 2 + 50, 300, 22);

  if (unlockedItemName.length() > 0) {
    fill(80, 255, 80);
    textSize(18);
    text(unlockedItemName + " UNLOCKED!", width / 2, height / 2 + 88);
  }

  fill(180);
  textSize(18);
  text("Press ENTER to continue", width / 2, height / 2 + 115);
}

// ===================== PAUSE MENU =====================
void drawPauseMenu() {
  noStroke();
  fill(0, 0, 0, 160);
  rect(0, 0, width, height);

  int[] acc = skinAccent[currentSkin];
  float px = width / 2 - 160;
  float py = height / 2 - 126;
  float pw = 320;
  float ph = 252;

  fill(15, 10, 30, 230);
  rect(px, py, pw, ph, 14);
  stroke(acc[0], acc[1], acc[2], 180);
  strokeWeight(2);
  noFill();
  rect(px, py, pw, ph, 14);
  noStroke();

  fill(acc[0], acc[1], acc[2]);
  textSize(32);
  text("PAUSED", width / 2, py + 44);

  String[] opts = {"CONTINUE", "RESTART MATCH", "MAIN MENU"};
  for (int i = 0; i < 3; i++) {
    float by = py + 76 + i * 56;
    boolean hov = (menuHover == i);
    noStroke();
    if (hov) {
      fill(acc[0], acc[1], acc[2], 50);
      rect(px + 20, by, pw - 40, 44, 8);
      stroke(acc[0], acc[1], acc[2]);
      strokeWeight(1.5);
      noFill();
      rect(px + 20, by, pw - 40, 44, 8);
      noStroke();
      fill(255);
    } else {
      fill(35, 35, 55, 200);
      rect(px + 20, by, pw - 40, 44, 8);
      fill(170);
    }
    textSize(19);
    text(opts[i], width / 2, by + 20);
  }

  fill(80);
  textSize(11);
  text("UP/DOWN = Navigate  |  ENTER = Confirm  |  ESC = Resume", width / 2, py + ph + 18);
}

// ===================== DECORATIVE =====================
void drawStarfield() {
  noStroke();
  float t = millis() / 50.0;
  for (int i = 0; i < 60; i++) {
    float sx2 = (noise(i * 100) * width + t * (0.3 + noise(i * 50) * 0.5)) % width;
    float sy2 = noise(i * 200 + 500) * height;
    float sz = 1 + noise(i * 300) * 2.5;
    fill(255, 40 + noise(i * 400) * 40);
    ellipse(sx2, sy2, sz, sz);
  }
}

void drawNeonGrid() {
  stroke(0, 40, 60, 40);
  strokeWeight(1);
  float offset = (millis() / 40.0) % 40;
  for (float y = offset; y < height; y += 40) {
    line(0, y, width, y);
  }
  for (float x = 0; x < width; x += 40) {
    line(x, 0, x, height);
  }
}

void drawRetroScanlines() {
  stroke(255, 255, 255, 8);
  strokeWeight(1);
  for (int y = 0; y < height; y += 3) {
    line(0, y, width, y);
  }
}

// ===================== INPUT =====================
void keyPressed() {
  if (key == 'w' || key == 'W') wPressed = true;
  if (key == 's' || key == 'S') sPressed = true;
  if (keyCode == UP) upPressed = true;
  if (keyCode == DOWN) downPressed = true;

  if (gameState == STATE_MENU) {
    if (keyCode == UP || key == 'w' || key == 'W') menuHover = (menuHover + 3) % 4;
    if (keyCode == DOWN || key == 's' || key == 'S') menuHover = (menuHover + 1) % 4;
    if (key == ENTER || key == RETURN) {
      if (menuHover == 0) { menuHover = 0; startTransition(STATE_MODE); }
      else if (menuHover == 1) { skinsMenuTab = 0; menuHover = currentSkin; startTransition(STATE_SKINS); }
      else if (menuHover == 2) { menuHover = ballSpeedSetting; startTransition(STATE_SETTINGS); }
      else if (menuHover == 3) { exit(); }
    }
  }

  else if (gameState == STATE_MODE) {
    if (keyCode == UP || keyCode == DOWN || key == 'w' || key == 'W' || key == 's' || key == 'S')
      menuHover = (menuHover + 1) % 2;
    if (key == ENTER || key == RETURN) {
      if (menuHover == 0) {
        gameMode = 1;
        menuHover = 1;
        startTransition(STATE_DIFFICULTY);
      } else {
        gameMode = 2;
        abilityMenuSelection = 0;
        startTransition(STATE_SELECT_P1);
      }
    }
    if (key == ESC) { key = 0; menuHover = 0; startTransition(STATE_MENU); }
  }

  else if (gameState == STATE_DIFFICULTY) {
    if (keyCode == UP || key == 'w' || key == 'W') menuHover = (menuHover + 2) % 3;
    if (keyCode == DOWN || key == 's' || key == 'S') menuHover = (menuHover + 1) % 3;
    if (key == ENTER || key == RETURN) {
      difficulty = menuHover;
      abilityMenuSelection = 0;
      startTransition(STATE_SELECT_P1);
    }
    if (key == ESC) { key = 0; menuHover = 0; startTransition(STATE_MODE); }
  }

  else if (gameState == STATE_SKINS) {
    if (key == 'q' || key == 'Q') { skinsMenuTab = 0; menuHover = currentSkin; }
    if (key == 'e' || key == 'E') { skinsMenuTab = 1; menuHover = currentDecoration; }
    if (skinsMenuTab == 0) {
      if (keyCode == LEFT) menuHover = (menuHover + SKIN_COUNT - 1) % SKIN_COUNT;
      if (keyCode == RIGHT) menuHover = (menuHover + 1) % SKIN_COUNT;
      if (key == ENTER || key == RETURN) {
        if (SKIN_UNLOCK_LEVEL[menuHover] <= playerLevel) {
          currentSkin = menuHover;
          saveProgress();
        }
      }
    } else {
      if (keyCode == UP || key == 'w' || key == 'W') menuHover = (menuHover + DECORATION_COUNT - 1) % DECORATION_COUNT;
      if (keyCode == DOWN || key == 's' || key == 'S') menuHover = (menuHover + 1) % DECORATION_COUNT;
      if (key == ENTER || key == RETURN) {
        if (DECORATION_UNLOCK_LEVEL[menuHover] <= playerLevel) {
          currentDecoration = menuHover;
          saveProgress();
        }
      }
    }
    if (key == ESC) { key = 0; menuHover = 1; skinsMenuTab = 0; startTransition(STATE_MENU); }
  }

  else if (gameState == STATE_SETTINGS) {
    if (key == '1') { ballSpeedSetting = 0; menuHover = 0; ballBaseSpeed = BALL_SPEEDS[0]; saveProgress(); }
    if (key == '2') { ballSpeedSetting = 1; menuHover = 1; ballBaseSpeed = BALL_SPEEDS[1]; saveProgress(); }
    if (key == '3') { ballSpeedSetting = 2; menuHover = 2; ballBaseSpeed = BALL_SPEEDS[2]; saveProgress(); }
    if (keyCode == LEFT) winScore = max(3, winScore - 1);
    if (keyCode == RIGHT) winScore = min(15, winScore + 1);
    if (key == ESC) { key = 0; menuHover = 2; startTransition(STATE_MENU); }
  }

  else if (gameState == STATE_SELECT_P1) {
    if (keyCode == UP || key == 'w' || key == 'W') abilityMenuSelection = (abilityMenuSelection + AB_COUNT - 1) % AB_COUNT;
    if (keyCode == DOWN || key == 's' || key == 'S') abilityMenuSelection = (abilityMenuSelection + 1) % AB_COUNT;
    if (key == ENTER || key == RETURN) {
      p1Ability = abilityMenuSelection;
      if (gameMode == 1) {
        botPickAbility();
        abilityMenuSelection = 0;
        resetGame();
        p1Cooldown = 0; p2Cooldown = 0;
        p1ActiveTimer = 0; p2ActiveTimer = 0;
        p1Shield = false; p2Shield = false;
        startTransition(STATE_PLAY);
      } else {
        abilityMenuSelection = 0;
        startTransition(STATE_SELECT_P2);
      }
    }
    if (key == ESC) {
      key = 0;
      abilityMenuSelection = 0;
      if (gameMode == 1) {
        menuHover = 1;
        startTransition(STATE_DIFFICULTY);
      } else {
        menuHover = 0;
        startTransition(STATE_MODE);
      }
    }
  }

  else if (gameState == STATE_SELECT_P2) {
    if (keyCode == UP || key == 'w' || key == 'W') abilityMenuSelection = (abilityMenuSelection + AB_COUNT - 1) % AB_COUNT;
    if (keyCode == DOWN || key == 's' || key == 'S') abilityMenuSelection = (abilityMenuSelection + 1) % AB_COUNT;
    if (key == ENTER || key == RETURN) {
      p2Ability = abilityMenuSelection;
      abilityMenuSelection = 0;
      resetGame();
      p1Cooldown = 0; p2Cooldown = 0;
      p1ActiveTimer = 0; p2ActiveTimer = 0;
      p1Shield = false; p2Shield = false;
      startTransition(STATE_PLAY);
    }
    if (key == ESC) { key = 0; abilityMenuSelection = 0; startTransition(STATE_SELECT_P1); }
  }

  else if (gameState == STATE_GAMEOVER) {
    if (key == ' ') {
      resetGame();
      p1Cooldown = 0; p2Cooldown = 0;
      p1ActiveTimer = 0; p2ActiveTimer = 0;
      p1Shield = false; p2Shield = false;
      gameState = STATE_PLAY;
    }
    if (key == ESC) { key = 0; menuHover = 0; gameState = STATE_MENU; }
  }

  else if (gameState == STATE_LEVELUP) {
    if (key == ENTER || key == RETURN) { gameState = STATE_MENU; menuHover = 0; }
  }

  else if (gameState == STATE_PLAY) {
    if (key == 'x' || key == 'X') activateAbility(1);
    if (gameMode == 2 && (key == 'm' || key == 'M')) activateAbility(2);
    if (key == ESC) {
      key = 0;
      menuHover = 0;
      wPressed = false; sPressed = false; upPressed = false; downPressed = false;
      gameState = STATE_PAUSE;
    }
  }

  else if (gameState == STATE_PAUSE) {
    if (keyCode == UP || key == 'w' || key == 'W') menuHover = (menuHover + 2) % 3;
    if (keyCode == DOWN || key == 's' || key == 'S') menuHover = (menuHover + 1) % 3;
    if (key == ENTER || key == RETURN) {
      if (menuHover == 0) {
        wPressed = false; sPressed = false; upPressed = false; downPressed = false;
        gameState = STATE_PLAY;
      } else if (menuHover == 1) {
        resetGame();
        p1Cooldown = 0; p2Cooldown = 0;
        p1ActiveTimer = 0; p2ActiveTimer = 0;
        p1Shield = false; p2Shield = false;
        wPressed = false; sPressed = false; upPressed = false; downPressed = false;
        gameState = STATE_PLAY;
      } else {
        menuHover = 0;
        startTransition(STATE_MENU);
      }
    }
    if (key == ESC) {
      key = 0;
      wPressed = false; sPressed = false; upPressed = false; downPressed = false;
      gameState = STATE_PLAY;
    }
  }
}

void keyReleased() {
  if (key == 'w' || key == 'W') wPressed = false;
  if (key == 's' || key == 'S') sPressed = false;
  if (keyCode == UP) upPressed = false;
  if (keyCode == DOWN) downPressed = false;
}

// ===================== BOT ABILITY PICK =====================
void botPickAbility() {
  if (difficulty == 0) {
    p2Ability = int(random(AB_COUNT));
  } else if (difficulty == 1) {
    int[] good = {AB_SHIELD, AB_GROW, AB_TELEPORT, AB_DASH, AB_BOOST};
    p2Ability = good[int(random(good.length))];
  } else {
    int[] best = {AB_SHIELD, AB_TELEPORT, AB_GROW};
    p2Ability = best[int(random(best.length))];
  }
}
