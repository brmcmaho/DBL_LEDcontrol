/**
 * This is a model OF A BRAIN!
 */
import java.io.*;
import java.nio.file.*;
import java.util.*;

/**
 * This is the model for the whole brain. It contains four mappings, two of which users should use (Bar and Node)
 * and two which are set up to deal with the physical reality of the actual brain, double bars and double nodes
 * and so on. 
 * @author Alex Maki-Jokela
*/
public static class Model extends LXModel {

  //Note that these are stored in maps, not lists. 
  //Nodes are keyed by their three letter name ("LAB", "YAK", etc)
  //Bars are keyed by the two associated nodes in alphabetical order ("LAB-YAK", etc)
  public final SortedMap<String, Node> nodemap;
  public final SortedMap<String, Bar> barmap;

  public final List<String> bars_in_pixel_order;


  /** 
   * Constructor for Model. The parameters are all fed from Mappings.pde
   * @param nodemap is a mapping of node names to their objects
   * @param barmap is a mapping of bar names to their objects
   * @param bars_in_pixel_order is a list of the physical bars in order of LED indexes which is used for mapping them to LED strings
   */
  public Model(SortedMap<String, Node> nodemap, SortedMap<String, Bar> barmap, List<String> bars_in_pixel_order) {
    super(new Fixture(barmap, bars_in_pixel_order));
    this.nodemap = Collections.unmodifiableSortedMap(nodemap);
    this.barmap = Collections.unmodifiableSortedMap(barmap);
    this.bars_in_pixel_order = Collections.unmodifiableList(bars_in_pixel_order);
  }

  /**
  * Maps the points from the bars into the brain. Note that it iterates through bars_in_pixel_order
  * @param barmap is the map of bars
  * @param bars_in_pixel_order is the list of bar names in order LED indexes
  */
  private static class Fixture extends LXAbstractFixture {
    private Fixture(SortedMap<String, Bar> barmap, List<String> bars_in_pixel_order) {
      for (String barname : bars_in_pixel_order) {
        Bar bar = barmap.get(barname);
        if (bar != null) {
          for (LXPoint p : bar.points) {
            this.points.add(p);
          }
        }
      }
    }
  }

  /**
  * Chooses a random node from the model.
  */
  public Node getRandomNode() {
    //TODO: Instead of declaring a new Random every call, can we just put one at the top outside of everything?
    Random randomized = new Random();
    //TODO: Can this be optimized better? We're using maps so Processing's random function doesn't seem to apply here
    List<String> nodekeys = new ArrayList<String>(this.nodemap.keySet());
    String randomnodekey = nodekeys.get( randomized.nextInt(nodekeys.size()) );
    Node randomnode = this.nodemap.get(randomnodekey);
    return randomnode;
  }


  /**
  * Gets a random bar from the model
  * If I could write getRandomIrishPub and have it work, I would.
  */
  public Bar getRandomBar() {
    //TODO: Instead of declaring a new Random every call, can we just put one at the top outside of everything?
    Random randomized = new Random();
    //TODO: Can this be optimized better? We're using maps so Processing's random function doesn't seem to apply here
    List<String> barkeys = new ArrayList<String>(this.barmap.keySet());
    String randombarkey = barkeys.get( randomized.nextInt(barkeys.size()) );
    Bar randombar = this.barmap.get(randombarkey);
    return randombar;
  }

  /**
  * Returns an arraylist of randomly selected nodes from the model
  * @param num_requested: How many randomly selected nodes does the user want?
  */
  public ArrayList<Node> getRandomNodes(int num_requested) {
    Random randomized = new Random();
    ArrayList<String> returnnodstrs = new ArrayList<String>();
    ArrayList<Node> returnnods = new ArrayList<Node>();
    List<String> nodekeys = new ArrayList<String>(this.nodemap.keySet());
    if (num_requested > nodekeys.size()) {
      num_requested = nodekeys.size();
    }
    while (returnnodstrs.size () < num_requested) {
      String randomnodekey = nodekeys.get( int(randomized.nextInt(nodekeys.size())) );
      if (!(Arrays.asList(returnnodstrs).contains(randomnodekey))) {
        returnnodstrs.add(randomnodekey);
      }
    }
    for (String randnod : returnnodstrs) {
      returnnods.add(this.nodemap.get(randnod));
    }
    return returnnods;
  }

  /**
  * Returns an arraylist of randomly selected bars from the model
  * @param num_requested: How many randomly selected bars does the user want?
  */
  public ArrayList<Bar> getRandomBars(int num_requested) {
    Random randomized = new Random();
    ArrayList<String> returnbarstrs = new ArrayList<String>();
    ArrayList<Bar> returnbars = new ArrayList<Bar>();
    List<String> barkeys = new ArrayList<String>(this.nodemap.keySet());
    if (num_requested > barkeys.size()) {
      num_requested = barkeys.size();
    }
    while (returnbarstrs.size () < num_requested) {
      String randombarkey = barkeys.get( int(randomized.nextInt(barkeys.size())) );
      if (!(Arrays.asList(returnbarstrs).contains(randombarkey))) {
        returnbarstrs.add(randombarkey);
      }
    }
    for (String randbar : returnbarstrs) {
      returnbars.add(this.barmap.get(randbar));
    }
    return returnbars;
  }

