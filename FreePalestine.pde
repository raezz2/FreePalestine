//sound
import processing.sound.*;
SoundFile hit;
SoundFile music;
SoundFile lose;

//image
PImage efek;
PImage bg;
PImage lifebar;
PImage rocket;
PImage bgGameover;
PImage button;
PFont font;    //font yang digunakan
boolean game_over=false; //game over jika kondisinya true
boolean menu=true; //halaman menu awal (game mulai saat kondisinya false)
Player basket;  //Declares an object of the type Player
Lifebar life;  //Declares an object of the type Player
Bom rockets[];  //Kita butuh beberapa rocket. [] menunjukkan bahwa kita menggunakan array objek.
int rocket_no= 3;    //Jumlah rocket yang tampil dilayar
int score= 0;
int lifeScore= 400; //lebar lifebar

//Membuat Class
class Player {
  int posx, posy;  //Posisi player saat ini
  PImage pic;  //player image
  int w, h;  //lebar dan tinggi player
  Player()  //constructor. Fungsi ini dipanggil setiap kali objek baru dari kelas Player dibuat.
  {
    w=85;
    h=65;
    posx=mouseX-w/2;
    posy=height-h;
  }

  void display()  //Menampilkan data
  {
    posx=mouseX-w/2;
    image(pic, posx, posy, w, h);
  }
}

class Bom {
  int posx, posy, speed, w, h;
  color c;
  boolean exploded;
  Bom()
  {
    posx=(int)random(50, width-50);
    posy=0;
    w=15;
    h=45;
    speed=(int)random(2, 5);
    c=color(180, 0, 0);
    exploded = false;
  }
  void explode() {
    // Tambahkan logika ledakan di sini
    // Misalnya, setel gambar atau efek ledakan
    image(efek, posx - 25, posy - 35, 70, 70);
  }
  void play_explosion_sound() {
    hit.play();
  }
  void reset_exploded() {
    exploded = false;
  }
  void display()
  {
    //fill(c);
    //ellipse(posx, posy, rad, rad);
    image(rocket, posx, posy, w, h);
  }
  void update_pos()
  {
    posy+=speed;
  }
  void check_bounds()
  {
      if (posy >= height && !exploded) {
      explode();
      lifeScore -= 20;
      exploded = true;
    } else if (posy >= height) {
      reset_pos();
    }
  }
  void reset_pos()
    {
      posy=0;
      posx=(int)random(50, width-50);
      speed=(int)random(3, 6);
    }
  }
  class Lifebar {
    int posx, posy, h;
    Lifebar()
  {
    posx= width/2 - lifeScore/2;
    posy= 30;
    h= 15;
  }
  void display()
  {
    //fill(c);
    //ellipse(posx, posy, rad, rad);
    image(lifebar, posx, posy, lifeScore, h);
  }
}

void setup()
{
  size(800, 450);
  //load image
  bg = loadImage("menu-background.png");
  bgGameover = loadImage("gameover.png");
  lifebar = loadImage("lifebar.png");
  rocket = loadImage("rocket.png");
  efek = loadImage("efek.png");
  button= loadImage("start.png");
  // Load the sound file
  music = new SoundFile(this, "Imagine.mp3");
  lose = new SoundFile(this, "failsound.mp3");
  hit = new SoundFile(this, "hit.wav");
  
  //background(128);
  smooth();  //Turn on anti-aliasing. Make lines look a lot smoother
  frameRate(30);
  font=loadFont("font.vlw");
  textFont(font, 16);
  basket=new Player();  //Initialize our object.
  basket.pic = loadImage("catcher.png");  // Memuat gambar di sini
  life = new Lifebar();
  rockets=new Bom[rocket_no];  
  for (int i=0;i<rocket_no;i++)  //Initialize each rocket.
  {
    rockets[i]=new Bom();
  }
}

void draw()
{
   background(bg);
   
  if (menu==true){
    menu();
  } 
  else{
    if (!game_over && music.isPlaying()){
      life.display();              //Displays the lifebar.
      basket.display();              //Displays the basket.
      
      for (int i=0;i<rocket_no;++i)   //Untuk setiap rocket yang ada, dijalankan fungsi display, update_pos, check_bounds dan check_collision.
        {
          rockets[i].display();
          rockets[i].update_pos();
          rockets[i].check_bounds();
          check_collision(rockets[i]);
          
          if (rockets[i].exploded) {
            rockets[i].explode();
            rockets[i].play_explosion_sound();  // Memanggil suara ledakan
            rockets[i].reset_pos();
            rockets[i].reset_exploded();  // Reset exploded setelah meledak
          }
        }
      score_display();
      lifeScore_display();
    }
    else if (game_over){
        gameOver();
    }
  }
}

void menu(){
  image(button, 300, 195,200,60); //menampilkan tombol button
  //jika mouse click pada area tombol button
  if(mouseX>=300 && mouseX<=300+200 && mouseY>=195&&mouseY<=195+60 && mousePressed){
      image(button, 270, 185,240,80);
      //reset posisi semua rocket
      for (int i=0;i<rocket_no;++i){
        rockets[i].reset_pos();
      }
      lifeScore=400; //reset lifeScore
      score = 0; //reset score point
      menu=false;
      music.play();
  }
}

void gameOver(){
  music.stop();
  image(bgGameover, 0, 0);
  image(button, 300, 195,200,60);
  if(mouseX>=300 && mouseX<=300+200 && mouseY>=195&&mouseY<=195+60 && mousePressed){
    image(button, 270, 185,240,80);
    menu=true;
    game_over=false;
    }
}

void check_collision(Bom temp_rocket) 
{
  //cek jika rocket ditangkap player
  if (temp_rocket.posx > basket.posx && temp_rocket.posx < basket.posx + basket.w && temp_rocket.posy > basket.posy - 15 && temp_rocket.posy < basket.posy - basket.h/2 + 30) {
    image(efek, temp_rocket.posx - 25, temp_rocket.posy - 35, 70, 70);
    hit.play();
    temp_rocket.reset_pos();
    score = score + 1; // tambah point
    if (lifeScore > 0 && lifeScore < 400) {
      lifeScore = lifeScore + 5; // tambah lifescore
    }
  }
}

void score_display() //menampilkan score
{
  fill(#FAFAFA);
  textAlign(LEFT);
  textSize(18);
  text("rocket Point : "+score, 5, height-5);
  noFill();
}

void lifeScore_display() //menampilkan lifescore
{
  fill(#FAFAFA);
  textAlign(CENTER);
  textSize(18);
  text("Life Score: "+lifeScore, width/2, 25);
  noFill();
  if (lifeScore<=0){
    game_over=true;
    lose.play();
  }
}
