with NCurses; use NCurses;
with Board; use Board;
with Ada.exceptions;
with Ada.Text_IO;
with Ada.Strings.Fixed; use Ada.Strings.Fixed;
with GNAT.Command_Line; use GNAT.Command_Line;
with GNAT.Sockets; use GNAT.Sockets;

procedure Chess is
	-- pragma Suppress(All_Checks);

	type Game_Options is (None, Network, Local);

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
	Temp : Byte;
	Game_Status : Game_Options := None;
	Port : Port_Type := 0;
	Is_Host : Boolean := False;
	-- Address_String : String (1..15) := (others=>' ');
	Address_String : String := "192.168.1.53";

	Client  : Socket_Type;
	Address : Sock_Addr_Type;
	Channel : Stream_Access; 

	Receiver   : Socket_Type;
	Connection : Socket_Type;

	Initial_Move : Boolean := True;

begin

	loop
		case Getopt ("l n h p: i:") is
			when 'l' =>
				if Game_Status = None then
					Game_Status := Local;
				else
					Ada.Text_IO.Put_Line("Conflicting agument : '-l'");
					return;
				end if;
			when 'n' =>
				if Game_Status = None then
					Game_Status := Network;
				else
					Ada.Text_IO.Put_Line("Conflicting agument : '-n'");
					return;
				end if;
			when 'p' =>
				Port := Port_Type'Value(Parameter);
			when 'h' =>
				Is_Host := True;
			when 'i' =>
				 Move(Parameter, Address_String);
			when others =>
				exit;
		end case;
	end loop;

	if Game_Status = Network then
		if (Port = 0 or Address_String = 15*' ') then
			Ada.Text_IO.Put_Line("Argument Error");
			return;
		end if;
		if Is_Host then
			Create_Socket (Receiver);
			Set_Socket_Option
				(Socket => Receiver,
				 Option => (Name=>Reuse_Address, Enabled => True));
			Bind_Socket
				(Socket  => Receiver,
				 Address => (Family=>Family_Inet,
							 Addr=>Inet_Addr (Address_String),
							 Port=>Port));
			Listen_Socket (Socket => Receiver);
			Accept_Socket
				(Server  => Receiver,
				 Socket  => Connection,
				 Address => Address);
			-- Put_Line("Client connected from " & Image (Address));
			Channel := Stream (Connection);
		else
			Create_Socket (Client);
			Address.Addr := Inet_Addr(Address_String);
			Address.Port := Port;

			Connect_Socket (Client, Address);
			Channel := Stream (Client);

		end if;
	end if;


	Init_Scr;
	Start_Color_Init;
	Reset_Board;
	Print_Board;

	Game_Loop : loop
		if Initial_Move then
			Initial_Move := False;
			if Is_Host then
				goto HOST_START;
			end if;
		end if;

		Wait_For_Input : loop
			begin
				Get_Variables(Channel);
				Print_Board;
				if Is_Winner in 1..2 then
					Print_and_Clear("Player" & Integer'Image(Is_Winner) & " is the winner");
					goto FINISH;
				end if;
				exit;
			exception
				when others => Print_Board;
			end;
		end loop Wait_For_Input;

		<<HOST_START>>
		Move_Loop : loop
			begin
				Temp := Get_Input;
				if Temp /= 16#FF# then
					Player_Select_Request := (Y=>Position(Temp / 2**4), X=>Position(Temp and 16#0F#));
					Pretty_Print_Line_Window("Selected " & 
						Character'Val(Character'Pos('A') + Integer(Player_Select_Request.X)) & 
						" -" & Integer'Image(Integer(Player_Select_Request.Y) + 1));

					Temp := Get_Input;
					if Temp /= 16#FF# then
						Player_Move_Request := (Y=>Position(Temp / 2**4), X=>Position(Temp and 16#0F#));
						if Player_Select_Request /= Player_Move_Request then
							Move(Player_Select_Request, Player_Move_Request);
							End_Turn;
							Print_Board;
							Set_Variables(Channel);
							if Is_Winner in 1..2 then
								Print_and_Clear("Player" & Integer'Image(Is_Winner) & " is the winner");
								goto FINISH;
							end if;
							exit;
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
		end loop Move_Loop;
	end loop Game_Loop;


	<<FINISH>>
	End_Win;

end Chess;