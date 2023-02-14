function playback_record()
	_flip=flip
	__recording_frame=0
	__recording_buttons=btn()
	__recording_buttons_pressed=btnp()
	__recording_first=true
	flip=function()
		_flip()
		__recording_frame+=1
		local b,bp=btn(),btnp()
		if b!=__recording_buttons or bp!=__recording_buttons_pressed then
			__recording_buttons=b
			__recording_buttons_pressed=bp
			printh(__recording_frame..","..__recording_buttons..","..__recording_buttons_pressed,playback_filename,__recording_first)
			__recording_first=false
		end
	end

	menuitem(playback_menu_idx, "end recording",function()
		flip=_flip
		playback_default_menu()
	end)
end

function playback_play()
	function playback_read_line()
		local data=""
		while stat(120) do
			serial(0x800,0x4300,1)
			local c=chr(peek(0x4300))
			if(c=="\n")break
			data..=c
		end
		if(#data==0)return nil
		return data
	end

	local cx,cy=peek2(0x5f28),peek2(0x5f2a)
	while stat(120)==false do
		camera()
		rectfill(10,50,117,78,0)
		rect(10,50,117,74,7)
		print("drop playback file",20,60,7)
		flip()
		camera(cx,cy)
	end

	_flip=flip
	_btn=btn
	_btnp=btnp

	__playback_frame=0
	_btn_data=0
	_btn_p_data=0

	btn=function(b,pl)
		if(b==nil and pl==nil)return _btn_data
		if(pl==nil)pl=0
		return (_btn_data&(1<<(b+pl*6)))>0
	end

	btnp=function(b,pl)
		if(b==nil and pl==nil)return _btn_p_data
		if(pl==nil)pl=0
		return (_btn_p_data&(1<<(b+pl*6)))>0
	end

	_playback_next_frame,_playback_next_btn,_playback_next_btnp=unpack(split(playback_read_line()))

	flip=function()
		_flip()
		__playback_frame+=1

		if __playback_frame>=_playback_next_frame then
			_btn_data,_btn_p_data=_playback_next_btn,_playback_next_btnp
			local line=playback_read_line()
			if(line!=nil)_playback_next_frame,_playback_next_btn,_playback_next_btnp=unpack(split(line))
		end
	end

	menuitem(playback_menu_idx+1, "end playback",function()
		flip=_flip
		btn=_btn
		btnp=_btnp
		playback_default_menu()
	end)
end

function playback_default_menu()
	menuitem(playback_menu_idx, "record playback",function() playback_record() end)
	menuitem(playback_menu_idx+1, "play playback",function() playback_play() end)
end

if(playback_filename==nil)playback_filename="recording"
if(playback_menu_idx==nil)playback_menu_idx=4
playback_default_menu()
