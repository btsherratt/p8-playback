function playback(data,idx)
	if(idx==nil)idx=1
	data=split(data)

	local _flip,_btn,_btnp=flip,btn,btnp
	local _playback_frame,_btn_data,_btn_p_data=0,0,0

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

	flip=function()
		_playback_next_frame,_playback_next_btn,_playback_next_btnp=unpack(data,idx,idx+2)

		_flip()
		_playback_frame+=1

		if _playback_frame>=_playback_next_frame then
			idx+=3
			if idx>#data then
				btn,btnp,flip=_btn,_btnp,_flip
			end

			_btn_data,_btn_p_data=_playback_next_btn,_playback_next_btnp
		end
	end
end