package Pieces is
	pragma Pure;
	
	type Owner_Type is (Player_1, Player_2, None) with Size=>2;
	type Moved_Signal is (No, Yes) with Size=>2;
	type Piece_Name is (Pawn, Knight, Bishop, Rook, Queen, King, Empty) with Size=>4;
	type Piece_Type is record
		Name : Piece_Name;
		Owner : Owner_Type;
		Has_Moved : Moved_Signal;
	end record 
		with Pack;

	Player_1_Pawn : constant Piece_Type := (Name=>Pawn, Owner=>Player_1, Has_Moved=>No);
	Player_1_Knight : constant Piece_Type := (Name=>Knight, Owner=>Player_1, Has_Moved=>No);
	Player_1_Bishop : constant Piece_Type := (Name=>Bishop, Owner=>Player_1, Has_Moved=>No);
	Player_1_Rook : constant Piece_Type := (Name=>Rook, Owner=>Player_1, Has_Moved=>No);
	Player_1_King : constant Piece_Type := (Name=>King, Owner=>Player_1, Has_Moved=>No);
	Player_1_Queen : constant Piece_Type := (Name=>Queen, Owner=>Player_1, Has_Moved=>No);

	Player_2_Pawn : constant Piece_Type := (Name=>Pawn, Owner=>Player_2, Has_Moved=>No);
	Player_2_Knight : constant Piece_Type := (Name=>Knight, Owner=>Player_2, Has_Moved=>No);
	Player_2_Bishop : constant Piece_Type := (Name=>Bishop, Owner=>Player_2, Has_Moved=>No);
	Player_2_Rook : constant Piece_Type := (Name=>Rook, Owner=>Player_2, Has_Moved=>No);
	Player_2_King : constant Piece_Type := (Name=>King, Owner=>Player_2, Has_Moved=>No);
	Player_2_Queen : constant Piece_Type := (Name=>Queen, Owner=>Player_2, Has_Moved=>No);

	Empty_Piece : constant Piece_Type := (Name=>Empty, Owner=>None, Has_Moved=>Yes);

end Pieces;