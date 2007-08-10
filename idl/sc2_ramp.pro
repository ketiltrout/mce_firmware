;------------------------------------------------------
;  Name:	sc2_ramp
;  Author: 	David Atkinson
;  Date:	February 2007
; -----------------------------------------------------
;
; Description
; ------------
; program to read in scuba2 ramp_bias data and create 
; pixel map showing the status of each pixel
; ------------------------------------------------------
;
; $Log: sc2_ramp.pro,v $
;

pro sc2_ramp

;-------------------------------------------
my_device = 'X'
SET_PLOT, my_device
; ensure decomposed for colours
device, decompose = 1
;--------------------------------------------
n_cols	=	32
n_rows	=	41

pix_cal		= 3.3 * 1.52e-13 * 1e6 ; DAC vals to uA

chi_level	= 50         
super_level	= 0.8          

;------------------------------------------------
aspect = 0.0
aspect = double(n_cols)/double(n_rows)
;------------------------------------------------
; read in image name
image_name = ''
READ, image_name, PROMPT='Enter file name......................: '

current_data = getenv('CURRENTDATADIR')
if current_data eq '' then begin
  print, 'CURRENTDATADIR not set. Has setup been sourced?'
endif

filepath	= current_data + '/'

image_file    	= filepath+image_name
printf, -1, ''
printf, -1, 'Opening image file:  ', image_file

; values to scale up pixel map image to make more visible
pixel_scale = 10
s_cols = pixel_scale*n_cols
s_rows = pixel_scale*n_rows
spixel_map = intarr(s_cols, s_rows)


; some colours defined.
color_array	= lonarr(6)
color_array(0)	= '000000'x	; black
color_array(1)	= 'ffffff'x	; white
color_array(2)	= '000077'x	; red
color_array(3)	= '007700'x	; green
color_array(4)	= '770000'x	; blue
color_array(5)	= '008888'x	; yellow
grid_color	= 3		; pix map grid color

myct	= 2		; colour table used for pixel map

; pixel map definitions 
zero 	= 0   	; black
unknown = 255	; white
trans	= 88	; red
super	= 24	; green
normal	= 216	; blue/purple
;--------------------------------------
; read in data file
fileline	= string(0)
control		= uintarr(8)
printf, -1, ''
printf, -1, 'Reading in data cube........ '
get_lun, lun1
openr, lun1, image_file

while fileline ne "<CONTROL>" do begin
 readf,lun1,fileline
endwhile

; read in some header lines...

 readf,lun1,fileline 
 readf,lun1,fileline
 nsteps = strmid(fileline,9,4)

 readf,lun1,fileline 
 readf,lun1,fileline  
 readf,lun1,fileline
 readf,lun1,fileline
 readf,lun1,fileline 

 readf,lun1,fileline 
 bias_card = strmid(fileline,12,1)

; print, nsteps
; print, bias_card

; create vectors to hold heater and bias control info.
 heater = uintarr(nsteps)
 bias   = uintarr(nsteps)

; read first (annoying) line of heater/bias block

 readf,lun1,fileline
 for  i=0, 3 do begin
   heater(i) = strmid(fileline,(14+(12*i)),5)
   bias(i) = strmid(fileline,(20+(12*i)),5)
 endfor 

; read in rest of block
 for j=1, (nsteps/4)-1 do begin
   readf,lun1,control
   for k=0, 3 do begin
     heater((4*j)+k) = control(2*k)
     bias((4*j)+k)   = control((2*k)+1)
   endfor 
 endfor

; convert dac units to real values 

heater_power   = ((heater*0.304e-9)^2)*2e12    ; pW
bias_current   = bias*1.0634e-8 * 1e6          ; uA



; show heater or bias ramp depending on mode.

window, 1
!p.multi=[0,1,1,0,1]
if bias_card eq 2 then plot, bias, ystyle=16, $
   xTITLE="Frame Number" , yTITLE="Bias (DAC units)", BACKGROUND='ffffff'x, COLOR='000000'x
