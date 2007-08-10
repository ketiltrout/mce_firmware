;------------------------------------------------------
;  Name:	check_range.pro
;  Author: 	David Atkinson
; -----------------------------------------------------
; Description
; ------------
; program to read parameter and check it is within range. 
; ------------------------------------------------------
;
; $Log: check_range.pro,v $
; 

PRO CHECK_RANGE, min, max, value

  while (value lt min or value gt max) do begin
   printf, -1, '! parameter out of range !'
   printf, -1, 'Min Value:', min 
   printf, -1, 'Max Value:', max 
   READ, value, PROMPT='Re-enter parameter....: '
  endwhile

end
