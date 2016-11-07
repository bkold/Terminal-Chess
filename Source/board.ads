with Ada.Text_IO;
with Pieces; use Pieces;
package Board is
	pragma Suppress(All_Checks);
	
	Collision : exception;
	Empty_Zone : exception;
	Not_Allowed : exception;
	Unknown : exception;

	-- Y
	-- | | | | |
	-- | | | | |
	-- | | | | |
	-- |________X
	type Position is new Integer range 0..7 with Size=>4;
	type Cordinate_Type is record
		X : Position;
		Y : Position;
	end record
		with Pack;

	procedure Reset_Board;
	procedure Print_Board;
	procedure Move (From, To : in Cordinate_Type);

	procedure End_Turn;

	function Is_Winner return Integer;
	
private
	package Pieces_IO is new Ada.Text_IO.Enumeration_IO(Piece_Name);
	use Pieces_IO;

	type Unit is new Integer range -1..1 with Size=>4;
	type Unit_Position is record
		X, Y : Unit;
	end record;

	type Column is array (Position) of Piece_Type;
	type Board_Type is array (Position) of Column;
	-- Our_Board(Y)(X)
	type Player_Counter is mod 2;
	type King_Status_Array is array (0..1) of Cordinate_Type with Pack;

	Turn : Player_Counter := 0;
	Our_Board : Board_Type;
	King_Status : King_Status_Array;
	Last_Moved : Cordinate_Type;

	Starting_Backrow_Order : constant array (1..2) of Column :=
		((Player_1_Rook, Player_1_Knight, Player_1_Bishop, Player_1_King, Player_1_Queen, Player_1_Bishop, Player_1_Knight, Player_1_Rook),
		 (Player_2_Rook, Player_2_Knight, Player_2_Bishop, Player_2_King, Player_2_Queen, Player_2_Bishop, Player_2_Knight, Player_2_Rook));

	function "+" (Left: in Cordinate_Type; Right : Unit_Position) return Cordinate_Type is
		(Position(Integer(Left.X) + Integer(Right.X)), Position(Integer(Left.Y) + Integer(Right.Y)));
	function "&" (Left, Right : in Cordinate_Type) return Unit_Position;

	procedure Take_Space (From, To : in Cordinate_Type);

	procedure Castle (From, To : in Cordinate_Type);

end Board;