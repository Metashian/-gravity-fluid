
class FluidGrid extends ArrayList<Part> {
  
  private float[][][] field;
  
  private float tile_w;
  private float tile_h;
  
  public FluidGrid(int width, int height) {
    field = new float[4][width][height];
  }
  
  public void setFieldProperty(int x, int y, int i, float value) {
    field[i][x][y] = value;
  }
  public void addFieldProperty(int x, int y, int i, float value) {
    field[i][x][y] += value;
  }
  public void addFieldProperty(float x, float y, int i, float value) {
    int bx = (int)x; float lx = x-bx; int nx = bx+1;
    int by = (int)y; float ly = y-by; int ny = by+1;
    boolean bx_inb = bx>=0 && bx<field[0].length;
    boolean by_inb = by>=0 && by<field[0][0].length;
    boolean nx_inb = nx>=0 && nx<field[0].length;
    boolean ny_inb = ny>=0 && ny<field[0][0].length;
    if(bx_inb && by_inb) { addFieldProperty(bx,by,i,value*(1-lx)*(1-ly)); }
    if(nx_inb && by_inb) { addFieldProperty(nx,by,i,value*lx*(1-ly)); }
    if(bx_inb && ny_inb) { addFieldProperty(bx,ny,i,value*(1-lx)*ly); }
    if(nx_inb && ny_inb) { addFieldProperty(nx,ny,i,value*lx*ly); }
  }
  public float getFieldProperty(int x, int y, int i) {
    return field[i][x][y];
  }
  public float getFieldProperty(float x, float y, int i) {
    int bx = (int)x; float lx = x-bx; int nx = bx+1;
    int by = (int)y; float ly = y-by; int ny = by+1;
    boolean bx_inb = bx>=0 && bx<field[0].length;
    boolean by_inb = by>=0 && by<field[0][0].length;
    boolean nx_inb = nx>=0 && nx<field[0].length;
    boolean ny_inb = ny>=0 && ny<field[0][0].length;
    float n00 = bx_inb && by_inb ? field[i][bx][by] : 0;
    float n10 = nx_inb && by_inb ? field[i][nx][by] : 0;
    float n01 = bx_inb && ny_inb ? field[i][bx][ny] : 0;
    float n11 = nx_inb && ny_inb ? field[i][nx][ny] : 0;
    return (n00*(1-lx)+n10*lx)*(1-ly)+(n01*(1-lx)+n11*lx)*ly;
  }
  
  public void setTileSize(float x, float y) {
    tile_w = x;
    tile_h = y;
  }
  public float getTileWidth() {
    return tile_w;
  }
  public float getTileHeight() {
    return tile_h;
  }
  
  public void projectPartsOnGrid() {
    for(Part part : this) {
      float x = part.getX()/getTileWidth();
      float y = part.getY()/getTileHeight();
      addFieldProperty(x,y,2,1);
      addFieldProperty(x,y,0,part.getXVelocity());
      addFieldProperty(x,y,1,part.getYVelocity());
    }
  }
  
  public void projectGridOnParts() {
    for(Part part : this) {
      float x = part.getX()/getTileWidth();
      float y = part.getY()/getTileHeight();
      part.setXVelocity(getFieldProperty(x,y,0));
      part.setYVelocity(getFieldProperty(x,y,1));
    }
  }
  
  public void calculatePressure() {
    for(int i=0;i<field[0].length;i++) {
    for(int j=0;j<field[0][0].length;j++) {
      float bx = i>0?field[0][i-1][j]:0;
      float px = i<field[0].length-1?field[0][i+1][j]:0;
      float by = j>0?field[1][i][j-1]:0;
      float py = j<field[0][0].length-1?field[1][i][j+1]:0;
      addFieldProperty(i,j,2,((bx-px)+(by-py))/8);
    }
    }
  }
  
  public void applyPressureGradient() {
    for(int i=0;i<field[0].length;i++) {
    for(int j=0;j<field[0][0].length;j++) {
      float bx = i>0?field[2][i-1][j]:0;
      float px = i<field[0].length-1?field[2][i+1][j]:0;
      float by = j>0?field[2][i][j-1]:0;
      float py = j<field[0][0].length-1?field[2][i][j+1]:0;
      addFieldProperty(i,j,0,(bx-px)/10);
      addFieldProperty(i,j,1,(by-py)/10);
    }
    }
  }
  
  public void normalizeVelocities() {
    for(int i=0;i<field[0].length;i++) {
    for(int j=0;j<field[0][0].length;j++) {
      if(field[2][i][j]!=0) {
        field[0][i][j] /= field[2][i][j];
        field[1][i][j] /= field[2][i][j];
      }
    }
    }
  }
  
  public void clearField() {
    for(int i=0;i<3;i++) {
      for(int j=0;j<field[0].length;j++) {
      for(int k=0;k<field[0][0].length;k++) {
        field[i][j][k] = 0;
      }
      }
    }
  }
  
  public void apply() {
    clearField();
    projectPartsOnGrid();
    normalizeVelocities();
    /*
    for(int i=0;i<10;i++) {
      calculatePressure();
      applyPressureGradient();
    }
    */
    applyPressureGradient();
    projectGridOnParts();
  }
  
  public void draw() {
    noStroke();
    for(int i=0;i<field[0].length;i++) {
    for(int j=0;j<field[0][0].length;j++) {
      float pressure = field[2][i][j];
      if(pressure!=0) {
        fill(
            abs(field[0][i][j]*pressure)*32,
            abs(field[1][i][j]*pressure)*32,
            abs(pressure)*64);
        rect(i*tile_w,j*tile_h,tile_w,tile_h);
      }
    }
    }
  }
  
}
