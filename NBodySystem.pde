
abstract static class NBodySystem extends ArrayList<Part> implements Runnable {
  
  public static final float G = 0.01;
  public static final float A = 1;
  
  public static class BarnesHut extends NBodySystem {
    
    private class Branch extends ArrayList<Part> {
      
      private Branch[] branches = new Branch[4];
      
      private float x;
      private float y;
      
      private float mass;
      
      private int part_count;
      
      public boolean hasBranches() {
        return branches[0]!=null;
      }
      
      public float getX() { return x/part_count; }
      public float getY() { return y/part_count; }
      
      public void applyForce(Part part, float x, float y, float mass) {
        float dx = x - part.getX();
        float dy = y - part.getY();
        if(dx!=0 || dy!=0) {
          float force = mass*G/((dx*dx+dy*dy)+1);
          dx *= force;
          dy *= force;
          part.accelerate(dx,dy);
        }
      }
      
      public void applyForces(Part part, float x, float y, float w, float h) {
        if(mass>0) {
          
          float dx = getX() - part.getX();
          float dy = getY() - part.getY();
          
          if(pow(min(w,h),2)/(dx*dx+dy*dy)<pow(precision,2)) {
            applyForce(part,getX(),getY(),mass);
          } else {
            
            if(hasBranches()) {
              w /= 2;
              h /= 2;
              for(int i=0;i<branches.length;i++) {
                branches[i].applyForces(part,x+w*(i%2),y+h*(i/2),w,h);
              }
            } else {
              for(Part leaf : this) {
                NBodySystem.applyForce(part,leaf);
              }
            }
            
          }
          
        }
      }
      
      public void add(Part part, float x, float y, float w, float h) {
        
        this.x += part.getX();
        this.y += part.getY();
        this.mass += part.getDensity();
        part_count++;
        
        if(hasBranches()) {
          if(part.getX()>=x && part.getX()<x+w &&
             part.getY()>=y && part.getY()<y+h) {
            w /= 2;
            h /= 2;
            int i = (int)((part.getX()-x)/w);
            int j = (int)((part.getY()-y)/h);
            branches[i+j*2].add(part,x+w*i,y+h*j,w,h);
          }
        } else {
          add(part);
          if(size()>getMaxBodiesPerBranch()) {
            split(x,y,w,h);
          }
        }
        
      }
      
      public void split(float x, float y, float w, float h) {
        
        for(int i=0;i<branches.length;i++) {
          branches[i] = new Branch();
        }
        
        for(Part part : this) {
          
          this.x -= part.getX();
          this.y -= part.getY();
          this.mass -= part.getDensity();
          part_count--;
          
          add(part,x,y,w,h);
        }
        clear();
        
      }
      
      public void draw(PGraphics g, float x, float y, float w, float h) {
        g.rect(x,y,w,h);
        if(hasBranches()) {
          w /= 2;
          h /= 2;
          for(int i=0;i<branches.length;i++) {
            branches[i].draw(g,x+w*(i%2),y+h*(i/2),w,h);
          }
        }
      }
      
    }
    
    private Branch root;
    
    private float x;
    private float y;
    private float w;
    private float h;
    
    private int branch_max_bodies;
    private float precision;
    
    private void buildTree() {
      root = new Branch();
      for(Part part : this) {
        root.add(part,x,y,w,h);
      }
    }
    
    public void setFrame(float x, float y, float w, float h) {
      this.x = x;
      this.y = y;
      this.w = w;
      this.h = h;
    }
    
    public void applyBoundaries() {
      for(Part part : this) {
        if(part.getX()<x || part.getX()>x+w) { part.setX(Math.min(Math.max(part.getX(),x),x+w)); part.setXVelocity(0); }
        if(part.getY()<y || part.getY()>y+h) { part.setY(Math.min(Math.max(part.getY(),y),y+h)); part.setYVelocity(0); }
      }
    }
    
    public void setMaxBodiesPerBranch(int value) {
      branch_max_bodies = value;
    }
    
    public int getMaxBodiesPerBranch() {
      return branch_max_bodies;
    }
    
    public void setPrecision(float value) {
      precision = value;
    }
    
    public float getPrecision() {
      return precision;
    }
    
    public void run() {
      buildTree();
      for(Part part : this) {
        root.applyForces(part,x,y,w,h);
      }
    }
    
    public void draw(PGraphics g) {
      root.draw(g,x,y,w,h);
    }
    
  }
  
  public static class BruteForce extends NBodySystem {
    
    public void run() {
      for(int i=0;i<size();i++) {
      for(int j=i+1;j<size();j++) {
        applyForce(get(i),get(j));
      }
      }
    }
    
  }
  
  public static void applyForce(Part a, Part b) {
    float dx = a.getX() - b.getX();
    float dy = a.getY() - b.getY();
    if(dx!=0 || dy!=0) {
      
      float force = G/((dx*dx+dy*dy)+1);
      dx *= force;
      dy *= force;
      
      a.accelerate(-dx*b.getDensity(),-dy*b.getDensity());
      b.accelerate(dx*a.getDensity(),dy*a.getDensity());
    }
  }
  
  public void move() {
    for(Part part : this) {
      part.move();
    }
  }
  
  public void draw() {
    for(Part part : this) {
      part.draw();
    }
  }
  
}
