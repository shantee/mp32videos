color[] palette = { 
  color(158, 8, 0),    // Rouge
  color(179, 12, 86),  // Orange
  color(20, 93, 210),  // Jaune
  color(79, 24, 63),   // Vert
  color(95, 31, 140),  // Bleu
  color(179, 12, 86),  // Orange
  color(115, 15, 0),   // Rouge
  color(197, 75, 6),   // Vert
  color(79, 55, 30),   // Bleu
  color(133, 3, 98),   // Jaune
};

float colorOffset = 0;

void drawCircularSpectrum(float centerX, float centerY, float radius, float intensity) {
 
  int numBands = 64;
  float angleStep = PI / numBands;
  strokeWeight(18);
  colorOffset += 0.01;  // Contrôle la vitesse du déplacement des couleurs

  for (int i = 0; i < numBands; i++) {
    float angle = i * angleStep;
    float bandHeight = map(player.mix.get(i % player.bufferSize()), 1, 5, 0, -3 * intensity);

    float x1 = centerX + cos(angle) * radius;
    float y1 = centerY + sin(angle) * 1.2;
    float x2 = centerX + cos(angle) * (radius * 7.0 + bandHeight);
    float y2 = centerY + sin(angle) * (radius + bandHeight);

    float t = (map(i, 0, numBands, 0, 1) + colorOffset) % 1.0;
    color col = getGradientColor(t);
    blendMode(ADD);
    stroke(col);
    line(x1, y1, x2, y2);
  }
}

color getGradientColor(float t) {
  int numColors = palette.length;
  float scaledT = t * (numColors - 1);
  int index1 = floor(scaledT);
  int index2 = min(index1 + 1, numColors - 1);
  float fraction = scaledT - index1;
  return lerpColor(palette[index1], palette[index2], fraction);
}

void drawVaporwaveBackground() {

  for (int y = 0; y < height; y++) {
    float inter = map(y, 0, height, 0, 1);
    stroke(lerpColor(color(178, 105, 180), color(77, 25, 177), inter), 0, 150,28);
    blendMode(ADD);
    line(0, y,width, y);

  }

}

void displayMusicInfo() {
  push();
translate(-140,-50,0);
  fill(0, 0, 0, 100);
  stroke(255);
  rect(0, 0, 400, 170);
  noStroke();

  textFont(fontNormal);
  textAlign(LEFT, TOP);
  texte = " " + title + "\n " + filename + "\n size : " + filesize + "\n " + year;
  textSize(30);
  fill(0, 0, 0);
  text(texte, 12, 30);
  text(texte, 12, 28);
  fill(255);
  text(texte, 10, 28);

  fill(0,0,0,100);
  rect(640,-200,800,3320);
  textFont(fontBold);
  
  translate(270, 800, 0);
  displayComments();
  pop();
}
float logox = 0;
float logoxSpeed = 0.82;
void logoMove(){
logox += logoxSpeed;
image(logo2,-180+logox,120);
  if (logox >= 1000 || logox <= 0) {
        logoxSpeed *= -1; // Inverse la direction du mouvement
    }
}
void showTitle(float  x){
 
        rect(-500,height/2-100+x,1800,140);
        fill(255);
        text(title, -40,height/2+x);
}
void loadMP3File(String mp3FilePath) {
  println("Traitement de : " + mp3FilePath);
  if (player != null) player.close();
  player = minim.loadFile(mp3FilePath, 2048);
  player.play();
  beat = new BeatDetect();//player.bufferSize(), player.sampleRate()
  beat.setSensitivity(20); // Ajuster la sensibilité, en millisecondes (plus la valeur est faible, plus c'est sensible)
   fft = new FFT(player.bufferSize(), player.sampleRate());
  String metadataFilePath = "metadata/" + getBaseName(mp3FilePath) + ".txt";
  loadMetadata(metadataFilePath);
}

void loadMetadata(String filepath) {
  filename = filesize = title = artist = year = comments = instruments = "";
  String[] lines = loadStrings(filepath);
  boolean inInstrumentsSection = false;

  for (String line : lines) {
    if (line.startsWith("Instruments:")) {
      inInstrumentsSection = true;
      continue;
    }
    if (inInstrumentsSection) instruments += line + "\n";
    if (line.startsWith("Patterns     :")) patterns = line.substring(14);
    if (line.startsWith("Channels     :")) channels = line.substring(14);
    if (line.startsWith("Samples      :")) samples = line.substring(14);

    if (line.startsWith("filesize : ")) filesize = line.substring(11);
    else if (line.startsWith("filename : ")) filename = line.substring(11);
    else if (line.startsWith("Module name  : ")) title = line.substring(15);
    else if (line.startsWith("Artist: ")) artist = line.substring(8);
    else if (line.startsWith("Year: ")) year = line.substring(6);
  }
 
}

void displayComments() {
  textAlign(LEFT, TOP);
 
  String[] lines = split(instruments, '\n');
  float lineHeight = textAscent() + textDescent();
  float spacing = 10;
  float totalTextHeight = lines.length * (lineHeight + spacing);
  float yOffset = commentY+80;
  fill(255,255,0);
textSize(24);
text(title, (width / 2) - 92, yOffset - 240);
text("channels :"+channels, (width / 2) - 92, yOffset - 200);
text("patterns :"+patterns, (width / 2) - 92, yOffset - 160);
text("samples  :"+samples, (width / 2) - 92, yOffset - 120);
text("file  : "+filename+" ("+filesize+")", (width / 2) - 92, yOffset - 80);
textSize(38);
  for (String line : lines) {
    fill(0);
    text(line, (width / 2) + 2-80, yOffset + 2);
    fill(255);
    text(line, (width / 2)-80, yOffset);
    yOffset += lineHeight + spacing;
  }

  commentY -= 2;  // Vitesse de défilement du texte
  if (commentY < -totalTextHeight - height) commentY = height;
}

void stop() {
  if (player != null) player.close();
  minim.stop();
  super.stop();
}

String[] getMP3Files(String dirPath) {
  File dir = new File(sketchPath(dirPath));
  if (dir.isDirectory()) {
    File[] files = dir.listFiles();
    ArrayList<String> mp3List = new ArrayList<String>();
    for (File file : files) {
      if (file.isFile() && file.getName().toLowerCase().endsWith(".mp3"))
        mp3List.add(dirPath + "/" + file.getName());
    }
    return mp3List.toArray(new String[mp3List.size()]);
  } else {
    println("Le répertoire " + dir.getAbsolutePath() + " n'existe pas ou n'est pas un répertoire.");
    return new String[0];
  }
  
}

String getBaseName(String filePath) {
  String fileName = new File(filePath).getName();
  int dotIndex = fileName.lastIndexOf('.');
  return (dotIndex > 0) ? fileName.substring(0, dotIndex) : fileName;
}
