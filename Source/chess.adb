with NCurses; use NCurses;
with Board; use Board;
with Ada.exceptions;
with Ada.Text_IO;
procedure Chess is

	procedure Print_and_Clear (Item : in String) with Inline is
	begin
		Attribute_On(3);
		Pretty_Print_Line_Window(Item);
		Refresh;
		delay 1.0;
		Print_Board;
	end Print_and_Clear;

	Player_Select_Request : Cordinate_Type;
	Player_Move_Request : Cordinate_Type;
	Temp_Cordinates : C_Cordinate_Type_Pointer;
	
begin
	Init_Scr;
	Start_Color_Init;
	Reset_Board;
	Print_Board;

	Game_Loop : loop
		begin
			Temp_Cordinates := Get_Input;
			if Temp_Cordinates.X /= -1 then
				Player_Select_Request.X := Position(Temp_Cordinates.X);
				Player_Select_Request.Y := Position(Temp_Cordinates.Y);

				Pretty_Print_Line_Window("Selected " & 
					Character'Val(Integer(Player_Select_Request.X) + 65) & 
					" -" & Integer'Image(Integer(Player_Select_Request.Y) + 1));

				Temp_Cordinates := Get_Input;
				if Temp_Cordinates.X /= -1 then
					Player_Move_Request.X := Position(Temp_Cordinates.X);
					Player_Move_Request.Y := Position(Temp_Cordinates.Y);

					if Player_Select_Request /= Player_Move_Request then
						Move(Player_Select_Request, Player_Move_Request);
						End_Turn;
						Print_Board;
						if Is_Winner in 1..2 then
							Print_and_Clear("Player" & Integer'Image(Is_Winner) & " is the winner");
							exit;
						end if;
					else
						Print_and_Clear("Same Position");
					end if;
				else
					Print_and_Clear("Input not in range");
				end if;
			else 
				Print_and_Clear("Input not in range");
			end if;
		exception
			when Collision => Print_and_Clear("Piece in the way");
			when Empty_Zone => Print_and_Clear("No piece there");
			when Not_Allowed => Print_and_Clear("Move is illegal");
			when Error : Others => 
				End_Win;
				Ada.Text_IO.Put("Unexpected Exception : " & Ada.Exceptions.Exception_Information(Error));
				exit;
		end;
	end loop Game_Loop;

	End_Win;

end Chess;