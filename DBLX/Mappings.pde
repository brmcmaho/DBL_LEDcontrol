import java.io.*;
import java.nio.file.*;
import java.util.*;
//import processing.data.Table;

//Builds the brain model
//BEWARE. Lots of csvs and whatnot.
//It's uglier than sin, but the brain is complicated, internally redundant, and not always heirarchical.
//It works.
public Model buildTheBrain(String bar_selection_identifier) { 
  println("AAAAAA");
  String mapping_data_location="mapping_datasets/"+bar_selection_identifier+"/";
  
  SortedMap<String, List<float[]>> barlists = new TreeMap<String, List<float[]>>();
  SortedMap<String, Integer> barstrips = new TreeMap<String, Integer>();
  SortedMap<String, Bar> bars = new TreeMap<String, Bar>();
  SortedMap<String, Node> nodes = new TreeMap<String, Node>();
  SortedMap<Integer, List<String>> stripMap = new TreeMap<Integer, List<String>>();
  for(int i=0; i<144; i++) {
   List<String> stringlist = new ArrayList<String>();
   stripMap.put(i,stringlist);
  }
  boolean newbar;
  boolean newnode;


  println("BBBBBB");
  //Map the pixels to individual LEDs and in the process declare the physical bars.
  //As of 15/6/1 the physical bars are the only things that don't have their own declaration table
  //TODO: This is now mostly handled by the Bar class loading, so clean it up and get rid of the unnecessary parts.
  Table pixelmapping = loadTable(mapping_data_location+"pixel_mapping.csv", "header");
  List<float[]> bar_for_this_particular_led;
  Set barnames = new HashSet();
  Set nodenames = new HashSet();
  List<String> bars_in_pixel_order = new ArrayList<String>();
  for (processing.data.TableRow row : pixelmapping.rows()) {
    int pixel_num = row.getInt("Pixel_i");
    float x = row.getFloat("X");
    float y = row.getFloat("Y");
    float z = row.getFloat("Z");
    String node1 = row.getString("Node1");
    String node2 = row.getString("Node2");
    int strip_num = row.getInt("Strip");
    String bar_name=node1+"-"+node2;
    newbar=barnames.add(bar_name);
    if (newbar){
      bars_in_pixel_order.add(bar_name);
      List<float[]> poince = new ArrayList<float[]>();
      barlists.put(bar_name,poince); 
      barstrips.put(bar_name,strip_num);
    }
    bar_for_this_particular_led = barlists.get(bar_name);
    float[] point = new float[]{x,y,z};
    bar_for_this_particular_led.add(point);
  } 
  logTime("-- Finished loading pixel_mapping");
  
  
  //Load the node info for the model nodes. (ignores double nodes)
  Table node_csv = loadTable(mapping_data_location+"Model_Node_Info.csv","header");
  
  println("CCCCCCC");

  for (processing.data.TableRow row : node_csv.rows()) {
    String node = row.getString("Node");
    float x = row.getFloat("X");
    float y = row.getFloat("Y");
    float z = row.getFloat("Z");
    String csv_neighbors = row.getString("Neighbor_Nodes");
    String csv_connected_bars = row.getString("Bars");
//    String csv_connected_physical_bars = row.getString("Physical_Bars");
//    String csv_adjacent_physical_nodes = row.getString("Physical_Nodes");
    boolean ground;
    String groundstr = row.getString("Ground");
    String inner_outer = row.getString("Inner_Outer");
    String left_right_mid = row.getString("Left_Right_Mid");
    if (groundstr.equals("1")){
      ground=true;
    }
    else{
      ground=false;
    } 

    //all of those were strings - split by the underscores
    List<String> neighbors = Arrays.asList(csv_neighbors.split("_"));
    List<String> connected_bars = Arrays.asList(csv_connected_bars.split("_"));
    Node nod = new Node(node,x,y,z,connected_bars, neighbors, ground,inner_outer, left_right_mid); 
   
    nodes.put(node,nod);
  }
  logTime("-- Finished loading model_node_info");
  
  println("DDDDDD");
  
  //Load the model bar info (which has conveniently abstracted away all of the double node jiggery-pokery)
  Table bars_csv = loadTable(mapping_data_location+"Model_Bar_Info.csv","header");
  
  for (processing.data.TableRow row : bars_csv.rows()) {
    String barname = row.getString("Bar_name");
    println(barname);
    float min_x = row.getFloat("Min_X");
    float min_y = row.getFloat("Min_Y");
    float min_z = row.getFloat("Min_Z");
    float max_x = row.getFloat("Max_X");
    float max_y = row.getFloat("Max_Y");
    float max_z = row.getFloat("Max_Z");
    String csv_nods=row.getString("Nodes");
    String module=row.getString("Module");
    String csv_adjacent_nodes = row.getString("Adjacent_Nodes");
    String csv_adjacent_bars = row.getString("Adjacent_Bars");
    String inner_outer = row.getString("Inner_Outer");
    String left_right_mid = row.getString("Left_Right_Mid");
    boolean ground;
    String groundstr = row.getString("Ground");
    if (groundstr.equals("1")){
      ground=true;
    }
    else{
      ground=false;
    } 
    println("SFWEFEFE");
    //all of those were strings - split by the underscores
    List<String> nods=Arrays.asList(csv_nods.split("_"));
    List<String> connected_nodes = Arrays.asList(csv_adjacent_nodes.split("_"));
    List<String> connected_bars = Arrays.asList(csv_adjacent_bars.split("_"));
    float current_max_z=-10000;
    println("wefewfewfwef");
    List<float[]> usethesepoints = new ArrayList<float[]>();
    println("efwew");
    usethesepoints = barlists.get(barname);
    println("efff");
    int barstripnum=barstrips.get(barname);
    println("wwww");
    Bar barrrrrrr = new Bar(barname,usethesepoints,min_x,min_y,min_z,max_x,max_y,max_z,module,nods,connected_nodes,connected_bars, ground,inner_outer,left_right_mid,barstripnum);
  
    println("ewerrrr");
    bars.put(barname,barrrrrrr);
  }


  println("EEEEEEE");
  //Load the strip info
  Table strips_csv = loadTable(mapping_data_location+"Node_to_node_in_strip_pixel_order.csv","header");
  
  for (processing.data.TableRow row : strips_csv.rows()) {
    int strip = row.getInt("Strip");
    String node1 = row.getString("Node1");
    String node2 = row.getString("Node2");
    String node1node2=node1+"_"+node2;
    println(strip,node1node2);
    List<String> existing_strip_in_stripMap = stripMap.get(strip);
    println(strip,existing_strip_in_stripMap);
    existing_strip_in_stripMap.add(node1node2);
    println(strip,"B");
    stripMap.put(strip,existing_strip_in_stripMap);
    println(strip,"C");
  }



  println("FFFFFF");
  //Map the strip numbers to lengths so that they're easy to handle via  the pixelpusher
  IntList strip_lengths = new IntList();
  int current_strip=0;
  for (String pbarnam : bars_in_pixel_order){
   // String barnam=pbarnam.substring(0,8);
    Bar stripbar = bars.get(pbarnam);
    int strip_num = stripbar.strip_id;
    int pixels_in_pbar = stripbar.points.size();
    if (strip_num!=9999){ //9999 is the value for "there's no actual physical strip set up for this right now but show it in Processing anyways" 
      if (strip_num==current_strip){
        int existing_strip_length=strip_lengths.get(strip_num);
        int new_strip_length = existing_strip_length + pixels_in_pbar;
        strip_lengths.set(strip_num,new_strip_length);
      } else {
        strip_lengths.append(pixels_in_pbar);
        current_strip+=1;
      }
    }
  }

  println("GGGGGG");

  println("Loaded Model bar info");
  
  Model model = new Model(nodes, bars, bars_in_pixel_order, strip_lengths, stripMap);
  // I can haz brain model.
  return model;
}
  
  
  
  
  
  
  
  