if bias_card eq 1 then plot, heater, ystyle=16, $
   xTITLE="Frame Number" , yTITLE="Heater (DAC units)", BACKGROUND='ffffff'x, COLOR='000000'x

; procede to frame data 
while fileline ne "<DATA>" do begin
 readf,lun1,fileline
endwhile


n_frames = nsteps

; create some arrays to hold data
header    	= intarr(43)
data_frame	= fltarr(n_cols,n_rows)
data_cube 	= fltarr(n_frames,n_cols,n_rows)
frame_count	= UINT(0)    ; unsigned integer: can have up to 65536 frames

; for each pixel hold magnitude, phase and goodness of line fit info
; last element identifies the pixels state (zero, unknown, normal, super, trans)

pixel_info	= fltarr(5,n_cols,n_rows) 

; read in the data.

while  ~ eof(lun1) and frame_count lt n_frames do begin
  readf, lun1, header 
  readf, lun1, data_frame
  readf, lun1, datum
  data_cube[frame_count,*,*]= data_frame
  frame_count=frame_count+1
endwhile

printf, -1, '                              done'
printf, -1, frame_count, ' frames read in.'

close, lun1
free_lun, lun1

data_cube = data_cube * pix_cal 

;strip back data cube if needed.
if frame_count lt n_frames then data_cube= data_cube[0:frame_count-1,*,*]

n_frames = frame_count   ; set n frames to actual number of frames read.
;------------------------------------------------------------------------

; initialise some flags

calc_map = 1
select   = 1
plot     = 0

; load colour table
loadct, myct

;---------------------------------------------------
while select ne 0 do begin
;---------------------------------------------------
; --------------------------------------------------
if calc_map eq 1 then begin 
;---------------------------------------------------

  print, ''
  print, 'calculating pixel map......................... '


  if bias_card eq 2 then begin
    xrange = max(bias_current)-min(bias_current)
;    x=findgen(xrange) + min(bias)
     x=bias_current

    for i=0, n_cols-1 do begin
      for j=0, n_rows-1 do begin
        fitresult = linfit(bias_current, data_cube(0:n_frames-1, i, j), CHISQ=goodfit)
        pixel_info(0,i,j)=abs(fitresult(1)*xrange) ; y magnitude = slope*xrange
        pixel_info(1,i,j)=fitresult(1)             ; slope
        pixel_info(2,i,j)=goodfit                  ; goodness of fit

; what kind of pixel?

        if fitresult(1) gt 0.01 then begin 
          pixel_info(3,i,j) = trans 
        endif else begin
          if abs(fitresult(1)*xrange) gt super_level then pixel_info(3,i,j) = super $
          else pixel_info(3,i,j)=normal
        endelse
; override if zero  
        if fitresult(1) eq 0 then pixel_info(3,i,j) = zero
; override if close to zero  
        if abs(fitresult(1)) lt 0.01 then pixel_info(3,i,j) = zero

; override if bad fit.
        if goodfit gt chi_level then pixel_info(3,i,j) = unknown
      endfor
    endfor


  endif else begin
    xrange = max(heater_power)-min(heater_power)
;    x=findgen(xrange) + min(heater)
     x = heater_power

    for i=0, n_cols-1 do begin
      for j=0, n_rows-1 do begin
        fitresult = linfit(heater_power, data_cube(0:n_frames-1, i, j), CHISQ=goodfit)
        pixel_info(0,i,j)=abs(fitresult(1)*xrange) ; magnitude
        pixel_info(1,i,j)=fitresult(1)        ; slope
        pixel_info(2,i,j)=goodfit             ; goodness of fit
  ; what kind of pixel?
        if fitresult(1) gt 0 then begin 
          pixel_info(3,i,j) = trans 
        endif else begin
          if abs(fitresult(1)*xrange) gt super_level then pixel_info(3,i,j) = super $
          else pixel_info(3,i,j)=normal
        endelse
; override if zero  
        if fitresult(1) eq 0 then pixel_info(3,i,j) = zero
