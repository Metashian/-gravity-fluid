
ArrayList<Part> parts = new ArrayList<Part>();
FluidGrid fg;
NBodySystem.BarnesHut bh = new NBodySystem.BarnesHut();
CollisionGrid cg;

float gravity;

void setup() {
  size(960,960,P2D);
  noSmooth();
  
  float tile_side_len = 5;
  fg = new FluidGrid(
      ceil(width/tile_side_len),
      ceil(height/tile_side_len));
  fg.setTileSize(tile_side_len,tile_side_len);
  
  bh.setFrame(0,0,width,height);
  bh.setMaxBodiesPerBranch(16);
  bh.setPrecision(1);
  
  cg = new CollisionGrid(2);
}

void handleInput() {
  switch(key) {
    case 'n':
    {
      float vx = (mouseX-pmouseX)/2;
      float vy = (mouseY-pmouseY)/2;
      for(int i=0;i<10;i++) {
        float angle = random(0,TWO_PI);
        float range = sqrt(random(0,1))*10;
        Part part = new Part(
            mouseX+range*cos(angle),
            mouseY+range*sin(angle),
            vx,vy);
        if(mouseButton==RIGHT) {
          part.setDensity(.1);
          part.setColor(color(128));
        } else {
          part.setDensity(1);
          part.setColor(color(0,255,0));
        }
        part.setRadius(1);
        
        parts.add(part);
        fg.add(part);
        bh.add(part);
        cg.add(part);
      }
    }
    break;
    case 'e':
    {
      int count = 1000;
      float mass = 1;
      float radius = min(width,height)/2-50;
      
      float density = (mass*count)/(radius*radius*PI);
      
      for(int i=0;i<count;i++) {
        float angle = random(0,TWO_PI);
        float range = sqrt(random(0,1))*radius;
        
        float ca = cos(angle);
        float sa = sin(angle);
        
        float v = sqrt(density*PI*range);
        
        Part part = new Part(
            width/2+range*ca,
            height/2+range*sa,
            -sa*v,
            ca*v);
        part.setDensity(mass);
        part.setColor(color(255));
        part.setRadius(1);
        
        parts.add(part);
        fg.add(part);
        bh.add(part);
        cg.add(part);
      } 
    }
    break;
    case 'c':
      parts.clear();
      fg.clear();
      bh.clear();
      cg.clear();
    break;
    case 'g':
      //gravity = (mouseX-width/2)/100.;
    break;
  }
}

void keyPressed() {
  handleInput();
}

void draw() {
  
  if(keyPressed) {
    handleInput();
  }
  
  background(0);
  
  bh.run();
  bh.move();
  //bh.applyBoundaries();
  
  cg.handle(width,height);
  
  fg.apply();
  float bound_radius = min(width,height)/2-10;
  for(Part part : parts) {
    
    float dx = width/2-part.getX();
    float dy = height/2-part.getY();
    float force = gravity/((dx*dx+dy*dy)/100+1);
    part.accelerate(dx*force,dy*force);
    
    part.move();
    //part.applyBorders(10,10,width-20,height-20);
    part.applyBorders(width/2,height/2,bound_radius);
  }
  
  noStroke();
  fill(255);
  
  //fg.draw();
  fill(255);
  for(Part part : parts) {
    part.draw();
  }
  
  surface.setTitle("FPS: "+frameRate);
}
