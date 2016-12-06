package NCurses is
	pragma Pure;

	type Color is new Natural range 0..7;
	type Color_Range is new Natural range 0..1000;
	type Byte is mod 2**8 with Size=>8;

	COLOR_BLACK : constant Color := 0;
	COLOR_RED : constant Color := 1;
	COLOR_GREEN : constant Color := 2;
	COLOR_YELLOW : constant Color := 3;
	COLOR_BLUE : constant Color := 4;
	COLOR_MAGENTA : constant Color := 5;
	COLOR_CYAN : constant Color := 6;
	COLOR_WHITE : constant Color := 7;

	procedure Start_Color_Init;

	function Get_Input return Byte
		with Import, Convention=>C, Link_Name=>"get_mouse_input";
	procedure Start_Color 
		with Import, Convention=>C, Link_Name=>"start_color";
	procedure Attribute_On (Pair : in Natural)
		with Import, Convention=>C, Link_Name=>"attribute_on_c";
	procedure Attribute_Off (Pair : in Natural)
		with Import, Convention=>C, Link_Name=>"attribute_off_c";
	procedure Attribute_On_Bold
		with Import, Convention=>C, Link_Name=>"attribute_on_bold_c";
	procedure Setup
		with Import, Convention=>C, Link_Name=>"setup";
	procedure Attribute_Off_Bold
		with Import, Convention=>C, Link_Name=>"attribute_off_bold_c";
	procedure Init_Color_Pair (Pair : in Natural; Color_1, Color_2 : in Color)
		with Import, Convention=>C, Link_Name=>"init_pair_c";
	procedure Init_Color (Color_Op : in Color; R, G, B : Color_Range)
		with Import, Convention=>C, Link_Name=>"init_color";
	procedure Move_Print_Window (Row, Col : in Natural; Item : in String)
		with Import, Convention=>C, Link_Name=>"mvprintw";
	procedure Print_Window (Item : in String) 
		with Import, Convention=>C, Link_Name=>"printw";
	procedure Pretty_Print_Window (Item : in String) with Inline;
	procedure Pretty_Print_Line_Window (Item : in String) with Inline;
	procedure Init_Scr 
		with Import, Convention=>C, Link_Name=>"initscr";
	procedure Refresh 
		with Import, Convention=>C, Link_Name=>"refresh";
	procedure End_Win 
		with Import, Convention=>C, Link_Name=>"endwin";
	procedure Clear 
		with Import, Convention=>C, Link_Name=>"clear";

	pragma Linker_Options("-lncurses");

end NCurses;