  /**
  * Returns a list of LXPoints between two adjacent nodes, in order.
  * e.g. if you wanted to get the nodes in order from ZAP to BUG (reverse alphabetical order) this is what you'd use
  * reminder: by default the points always go in alphabetical order from one node to another
  * returns null if the nodes aren't adjacent.
  * @param node1
  * @param node2
  */
  public List<LXPoint> getOrderedLXPointsBetweenTwoAdjacentNodes(Node node1, Node node2) {
    String node1name = node1.id;
    String node2name = node2.id;
    int reverse_order = node1name.compareTo(node2name); //is this going in reverse order? 
    String barname;
    if (reverse_order<0) {
      barname = node1name + "-" + node2name;
    } else {
      barname = node2name + "-" + node1name;
    }
    Bar ze_bar = this.barmap.get(barname);

    if (ze_bar == null) { //the bar doesnt exist (non adjacent nodes etc)
      return null;
    } else {
      if (reverse_order>0) {
        List<LXPoint> zebarpoints = new ArrayList(ze_bar.points);
        Collections.reverse(zebarpoints);
        return zebarpoints;
      } else {
        return ze_bar.points;
      }
    }
  }
}



/**
 * The Node class is the most useful tool for traversing the brain.
 * @param id: The node id ("BUG", "ZAP", etc)
 * @param x,y,z: The node xyz coords
 * @param ground: Is this node one of the ones on the bottom of the brain?
 * @param adjacent_bar_names: names of bars adjacent to this node
 * @param adjacent_node_names: names of nodes adjacent to this node
 * @param adjacent_bar_names: names of bars adjacent to this node
 * @param id: The node id ("BUG", "ZAP", etc)
*/
public class Node extends LXModel {

  //Node number with module number
  public final String id;

  //Straightforward. If there are multiple physical nodes, this is the xyz from the node with the highest z
  public final float x;
  public final float y;
  public final float z;

  //xyz position of node
  //If it's a double or triple node, returns the coordinates of the highest-z-position instance of the node
  public final boolean ground;
  
  //inner layer or outer layer?
  public final String inner_outer;
  
  //inner layer or outer layer?
  public final String left_right_mid;

  //List of bar IDs connected to node.
  public final List<String> adjacent_bar_names;

  //List of node IDs connected to node.
  public final List<String> adjacent_node_names;


  //Declurrin' some arraylists
  public ArrayList<Bar> adjacent_bars = new ArrayList<Bar>();
  public ArrayList<Node> adjacent_nodes = new ArrayList<Node>();



  
  public Node(String id, float x, float y, float z, List<String> adjacent_bar_names, List<String> adjacent_node_names, boolean ground, String inner_outer, String left_right_mid) {
    this.id=id;
    this.x=x;
    this.y=y;
    this.z=z;
    this.adjacent_bar_names=adjacent_bar_names;
    this.adjacent_node_names = adjacent_node_names;
    this.ground = ground;
    this.inner_outer=inner_outer;
    this.left_right_mid=left_right_mid;
    this.adjacent_bars = new ArrayList<Bar>();
    this.adjacent_nodes = new ArrayList<Node>();
  }



  /**
  * Returns one adjacent node
  */ 
  public Node random_adjacent_node() {
    String randomnodekey = adjacent_node_names.get( int(random(adjacent_node_names.size())) );
    Node returnnod=model.nodemap.get(randomnodekey);
    return returnnod;
  }

  /**
   * Returns an ArrayList of randomly selected adjacent nodes. 
   * @param num_requested: How many random adjacent nodes to return
   */
  public ArrayList<Node> random_adjacent_nodes(int num_requested) {
    ArrayList<String> returnnodstrs = new ArrayList<String>();
    ArrayList<Node> returnnods = new ArrayList<Node>();
    if (num_requested > this.adjacent_node_names.size()) {
      num_requested = this.adjacent_node_names.size();
    }
    while (returnnodstrs.size () < num_requested) {
      String randomnodekey = adjacent_node_names.get( int(random(adjacent_node_names.size())) );
      if (!(Arrays.asList(returnnodstrs).contains(randomnodekey))) {
        returnnodstrs.add(randomnodekey);
      }
    }
    for (String randnod : returnnodstrs) {
      returnnods.add(model.nodemap.get(randnod));
    }
    return returnnods;
  }



  /**
  * Returns one adjacent bar
  */ 
  public Bar random_adjacent_bar() {
    String randombarkey = adjacent_bar_names.get( int(random(adjacent_bar_names.size())) );
    Bar returnbar=model.barmap.get(randombarkey);
    return returnbar;
  }


