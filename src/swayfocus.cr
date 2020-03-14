require "json"
require "option_parser"

version = "0.1"
puts ""

class Window
    JSON.mapping({
        id: UInt32,
        name: String,
        wtype: {type: String, key: "type"},
        app_id: {type: String, default: ""},
        wclass: {type: String, key: "class", default: ""},
        marks: {type: Array(String), default: [] of String},
        nodes: {type: Array(Window), default: [] of Window},
        focused: {type: Bool, default: false}
    })

    def clear_nodes
        @nodes = [] of Window
    end
end

def node_loop (root : Window)
    list = [] of Window
    root.nodes.each do |node|
        if(node.wtype == "con")
            list << node
        elsif(node.nodes != [] of Window)
            list.concat(node_loop(node))
        end
    end
    return list
end

client_tree = Window.from_json(`swaymsg -t get_tree`)

if(client_tree.wtype != "root")
    puts "Malformed client tree."
    exit(1)
end

window_list = node_loop(client_tree)

def parse_marks(marks : Array(String), mark : String)
    res : Bool = false
    marks.each do |cm|
    	if(cm.includes? mark)
    	   res = true
    	end
    end
    return !res
end

def check_type
end

cycle = false
OptionParser.parse do |parser|
    parser.banner = "Usage: swayfocus [OPTIONS]"
    
    parser.on "-v", "--version", "Show Version" do
        puts version
        exit(0)
    end
    
    parser.on "-h", "--help", "Show Help" do
        puts parser
        exit(0)
    end

    parser.on "-p", "--print", "Print window names and exit" do
        window_list.each do |win|
            puts win.name
        end
        exit(0)
    end

    parser.on "-c", "--cycle", "Cycle through all matching windows in order, instead of selecting the first in the list" do
    	cycle = true
    end

    parser.on "-n WNAME", "--name=WNAME", "Match against window name" do |wname|
	window_list.reject! {|w| !w.name.includes? wname}
    end

    parser.on "-m WMARK", "--mark=WMARK", "Match against window mark" do |wmark|
    	window_list.reject! {|w| parse_marks(w.marks, wmark)}
    end

    parser.on "-t WTYPE", "--type=WTYPE", "Match against window type (app_id for wayland, class for xwayland)" do |wtype|
    	window_list.reject! {|w| !(w.app_id.includes?(wtype) || w.wclass.includes?(wtype))}
    end
    
    parser.invalid_option do |flag|
        STDERR.puts "#{flag} is not a valid option"
        STDERR.puts ""
        STDERR.puts parser
        exit(1)
    end

    parser.missing_option do |flag|
    	STDERR.puts "#{flag} requires an argument"
    	STDERR.puts ""
    	STDERR.puts parser
    	exit(1)
    end

    parser.unknown_args do
    	exit(0)
    end
end

if(window_list == [] of Window)
    puts "No matching window."
    exit(1)
end
if(cycle)
    while(!window_list[window_list.size - 1].focused)
    	window_list.push window_list[0]
    	window_list.delete_at(0)
    end
end

Process.exec("swaymsg", [%<[con_id=>+window_list[0].id.to_s+%<]>,"focus"])
