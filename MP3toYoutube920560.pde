boolean record = true;
int frameCount = 0;

import ddf.minim.*;
import ddf.minim.analysis.*;
import java.io.File;

Minim minim;
AudioPlayer player;
BeatDetect beat;
FFT fft;
PFont fontNormal, fontBold, fontItalic;
String texte, title = "", artist = "", year = "", comments = "", filename = "", filesize = "", channels = "", instruments = "", patterns = "", samples = "";
String[] mp3Files;
int currentFileIndex = 0, titleStartTime = 0;
float commentY, defaultBeat, beatValue, scaleFactor = 1.0, opacityValue = 0.50;
boolean inInstrumentsSection = false, hideTitle = false;
PImage img, sprite, logo2;
PShape rayons;
PShader hueShiftShader;

void setup() {
  size(960, 540, P3D);
  hueShiftShader = loadShader("hueShift.frag");
  hueShiftShader.set("resolution", float(width), float(height));

  fontNormal = createFont("Ubuntu", 32);
  fontBold = createFont("Ubuntu", 30);

  minim = new Minim(this);
  logo2 = loadImage("assets/maf-logo2.jpeg");
  img = loadImage("BG2.jpg");
  rayons = loadShape("assets/rayons.obj");
  sprite = loadImage("assets/maf-logo.png");

  mp3Files = getMP3Files("mp3");
  if (mp3Files.length == 0) {
    println("Aucun fichier MP3 trouvé dans le répertoire 'mp3'.");
    exit();
  }
  loadMP3File(mp3Files[currentFileIndex]);
  titleStartTime = millis(); // Initialiser le temps de départ pour le titre
}

float time = 0; 

void draw() {
  background(0);

  // SHADER 
  blendMode(SCREEN);
  opacityValue += 0.005; // Ajustez la vitesse du changement de teinte
  if (opacityValue > 1.0) {
    opacityValue -= 1.0;
  }
  time += 0.1;
  hueShiftShader.set("time", time); // Convertir en secondes

  // Appliquer le shader à l'ensemble de la scène
  
  camera(width/2, height/2, 600, width/2, height/2, 0, 0, 1, 0);
  beat.detect(player.mix);
  fft.forward(player.mix);
  //isOnset
  float amplitude = player.mix.level();
  if (beat.isOnset() || amplitude > 0.14) { // Seuil de l'amplitude pour une meilleure réactivité

    scaleFactor = random(0.9,2.0);
    amplitude = 0;

  } else {
    scaleFactor = lerp(scaleFactor, 0.80, 0.5);
   
  }

  push();
  translate(0, 0, -1100);
  scale(1.2,1.2,1);
  blendMode(OVERLAY);
  image(img, -1050, -1150, width * 3.4, height * 4.15);
  pop();
  push();

  lights();

  // LES RAYONS    
  blendMode(ADD);
  translate(550, 650, -1000); // Centre le modèle
  scale(1.8,1.5,1);
  rotateZ(radians(30));
  rotateX(radians(90));
  rotateY(radians(90));
  shader(hueShiftShader);

  shape(rayons);
  resetShader();
  pop();
  // Dessiner la ligne horizontale de rectangles

 
logoMove();
  // ILLUSTRATION 

  blendMode(BLEND);
  displayMusicInfo();
  blendMode(MULTIPLY);
  textSize(96);
  fill(0);

  // Affichage du titre avec gestion du temps
  if (!hideTitle) {
    int elapsedTime = millis() - titleStartTime;
    if (elapsedTime < 20000) { // Afficher le titre pendant 3.4 secondes
      showTitle(30-sin(frameCount*0.035)*70); // Montre le titre
    } else {
      
      hideTitle = true;
    }
  }

  push();
  translate(width / 2+20, height / 2 + 138);
  rotateZ(PI);
  blendMode(ADD);

  drawCircularSpectrum(0, 0, 24, 256);
  pop();
 
  drawHorizontalBars();
  // FOND BLEU 

  blendMode(SCREEN);
  scale(3,3,1);
  translate(-300,-300,0);
   push();
  blendMode(ADD);
  translate(width/2,height/2,0);
  scale(0.41*(scaleFactor/2),0.4*(scaleFactor/2),1);
  image(sprite,-400 ,  50);
  pop(); 
  drawVaporwaveBackground();
  noStroke();

  if (record) {
    String framesDir = "frames/" + getBaseName(mp3Files[currentFileIndex]);
    saveFrame(framesDir + "/frame-######.png");
    frameCount++;
  }

  if (!player.isPlaying()) {
    player.close();
    commentY = height;
    currentFileIndex++;

    if (currentFileIndex < mp3Files.length) {
      loadMP3File(mp3Files[currentFileIndex]);
      titleStartTime = millis(); // Réinitialiser le temps de départ pour le titre
      hideTitle = false;
    } else {
      println("Tous les fichiers ont été traités.");
      exit();
    }
  }

  
}

void keyPressed() {
  if (key == ' ') {
    nextTrack();
    commentY = 80;
  }
  titleStartTime = millis();
  hideTitle = false;
}

void nextTrack() {
  if (player.isPlaying()) {
    player.close();
  }
  currentFileIndex++;
  if (currentFileIndex >= mp3Files.length) {
    currentFileIndex = 0;
  }
  loadMP3File(mp3Files[currentFileIndex]);
  titleStartTime = millis();
  hideTitle = false;
}


void drawHorizontalBars() {
  int numRectsPerSide = 44; // Nombre de rectangles de chaque côté
  int gapWidth = 720; // Largeur de l'espace central
  float rectWidth = (width - gapWidth) / (numRectsPerSide * 2.0);
  float yBase = height /2 + 145; // Position verticale de la base des rectangles

  // Tableau pour stocker les valeurs du spectre
  float[] spectrumValues = new float[numRectsPerSide];

  // Obtenir les valeurs du spectre
  for (int i = 0; i < numRectsPerSide; i++) {
    int bandIndex = (int)map(i, 0, numRectsPerSide - 1, 0, fft.specSize() - 1);
    spectrumValues[i] = fft.getBand(bandIndex);
  }

  // Trouver la valeur maximale pour le scaling
  float maxSpectrumValue = 400;
  for (int i = 0; i < numRectsPerSide; i++) {
    if (spectrumValues[i] > maxSpectrumValue) {
      maxSpectrumValue = spectrumValues[i];
    }
  }

  float scaleFactorBars = 2000 / maxSpectrumValue; // Ajuster selon vos besoins
blendMode(ADD);
  fill(255,255,255); // Couleur blanche pour les rectangles
  
  noStroke();

  // Dessiner les rectangles du côté gauche
  for (int i = 0; i < numRectsPerSide; i++) {
    float x =-135+ 2.2*i * rectWidth;
    float h = spectrumValues[i] * scaleFactorBars;
    rect(x, yBase - h, rectWidth, h);
  }

  // Dessiner les rectangles du côté droit
  float xOffset = numRectsPerSide * rectWidth + gapWidth;
  for (int i = 0; i < numRectsPerSide; i++) {
    float x = xOffset + 2.2*i * rectWidth;
    float h = spectrumValues[numRectsPerSide - 1 - i] * scaleFactorBars;
    rect(x, yBase - h, rectWidth, h);
  }
}