  /**
   * Returns an ArrayList of randomly selected adjacent bars. 
   * @param num_requested: How many random adjacent bars to return
   */
  public ArrayList<Bar> random_adjacent_bars(int num_requested) {
    ArrayList<String> returnbarstrs = new ArrayList<String>();
    ArrayList<Bar> returnbars = new ArrayList<Bar>();
    if (num_requested > this.adjacent_bar_names.size()) {
      num_requested = this.adjacent_bar_names.size();
    }
    while (returnbarstrs.size () < num_requested) {
      String randombarkey = adjacent_bar_names.get( int(random(adjacent_bar_names.size())) );
      if (!(Arrays.asList(returnbarstrs).contains(randombarkey))) {
        returnbarstrs.add(randombarkey);
      }
    }
    for (String randbar : returnbarstrs) {
      returnbars.add(model.barmap.get(randbar));
    }
    return returnbars;
  }

  //List of adjacent bars
  public ArrayList<Bar> adjacent_bars() {
    ArrayList<Bar> baarrs = new ArrayList<Bar>();
    for (String pnn : this.adjacent_bar_names) {
      baarrs.add(model.barmap.get(pnn));
    }
    return baarrs;
  }
  
  //List of adjacent bars.
  public ArrayList<Node> adjacent_nodes() {
    ArrayList<Node> nods = new ArrayList<Node>();
    for (String pnn : this.adjacent_node_names) {
      nods.add(model.nodemap.get(pnn));
    }
    return nods;
  }

}






/**
 * The Bar class is the second-most-useful tool for traversing the brain.
 * @param id: The bar id ("BUG-ZAP", etc)
 * @param min_x,min_y,min_z: The minimum node xyz coords
 * @param max_x,max_y,max_z: The maximum node xyz coords
 * @param ground: Is this bar one of the ones on the bottom of the brain?
 * @param module_names: Which modules is this bar in? (can be more than one if it's a double-bar)
 * @param node_names: Nodes contained in this bar
 * @param adjacent_bar_names: names of bars adjacent to this node
 * @param adjacent_node_names: names of nodes adjacent to this node
 * @param adjacent_bar_names: names of bars adjacent to this node
*/
public static class Bar extends LXModel {

  //bar name
  public final String id;

  //min and max xyz of bar TODO make these work again
 /* public final float min_x;
  public final float min_y;
  public final float min_z;
  public final float max_x;
  public final float max_y;
  public final float max_z;*/

  //Is it on the ground? (or bottom of brain)
  public final boolean ground;

  //Inner bar? Outer bar? Mid bar?
  public final String inner_outer_mid;
  
  //Left Hemisphere? Right Hemisphere?
  public final String left_right_mid;

  //list of strings of modules that this bar is in.
  public final String module;

  //List of node IDs connected to node.
  public final List<String> node_names;

  //List of bar IDs connected to node.
  public final List<String> adjacent_bar_names;



  //NOTE: There's an issue with the Bar class in which we can't both declare it a private static fixture and have references to
  // the non-static class model to call neighboring nodes, etc. If you know how to resolve this, let me (Maki) know, for now just use
  // the _names functions which are lists of strings and call them from the model.

  //Bar nodes
  public ArrayList<Node> nodes = new ArrayList<Node>();

  //Adjacent nodes to bar
  public ArrayList<Node> adjacent_nodes = new ArrayList<Node>();

  //Adjacent bars to bar
  public ArrayList<Bar> adjacent_bars = new ArrayList<Bar>();


   
  //This bar is open to the public.
  public Bar(String id, List<float[]> points, String module, List<String> node_names, 
  List<String> adjacent_node_names, List<String> adjacent_bar_names, boolean ground, String inner_outer_mid, String left_right_mid) {
    super(new Fixture(points));
    this.id=id;
    this.module=module;
  /*  this.min_x=min_x;
    this.min_y=min_y; //CALCULATE THESE BASED ON THE POINTS
    this.min_z=min_z;
    this.max_x=max_x;
    this.max_y=max_y;
    this.max_z=max_z;*/
    this.inner_outer_mid = inner_outer_mid;
    this.left_right_mid = left_right_mid;
    this.node_names = node_names;
    this.adjacent_bar_names=adjacent_bar_names;
    this.ground = ground;
    this.nodes = new ArrayList<Node>();
    this.adjacent_bars = new ArrayList<Bar>();
    this.adjacent_nodes = new ArrayList<Node>();
  }


   private static class Fixture extends LXAbstractFixture {
    private Fixture(List<float[]> points) {
      for (float[] p : points ) {
        LXPoint point=new LXPoint(p[0], p[1], p[2]);
        this.points.add(point);
      }
    }
  }
  
  //List of adjacent bars
  public ArrayList<Bar> adjacent_bars() {
    ArrayList<Bar> baarrs = new ArrayList<Bar>();
    for (String pnn : this.adjacent_bar_names) {
      baarrs.add(model.barmap.get(pnn));
    }
    return baarrs;
  }
}


