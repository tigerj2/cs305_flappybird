-- Bouncing Ball Video 
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_SIGNED.all;
LIBRARY work;
USE work.de0core.all;

			-- Bouncing Ball Video 

ENTITY ourball IS
Generic(ADDR_WIDTH: integer := 12; DATA_WIDTH: integer := 1);

   PORT(SIGNAL left_click, Clock , vert_sync_int: IN std_logic;
		  Signal  pixel_column, pixel_row :in std_logic_vector(9 downto 0);
        SIGNAL Red,Green,Blue,ball_signal 			: OUT std_logic;
        SIGNAL Horiz_sync,Vert_sync		: OUT std_logic;
		  Signal ball_X,ball_Y : Out  std_logic_vector(9 DOWNTO 0));
END ourball;

architecture behavior of ourball is
	-- Video Display Signals   
	SIGNAL Red_Data, Green_Data, Blue_Data,
			reset, Ball_on, Direction,spawn_flag			   : std_logic;
	--SIGNAL Size 													   : std_logic_vector(9 DOWNTO 0):=CONV_STD_LOGIC_VECTOR(8,10);
	SIGNAL Ball_Y_motion,Left_Click_Motion,Gravity_Motion : std_logic_vector(9 DOWNTO 0);
	SIGNAL Ball_Y_pos												   : std_logic_vector(9 DOWNTO 0):=CONV_STD_LOGIC_VECTOR(240,10);
	SIGNAL Ball_X_pos												   : std_logic_vector(9 DOWNTO 0):=CONV_STD_LOGIC_VECTOR(320,  10);
	
	Constant bottom_boundary									   : std_logic_vector(9 downto 0):=CONV_STD_LOGIC_VECTOR(480,10);
	--hardcoded size in there which is 8
	Constant top_boundary										   : std_logic_vector(9 downto 0):=CONV_STD_LOGIC_VECTOR(8,10);
	Constant Size													   : std_logic_vector(9 downto 0):=CONV_STD_LOGIC_VECTOR(8,10);	

BEGIN 
	-- Colors for pixel data on video signal
	Red <=  '1';
	-- Turn off Green and Blue when displaying ball
	Green <= NOT Ball_on;
	Blue <=  NOT Ball_on;

	RGB_Display_Ball: Process (Ball_X_pos, Ball_Y_pos, pixel_column, pixel_row)
	BEGIN
		-- Set Ball_on ='1' to display ball
		IF ('0' & Ball_X_pos <= pixel_column + Size) AND
		-- only display ball if it is inside screen ?
		(Ball_X_pos + Size >= '0' & pixel_column) AND
		('0' & Ball_Y_pos <= pixel_row + Size) AND
		(Ball_Y_pos + Size >= '0' & pixel_row ) THEN
		
			Ball_on <= '1';
			ball_signal <= '1';
		ELSE
			Ball_on <= '0';
			ball_signal <= '0';

		END IF;
	END process RGB_Display_Ball;

	Move_Ball: process
	BEGIN
		--Dont really need spawn flag I think - For Jason ?		
		spawn_flag <= '1';
		-- Move ball once every vertical sync
		WAIT UNTIL vert_sync_int'event and vert_sync_int = '1';
			 --Dont really need spawn flag I think - For Jason ?
			 IF(spawn_flag = '0') then
					-- Bounce off top or bottom of screen 40 has been hardcoded as top boundary can use constant for it later 
					If(left_click = '1' and (('0' & Ball_Y_pos) >=  CONV_STD_LOGIC_VECTOR(40,10)) ) then
							Left_Click_Motion <= - CONV_STD_LOGIC_VECTOR(15,10);
					else 
							Left_Click_Motion <= - CONV_STD_LOGIC_VECTOR(0,10);
					END IF;
					--minusing size twice to make sure all of the ball stays in screen
					if (('0' & Ball_Y_pos) <=  (bottom_boundary - Size - Size)) THEN
						Gravity_Motion <= CONV_STD_LOGIC_VECTOR(4,10);
					-- Compute next ball Y position
					else
						Gravity_Motion <= CONV_STD_LOGIC_VECTOR(0,10);

					END IF;
			ELSE
					--Dont really need spawn flag I think - For Jason ?
					spawn_flag <= '0';
			END IF;
			--Update y pos of ball
			Ball_Y_pos <= Ball_Y_pos +Gravity_Motion+Left_Click_Motion;
	END process Move_Ball;
	--output the x,y pos of ball x pos might be used for horz movement of ball undecided mechanic
	ball_X<=ball_X_pos;
	ball_Y<= ball_Y_pos;
END behavior;

