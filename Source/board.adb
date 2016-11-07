with NCurses; use NCurses;
package body Board is
	
	procedure Reset_Board is
	begin -- Reset_Board
		for I of Our_Board loop
			I := (others=>Empty_Piece);
		end loop;

		for I of Our_Board(Position'First + 1) loop
			I := Player_1_Pawn;
		end loop;
		Our_Board(Position'First) := Starting_Backrow_Order(1);

		for I of Our_Board(Position'Last - 1) loop
			I := Player_2_Pawn;
		end loop;
		Our_Board(Position'Last) := Starting_Backrow_Order(2);

		King_Status(0) := (X=>3, Y=>0);
		King_Status(1) := (X=>3, Y=>7);
		Last_Moved := (0, 0);

	end Reset_Board;

	procedure Print_Board is
		Small_String : String(1..6);
	begin -- Print_Board
		Clear;
		Attribute_On(1);
		Pretty_Print_Line_Window(Owner_Type'Image(Owner_Type'Val(Turn)));
		for I in reverse Our_Board'Range loop
			Pretty_Print_Line_Window("   -------------------------------------------------------------------------");
			Pretty_Print_Line_Window("   |        |        |        |        |        |        |        |        | ");
			Pretty_Print_Window(Integer'Image(Integer(I) + 1) & " | ");
			for J of Our_Board(I) loop
				if J /= Empty_Piece then
					if J.Owner = Player_1 then
						Attribute_On(2);
					end if;
					Put(To=>Small_String, Item=>J.Name);
					Pretty_Print_Window(Small_String);
					Attribute_On(1);
				else
					Pretty_Print_Window("      ");
				end if;
				Pretty_Print_Window(" | ");
			end loop;
			Pretty_Print_Line_Window(ASCII.lf & "   |        |        |        |        |        |        |        |        | ");
		end loop;
		Pretty_Print_Line_Window("   -------------------------------------------------------------------------");
		Pretty_Print_Line_Window("       A        B        C        D        E        F        G        H      ");
		Refresh;
	end Print_Board;

	procedure Move (From, To : in Cordinate_Type) is
	begin -- Move

		if Our_Board(From.Y)(From.X).Owner /= Owner_Type'Val(Turn) then -- check if it's their piece
			raise Not_Allowed;
		end if;

		case Our_Board(From.Y)(From.X).Name is
			-- check to see if move if possible
			when Pawn => --since the pawn move logic is so complex, it's best to do it all here
						declare
							Turn_Test : Integer;
							function "+" (Left: in Position; Right : in Integer) return Position is
								(Position(Integer(Left) + Right));
						begin
							Turn_Test := (if Turn = 0 then -1 else 1);

							if Integer(From.X - To.X) = 0 then -- advance
								if Our_Board(To.Y)(To.X).Owner = None and -- can't attack forward
									then (Integer(From.Y - To.Y) = Turn_Test or (Integer(From.Y - To.Y) = Turn_Test*2 and Our_Board(From.Y)(From.X).Has_Moved = No and Our_Board(To.Y + Turn_Test)(To.X).Owner = None)) then --check if move is valid
										Take_Space(From, To);
								else
									raise Not_Allowed;
								end if;
							elsif Integer(From.X - To.X) in -1..1 then -- attack move
								if Integer(From.Y - To.Y) = Turn_Test then --check if move is valid
									if Our_Board(To.Y)(To.X).Owner /= None then
											Take_Space(From, To);			
									elsif Our_Board(Last_Moved.Y)(Last_Moved.X).Name = Pawn and -- en passent
										then Last_Moved = (X=>To.X, Y=>To.Y + Turn_Test) then
											Our_Board(Last_Moved.Y)(Last_Moved.X) := Empty_Piece;
											Take_Space(From, To);
									else
										raise Not_Allowed;
									end if;
								else
									raise Not_Allowed;
								end if;					
							else
								raise Not_Allowed;
							end if;
						end;
			when Knight =>
						if abs(From.X - To.X) = 1 and
							then abs(From.Y - To.Y) = 2 then
								Take_Space(From, To);
						elsif abs(From.X - To.X) = 2 and 
							then abs(From.Y - To.Y) = 1 then
								Take_Space(From, To);
						else
							raise Not_Allowed;
						end if;
				
			when Rook =>
						if (From.X = To.X and From.Y /= To.Y) or 
							else (From.Y = To.Y and From.X /= To.X) then
								Take_Space(From, To);
						else
							raise Not_Allowed;
						end if;

			when Bishop =>
						if abs(From.X - To.X) = abs(From.Y - To.Y) then
								Take_Space(From, To);
						else
							raise Not_Allowed;
						end if;

			when Queen =>
						if (From.X = To.X and From.Y /= To.Y) or 
							else (From.Y = To.Y and From.X /= To.X) then
								Take_Space(From, To);
						elsif abs(From.X - To.X) = abs(From.Y - To.Y) then
							Take_Space(From, To);
						else
							raise Not_Allowed;
						end if;

			when King =>
						if To.X - From.X in -1..1 and To.Y - From.Y in -1..1 then
							Take_Space(From, To);
						elsif abs(To.X - From.X) = 2 and To.Y = From.Y then
							Castle(From, To);
						else
							raise Not_Allowed;
						end if;
			
			when others => raise Empty_Zone;
		end case;
	end Move;

	procedure End_Turn is
	begin
		Turn := Turn + 1;
	end End_Turn;

	Procedure Castle (From, To : in Cordinate_Type) is
		Rook_Position : Position;
		Loop_Range_Start : Position;
		Loop_Range_End : Position;
	begin
		if From.X > To.X then 
			Rook_Position := 0;
			Loop_Range_Start := 1;
			Loop_Range_End := 2;
		else 
			Rook_Position := 7;
			Loop_Range_Start := 4;
			Loop_Range_End := 6;
		end if;

		if Our_Board(From.Y)(From.X).Has_Moved = No and 
			then Our_Board(From.Y)(Rook_Position).Has_Moved = No then
				if (for all I of Our_Board(From.Y)(Loop_Range_Start..Loop_Range_End) => I.Name = Empty) then
					if Rook_Position = 0 then
						Take_Space((X=>Rook_Position, Y=>From.Y), (X=>Loop_Range_End, Y=>From.Y)); -- Move Rook;
					else
						Take_Space((X=>Rook_Position, Y=>From.Y), (X=>Loop_Range_Start, Y=>From.Y)); -- Move Rook;
					end if;
					Take_Space(From, To); -- Move King
				else
					raise Collision;
				end if;
		else
			raise Not_Allowed;
		end if;

	end Castle;

	function Is_Winner return Integer is
	begin
		if Our_Board(King_Status(0).Y)(King_Status(0).X).Name /= King and 
			Our_Board(King_Status(0).Y)(King_Status(0).X).Owner /= Player_1 then
				return 2;
		elsif Our_Board(King_Status(1).Y)(King_Status(1).X).Name /= King and 
			Our_Board(King_Status(1).Y)(King_Status(1).X).Owner /= Player_2 then 
				return 1;
		else
			return 0;
		end if;
	end Is_Winner;

	--physically move, checks for collisions
	procedure Take_Space (From, To : in Cordinate_Type) is
		Old_Piece : constant Piece_Type := Our_Board(From.Y)(From.X);
		--From acts as old spot, since 'in'
		Temp_Position : Cordinate_Type := From;
		Step_Size : Unit_Position;
	begin
		if Our_Board(To.Y)(To.X).Owner = Owner_Type'Val(Turn) then
			raise Collision;
		end if;

		case Our_Board(From.Y)(From.X).Name is
			when Pawn..Knight =>
					Our_Board(From.Y)(From.X) := Empty_Piece;
					Our_Board(To.Y)(To.X) := Old_Piece;

			when Bishop..Queen => 
					Step_Size := To & From;
					while Temp_Position /= To loop -- walk the line
						Temp_Position := Temp_Position + Step_Size;
						exit when Our_Board(Temp_Position.Y)(Temp_Position.X) /= Empty_Piece;
					end loop;
					
					if Temp_Position = To then
						Our_Board(From.Y)(From.X) := Empty_Piece;
						Our_Board(To.Y)(To.X) := Old_Piece;
					else
						raise Collision;
					end if;
			
			when King =>
					Our_Board(From.Y)(From.X) := Empty_Piece;
					Our_Board(To.Y)(To.X) := Old_Piece;
					King_Status(Integer(Turn)) := To;

			when Empty =>
					raise Unknown;
		end case;
		Our_Board(To.Y)(To.X).Has_Moved := Yes;
		if Our_Board(To.Y)(To.X).Name = Pawn and then (To.Y = 7 or To.Y = 0) then
			Our_Board(To.Y)(To.X).Name := Queen;
		end if;
		Last_Moved := To;

	end Take_Space;

	function "&" (Left, Right : in Cordinate_Type) return Unit_Position is
		Local : Unit_Position := (0, 0);
	begin
		if Left.X - Right.X > 0 then
			Local.X := 1;
		elsif Left.X - Right.X < 0 then
			Local.X := -1;
		end if;

		if Left.Y - Right.Y > 0 then
			Local.Y := 1;
		elsif Left.Y - Right.Y < 0 then
			Local.Y := -1;
		end if;
		return Local;
	end "&";

end Board;
