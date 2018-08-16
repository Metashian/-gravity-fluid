
class Part {
  
  private float[] x = new float[2]; // x position
  private float[] y = new float[2]; // y position
  private float[] a = new float[2]; // angle
  
  private float density;
  private float radius;
  private color rgb;
  
  public Part(float x, float y, float vx, float vy) {
    setX(x);
    setY(y);
    setXVelocity(vx);
    setYVelocity(vy);
  }
  
  public Part(float x, float y) {
    this(x,y,0,0);
  }
  
  protected void set(float[] x, float value) {
    x[0] = value;
  }
  protected void setVelocity(float[] x, float value) {
    x[1] = x[0]-value;
  }
  protected void move(float[] x) {
    x[0] += -x[1]+(x[1]=x[0]);
  }
  protected float get(float[] x) {
    return x[0];
  }
  protected float getVelocity(float[] x) {
    return x[0]-x[1];
  }
  
  public void setX(float value) { set(x,value); }
  public void setXVelocity(float value) { setVelocity(x,value); }
  public float getX() { return get(x); }
  public float getXVelocity() { return getVelocity(x); }
  
  public void setY(float value) { set(y,value); }
  public void setYVelocity(float value) { setVelocity(y,value); }
  public float getY() { return get(y); }
  public float getYVelocity() { return getVelocity(y); }
  
  public void setAngle(float value) { set(a,value); }
  public void setSpin(float value) { setVelocity(a,value); }
  public float getAngle() { return get(a); }
  public float getSpin() { return getVelocity(a); }
  
  public void setDensity(float value) {
    density = value;
  }
  public float getDensity() {
    return density;
  }
  
  public void setRadius(float value) {
    radius = value;
  }
  public float getRadius() {
    return radius;
  }
  
  public void setColor(color value) {
    rgb = value;
  }
  public color getColor() {
    return rgb;
  }
  
  public void accelerate(float dx, float dy) {
    x[1] -= dx;
    y[1] -= dy;
  }
  
  public void move() {
    move(x);
    move(y);
    move(a);
  }
  
  public void applyBorders(float x, float y, float w, float h) {
    float jitter = random(0,1);
    setX(min(max(getX(),x+getRadius()+jitter),x+w-getRadius()-jitter));
    setY(min(max(getY(),y+getRadius()+jitter),y+h-getRadius()-jitter));
  }
  
  public void applyBorders(float x, float y, float radius) {
    float dx = getX()-x;
    float dy = getY()-y;
    float mag = dx*dx+dy*dy;
    if(radius*radius<mag) {
      float factor = radius/sqrt(mag);
      setX(x+dx*factor);
      setY(y+dy*factor);
    }
  }
  
  public void timeStep() {
    
    move();
  }
  
  public void draw() {
    //float diameter = 2*getRadius();
    //ellipse(getX(),getY(),diameter,diameter);
    fill(rgb);
    rect(getX(),getY(),getRadius(),getRadius());
  }
  
}
