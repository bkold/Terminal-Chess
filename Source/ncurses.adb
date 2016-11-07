package body NCurses is

	procedure Start_Color_Init is 
	begin
		Start_Color;
		Init_Color_Pair(1, COLOR_WHITE, COLOR_BLACK);
		Init_Color_Pair(2, COLOR_BLACK, COLOR_WHITE);
		Init_Color_Pair(3, COLOR_RED, COLOR_BLACK);
		Setup;
	end Start_Color_Init;

	procedure Pretty_Print_Window (Item : in String) is
	begin
		Print_Window(Item & ASCII.nul);
	end Pretty_Print_Window;

	procedure Pretty_Print_Line_Window (Item : in String) is
	begin
		Print_Window(Item & ASCII.lf & ASCII.nul);
	end Pretty_Print_Line_Window;


end NCurses;