
class CollisionGrid extends ArrayList<Part> {
  
  public static final float r = 3;
  
  private int[][] id_grid;
  private float cell_length;
  
  private HashMap<Part,PartInfo> info = new HashMap<Part,PartInfo>();
  
  public class PartInfo {
    
    private ArrayList<Part> neighborhood = new ArrayList<Part>();
    private int id;
    
    public ArrayList<Part> getNeighborhood() {
      return neighborhood;
    }
    
    public void setID(int value) {
      id = value;
    }
    
    public int getID() {
      return id;
    }
    
  }
  
  public CollisionGrid(float cell_length) {
    this.cell_length = cell_length;
  }
  
  public void handle(float w, float h) {
    resetGrid(w,h);
    for(int i=0;i<1;i++) {
      sortPartsByID();
      applyContactPhysics();
      //moveParts();
      //applyBoundaries();
    }
    //draw();
  }
  
  private void resetGrid(float w, float h) {
    int grid_x = (int)(w/cell_length)+1;
    int grid_y = (int)(h/cell_length)+1;
    if(id_grid==null || id_grid.length!=grid_x || id_grid[0].length!=grid_y) {
      id_grid = new int[grid_x][grid_y];
    }
    for(int i=0;i<grid_x;i++)
    for(int j=0;j<grid_y;j++)
    {
      id_grid[i][j] = -1;
    }
  }
  
  private void sortPartsByID() {
    updatePartIDs();
    sortPartsByID(0,size()-1);
    int last_id = -1;
    for(int i=0;i<size();i++) {
      int id = info.get(get(i)).getID();
      if(last_id!=id) {
        last_id =id;
        int x = last_id%id_grid.length; if(x<0||x>=id_grid.length) continue;
        int y = last_id/id_grid.length; if(y<0||y>=id_grid[0].length) continue;
        id_grid[x][y] = i;
      }
    }
  }
  
  private void applyContactPhysics() {
    for(Part part : this) {
      info.get(part).getNeighborhood().clear();
    }
    for(Part part : this) {
      int x = (int)(part.getX()/cell_length);
      int y = (int)(part.getY()/cell_length);
      for(int i=-1;i<=1;i++)
      for(int j=-1;j<=1;j++)
      {
        int u = x+i; if(u<0||u>=id_grid.length) continue;
        int v = y+j; if(v<0||v>=id_grid[0].length) continue;
        if(id_grid[u][v]!=-1) {
          int cell_id = info.get(get(id_grid[u][v])).getID();
          for(int k=id_grid[u][v];k<size()&&info.get(get(k)).getID()==cell_id;k++) {
            consider(part,get(k)); // consider
          }
        }
      }
    }
    /*
    final float mass = 1;
    for(Part part : this) {
      part.calculatePressure(4*mass/(PI*pow(Part.radius,8)));
    }
    for(Part part : this) {
      part.resetHistory();
    }
    for(Part part : this) {
      part.interact();
    }
    */
    /*
    for(Part part : this) {
      part.calculatePressure();
    }
    */
    for(Part part : this) {
      interact(part);
    }
  }
  
  public void interact(Part part) {
    

    // simulate collisions
    for(Part n : info.get(part).getNeighborhood()) {
      
      float dx = part.getX() - n.getX();
      float dy = part.getY() - n.getY();
      if(!(dx==0 && dy==0)) {
        float dot = dx*dx+dy*dy;
        //float rad = radius*2;
        float rad = r;
        if(dot<rad*rad) {
          
          //final float rigidity = min(this.rigidity,part.rigidity);
          //final float solidness = max(this.solidness,part.solidness);
          
          final float rigidity = 0;
          final float solidness = .5;
          
          if(solidness!=0) {
            float force = max((1-(rad-rigidity)/sqrt(dot))*solidness,-0.05);
            dx *= force;
            dy *= force;
            part.setX(part.getX()-dx);
            part.setY(part.getY()-dy);
            n.setX(n.getX()+dx);
            n.setY(n.getY()+dy);
          }
          
        }
      }
      
    }
    
  }
  private void moveParts() {
    for(Part part : this) {
      part.move();
    }
  }
  
  private void applyBoundaries() {
    // for now...
    final float extension = 10;
    for(Part part : this) {
      part.setX(min(max(part.getX(),extension),id_grid.length*cell_length-extension));
      part.setY(min(max(part.getY(),extension),id_grid[0].length*cell_length-extension));
    }
  }
  
  private void draw() {
    fill(255);
    stroke(255);
    for(Part part : this) {
      part.draw();
    }
  }
  
  private void updatePartIDs() {
    for(Part part : this) {
      updateID(part,id_grid.length,cell_length);
    }
  }
  
  public void consider(Part part, Part neighbor)
  {
    ArrayList<Part> neighborhood = info.get(part).getNeighborhood();
    if(!neighborhood.contains(this)) {
      float dx = part.getX() - neighbor.getX();
      float dy = part.getY() - neighbor.getY();
      float r2 = r*r;
      //float r2 = Part.radius*Part.radius;
      if(dx*dx+dy*dy<r2*4) {
        neighborhood.add(neighbor);
      }
    }
  }
  
  public void updateID(Part part, int grid_x, float cell_length)
  {
    info.get(part).setID(
        ((int)(part.getX()/cell_length))+
        ((int)(part.getY()/cell_length))*grid_x);
  }
  
  private void sortPartsByID(int last, int next) {
    // quick sort
    if(next-last>0) {
      int old_last = last;
      int old_next = next;
      int pivot = info.get(get((last+next)/2)).getID();
      while(next-last>0) {
        while(info.get(get(last)).getID()>pivot) last++;
        while(info.get(get(next)).getID()<pivot) next--;
        Part tmp = get(last);
        set(last,get(next));
        set(next,tmp);
        last++;
        next--;
      }
      sortPartsByID(old_last,next);
      sortPartsByID(last,old_next);
    }
  }
  
  public boolean add(Part part) {
    /*
    for(int i=size()-1;i>=0;i--) {
      float dx = part.getX() - get(i).getX();
      float dy = part.getY() - get(i).getY();
      float r2 = 1;
      //float r2 = Part.radius*Part.radius;
      if(dx*dx+dy*dy<r2) {
        return false;//remove(i);
      }
    }
    return super.add(part);
    */
    info.put(part,new PartInfo());
    return super.add(part);
  }
  
  public void clear() {
    info.clear();
    super.clear();
  }
  
  public void erase(float x, float y, float radius) {
    for(int i=size()-1;i>=0;i--) {
      float dx = x - get(i).getX();
      float dy = y - get(i).getY();
      if(dx*dx+dy*dy<radius*radius) {
        info.remove(get(i));
        remove(i);
      }
    }
  }
  
}