; override if bad fit.
        if goodfit gt chi_level then pixel_info(3,i,j) = unknown
      endfor
    endfor

  endelse


  ; rescale super conducting pixels colour to indicate magnitude scale

  super_min = super_level

  ; find max super conducting value.....
  super_max = 0.0
  for i=0, n_cols-1 do begin
    for j=0, n_rows-1 do begin 
      if pixel_info(3,i,j) eq super then begin
        if pixel_info(0,i,j) gt super_max then super_max = pixel_info(0,i,j)
      endif 
    endfor
  endfor


  super_range = super_max-super_min
  super_levels = 30.0   ; #shades of green 
  super_offset = 3.0    ; offset from darkest.

  ; rescale super pixels and copy to layer 4 of pixel info..
  for i=0, n_cols-1 do begin
    for j=0, n_rows-1 do begin
      if pixel_info(3,i,j) eq super then begin
         pixel_info(4,i,j) = super_levels*((pixel_info(0,i,j) - super_min)/(super_range)) + super_offset
      endif else begin
         pixel_info(4,i,j) = pixel_info(3,i,j)
      endelse
    endfor
  endfor 

; scale up pixel plot
    for sci=0, s_cols-1 do begin
      for sri=0, s_rows-1 do begin
; invert y axis for display
        spixel_map(sci, s_rows-sri-1) = pixel_info(4, sci/pixel_scale, sri/pixel_scale) 
    endfor
  endfor

endif

printf, -1, ''
printf, -1, '-------------------------------'
printf, -1, ' Red Pixels    : IN TRANSITION  ' 
printf, -1, ' Green Pixels  : SUPERCONDUCTING' 
printf, -1, ' Purple Pixels : NORMAL         ' 
printf, -1, ' Black Pixels  : ZERO VALUE     '
printf, -1, ' White Pixels  : UNKNOWN        '
printf, -1, '-------------------------------'

;--------------------------------------
; plot pixel map
;---------------------------------------
  window, 2, xsize=s_cols, ysize=s_rows
  device, decompose=0
;  loadct, myct
  tv, spixel_map
  device, decompose=1
;------------------------------------------
; plot grid 
;--------------------------------------------
  for i=0, n_rows do begin
    plots, [0,n_cols*pixel_scale], [i*pixel_scale, i*pixel_scale], /device, color=color_array(grid_color)
  endfor
 
  for j=0, n_cols do begin
    plots, [j*pixel_scale, j*pixel_scale], [0, n_rows*pixel_scale], /device, color=color_array(grid_color)
  endfor
;-------------------------------------------------------------
 
  if plot eq 1 then begin
 
    printf,-1, ''
    printf,-1, '------------------------------------------'
    printf,-1, 'click cursor on pixel to select...........' 
    printf,-1, '------------------------------------------'

    cursor, x1, y1, /device
    current_col = (x1/pixel_scale) + 1
