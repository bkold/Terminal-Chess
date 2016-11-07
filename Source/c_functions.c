#include <ncurses.h>

struct c_cordinate_t{
	int x;
	int y;
};

struct c_cordinate_t these_cordinates;

void init_pair_c(int index, int color_1, int color_2){	
	init_pair(index, color_1, color_2);
}

void attribute_on_c(int option){	
	attron(COLOR_PAIR(option)|A_BOLD);
}

void attribute_on_bold_c(){	
	attron(A_BOLD);
}

void attribute_off_bold_c(){	
	attroff(A_BOLD);
}

void attribute_off_c(int option){	
	attroff(COLOR_PAIR(option)|A_BOLD);
}

void setup(){
	mmask_t old;
	noecho ();
	cbreak ();
	keypad (stdscr, TRUE);
	mousemask (ALL_MOUSE_EVENTS | REPORT_MOUSE_POSITION, &old);
}

struct c_cordinate_t *get_mouse_input(){
	int ch = getch ();
	if (ch == KEY_MOUSE){
		MEVENT event;
		if(getmouse (&event) == OK){
			//modify input and return a packed int
			/*
				3, 1	75, 1

				3, 33	75, 33
			*/
			if(event.x <= 75 && event.x >= 3){
				if(event.y <= 33 && event.y >= 1){
					these_cordinates.x = (event.x - 4) / 9;
					these_cordinates.y = 7 - (event.y - 2) / 4;
					return &these_cordinates;
				}
			}
		}
	}
	these_cordinates.x = -1;
	these_cordinates.y = -1;
	return &these_cordinates;
}