; invert and scale row index
    current_row = n_rows - (y1/pixel_scale)

    printf, -1, 'selected pixel column   :', current_col
    printf, -1, 'selected pixel row      :', current_row
    printf, -1, 'magnitude               :', pixel_info(0,current_col-1, current_row-1)
    printf, -1, 'line fit gradient       :', pixel_info(1,current_col-1, current_row-1)
    printf, -1, 'goodness of fit (chi-sq):', pixel_info(2,current_col-1, current_row-1)
    case pixel_info(3,current_col-1,current_row-1) of 
       zero:       printf, -1, 'Pixel suspected to be   : ZERO VALUE'
       unknown:    printf, -1, 'Pixel suspected to be   : UNKNOWN'
       trans:      printf, -1, 'Pixel suspected to be   : IN TRANSITION' 
       super:      printf, -1, 'Pixel suspected to be   : SUPERCONDUCTING' 
       normal:     printf, -1, 'Pixel suspected to be   : NORMAL' 
    endcase 
                   printf,-1, '------------------------------------------'

    xyouts, (x1-pixel_scale)/double(s_cols), (y1-pixel_scale)/double(s_rows), $
                        '*', ALIGNMENT=0, /NORMAL, CHARSIZE=4, COLOR='ff0000'x

    window, 3, TITLE="pixel plot"
    !p.multi=[0,1,2,0,1]

    plot, data_cube(0:n_frames-1, current_col-1, current_row-1), psym=7, ystyle=16, $
          xTITLE="Frame Number" , yTITLE="Feedback(uA)", BACKGROUND='ffffff'x, COLOR='000000'x
    
    if bias_card eq 2 then begin
      plot, bias_current, data_cube(0:n_frames-1, current_col-1, current_row-1), psym=7, $
      xTITLE="Bias Current (uA)" , yTITLE="Feedback (uA)", BACKGROUND='ffffff'x, COLOR='000000'x, ystyle=16
      fitresult = linfit(bias_current, data_cube(0:n_frames-1, current_col-1, current_row-1), CHISQ=goodfit)
 
      y = x*fitresult(1) + fitresult(0)
      oplot, x, y, color='0000ff'x

    endif else begin   
      plot, heater_power, data_cube(0:n_frames-1, current_col-1, current_row-1), psym=7, $
      xTITLE="Heater Power (pW)" , yTITLE="Feedback(uA)", BACKGROUND='ffffff'x, COLOR='000000'x
      fitresult = linfit(heater_power, data_cube(0:n_frames-1, current_col-1, current_row-1), CHISQ=goodfit)

      y = x*fitresult(1) + fitresult(0)
      oplot, x, y, color='0000ff'x
    endelse 

  endif
    
  printf, -1, ''
  READ, select, PROMPT='(1)Plot Pixel; (2)Change Levels; (3)Export; (0)Exit....: '
  check_range, 0, 3, select

  case select of 
    0: print, 'exiting......'
    1: begin
         calc_map = 0
         plot     = 1
       end
    2: begin
         calc_map = 1;
         plot     = 0;

         print, ''
         print, '----------------------------------------------'
         print, '             CURRENT LEVELS                  '
         print, '----------------------------------------------'
         print, 'fit accuracy  (chi-sq)         : ', chi_level
         print, 'minimum super conducting level : ', super_level
         print, '----------------------------------------------'
         print, ''
         READ, chi_level, PROMPT='Fit Accuracy..................: '
         READ, super_level, PROMPT='Super Conducting Level......: '
       end
    3: begin
         calc_map = 0;
         plot     = 0;
         print, ''
         print, 'exporting data.........'

         openw, lun2, 'export/magnitude.dat', /GET_LUN
         printf, lun2, pixel_info(0,*,*), format = '(32A)'
         free_lun, lun2
     
         openw, lun3, 'export/slope.dat', /GET_LUN
         printf, lun3, pixel_info(1,*,*), format = '(32A)'
         free_lun, lun3

         openw, lun2, 'export/chi-sq.dat', /GET_LUN
         printf, lun2, pixel_info(2,*,*), format = '(32A)'
         free_lun, lun2

         ;--------------------------------------
         ; export pixel map
         ;---------------------------------------

         SET_PLOT, 'PS'
	 DEVICE, /ENCAPSULATED,/COLOR,BITS=8, /LANDSCAPE
         DEVICE, FILENAME='export/pixel_map_ramp.eps'
;         DEVICE, XSIZE=s_cols, YSIZE=s_rows
         tv, spixel_map
          
 
         ;------------------------------------------
         ; plot grid 
         ;--------------------------------------------
         ; !D.X_SIZE seems to be returning wrong val, so just 
         ; get x-axis using !D.Y_SIZE*aspect

         for i=0, n_rows do begin
           plots, [0.0,!D.Y_SIZE*aspect], [i*!D.Y_SIZE/n_rows, i*!D.Y_SIZE/n_rows], /device
         endfor

         for j=0, n_cols do begin
           plots, [j*!D.Y_SIZE*aspect/(n_cols), j*!D.Y_SIZE*aspect/(n_cols)], [0.0, !D.Y_SIZE], /device
         endfor

         ;-------------------------------------------------------------
 
         DEVICE, /close
         SET_PLOT, my_device
         print, '..done'
         print, ''
       end
  endcase 
       
endwhile
print, '................program finished'
end
