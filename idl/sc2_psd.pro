;------------------------------------------------------
;  Name	:	sc2_psd
;  Author: 	David Atkinson
;  Date:	August 2007
;  (evolution of sc2_time_v3)
; -----------------------------------------------------
;
; Description
; ------------
; This program reads in a scuba2 data file containing
; a series of frames.
;  
; Spectra are calculated for each pixel and can be plotted/exported.
;
; A mean value is calculated in a frequency window for each  
; pixel spectra and plotted to a pixel map (linear, log, or threshold options).   
; --------------------------------------------------------
; 
; $Log: sc2_psd.pro,v $
;

pro sc2_time_v3

my_device = 'X'
SET_PLOT, my_device

; ensure decomposed for colours
device, decompose = 1

current_data = getenv('CURRENTDATADIR')
if current_data eq '' then begin
  print, 'CURRENTDATADIR not set. Has setup been sourced?'
endif


;------------------------------------------------
n_cols		=	32
n_rows		=	41

filepath	= current_data + '/'
exportpath	= current_data + '/analysis'

; info on file location
mce_clock	= 50E6		; MCE clock speed
frame_rate	= DOUBLE(0)
fileline	= STRING(0)
frame_count	= UINT(0)    ; unsigned integer: can have up to 65536 frames
session_id	= UINT(9999)
pixel_color	= 1
grid_color	= 3
pix_cal		= 3.3 * 1.52e-13 ; DAC vals to uA
color_array	= lonarr(6)
color_array(0)	= '000000'x	; black
color_array(1)	= 'ffffff'x	; white
color_array(2)	= '000077'x	; red
color_array(3)	= '007700'x	; green
color_array(4)	= '770000'x	; blue
color_array(5)	= '008888'x	; yellow

export_index	= 0
;--------------------------------------------------

; read in image name
image_name = ''
READ, image_name, PROMPT='Enter file name......................:'

image_file    	= filepath+image_name
printf, -1, ''
printf, -1, 'Opening image file:  ', image_file

get_lun, lun1
openr, lun1, image_file

; read in number of frames
printf, -1, ''
READ, n_frames,   PROMPT='Enter number of frames to process....: '
check_range, 1, 65536, n_frames


; read in data rate
printf, -1, ''
READ, data_rate,   PROMPT='Enter data rate....: '
check_range, 1, 50, data_rate


; read session id time tag
printf, -1, ''
READ, session_id,   PROMPT='Enter 4-digit session id to tag export files....: '



printf, -1, ''
printf, -1, 'Reading in data cube........ '

; -----------------------------------------------------------------
; create arrays to hold read in data.
 
header    	= intarr(43)
data_frame	= fltarr(n_cols,n_rows)
data_cube 	= fltarr(n_frames,n_cols,n_rows)
;---------------------------------------------------------------------------
; read in data from file......

while  ~ eof(lun1) and frame_count lt n_frames do begin

  readf, lun1, header 
  readf, lun1, data_frame
  readf, lun1, datum
  data_cube[frame_count,*,*]= data_frame
  frame_count=frame_count+1

endwhile

printf, -1, '............................done'
printf, -1, frame_count, ' frames read in.'

close, lun1
free_lun, lun1

;strip back data cube if needed.
if frame_count lt n_frames then data_cube= data_cube[0:frame_count-1,*,*]

n_frames = frame_count   ; set n frames to actual number of frames read.

;------------------------------------------------------------------------
spectra_cube = fltarr((n_frames/2)+1,n_cols,n_rows)

n_samps		=  128
n_hrows		= 41
rate_fudge	= data_rate

frame_rate = mce_clock/(n_samps*n_hrows*rate_fudge)
printf, -1, ''

;frame_rate	= 980.0

printf, -1, 'frame rate =    ', frame_rate 


data_cube = data_cube * pix_cal  * 1e6  ; uAmps

; --------------------------------------------------
; calculate spectra.....
printf, -1, ''
printf, -1, '......calculating spectra through data cube'

df=frame_rate/float(n_frames)

for i=0, n_cols-1 do begin

  for j=0, n_rows-1 do begin

  pixel_data	  = (data_cube(0:n_frames-1, i, j))
  
  dum=poly_fit(findgen(n_frames),pixel_data,3,ysub) ; cubic fit
  
  
  ;dc_level	  = mean(pixel_data)
  ;fft_data	  = pixel_data-dc_level
  ;fft_result 	  = FFT(fft_data)
  fft_result      = fft(hanning(n_frames)*(pixel_data-ysub),-1)
  spectra	  = ((ABS(fft_result[0:n_frames/2]^2))/df)^.5
  
  spectra_cube[*,i,j] = spectra * 1e6  ; pA/root(Hz)
  endfor

endfor


; ---------------------------------------------------------------
; create x-axis for spectra data

frame_time = 1/frame_rate
xfreq=findgen((n_frames/2)+1) / (n_frames * frame_time)
xfreq_max = max(xfreq)

; --------------------------------------------------------------
; some flags for while loop...

plot 		= 1
export 		= 0
select		= 0
map_type	= 2
show_pix	= 1
show_grid	= 1

; intialise some values.
current_row	= 1
current_col	= 1
oplot_row	= 1
oplot_col	= 1
oplot_sel	= 0
cut_level 	= 1E8
f_min		= 10   
f_max		= 20
fwindow = where(xfreq gt f_min and xfreq lt f_max)
fstart  = min(fwindow)		; start xfreq index position of window
fstop	= max(fwindow)		; stop xfreq index position of window

pixel_map	= intarr(n_cols,n_rows)
pixel_mean	= fltarr(n_cols,n_rows)
cut_plot        = fltarr((n_frames/2)+1)
;linear_range	= 100
;linear_cut = 0.0

; f window tracers
xf_lo		= fltarr(2)	
xf_hi		= fltarr(2)	
yf		= fltarr(2)
yf(0)		=  1e0
yf(1)		=  1e20

; values to scale up pixel map image to make more visible
pixel_scale = 10
s_cols = pixel_scale*n_cols
s_rows = pixel_scale*n_rows
spixel_map = intarr(s_cols, s_rows)
mpixel_map = fltarr(s_cols, s_rows)

; initialse cursor co-ordinates
x1		= (current_col-1)*pixel_scale
x2		= (oplot_col-1)*pixel_scale
y1		= (n_rows-current_row)*pixel_scale
y2		= (n_rows-oplot_row)*pixel_scale


SET_PLOT, my_device  ; set for display

;DEVICE, DECOMPOSE=0
;loadct, 0

;---------------------------------------------------------------------
; main body of program
;---------------------------------------------------------------------

while plot ne 0 do begin 
   
  
 if export eq 1 then DEVICE, FILENAME=STRCOMPRESS(exportpath +'/sc2_pixplot_'+string(session_id)+'_'+string(export_index)+'.ps', /REMOVE_ALL), /LANDSCAPE

 if export eq 0 then window, 1, TITLE="pixel plot"
 !p.multi=[0,1,2,0,1]

; -------------------------------------------------------------  
; temporal pixel plot
; ------------------------------------------------------------

 if oplot_sel eq 0 then begin

    pixel_data	= (data_cube(0:n_frames-1, current_col-1, current_row-1))        
    plot, pixel_data, xTITLE="Samples" , yTITLE="Magnitude  uA", ystyle=16, $
                      BACKGROUND='ffffff'x, COLOR='000000'x, /NODATA
    
    if export eq 0 then oplot, pixel_data, COLOR='ff0000'x $
       else oplot, pixel_data, COLOR='000000'x
    
    pixel1_str = 'pixel: (' + string(current_col) + ',' + string(current_row)+')'
    pixel1_str = STRCOMPRESS (pixel1_str, /REMOVE_ALL)

    if export eq 0 then $
    xyouts, 0.02, 0.49, pixel1_str, ALIGNMENT=0, /NORMAL, CHARSIZE=1.2, COLOR='ff0000'x $
    else xyouts, 0.02, 0.49, pixel1_str, ALIGNMENT=0, /NORMAL, CHARSIZE=1.2, COLOR='000000'x

    pixel_max   = max(pixel_data) 
    pixel_min   = min(pixel_data)
  
 endif else begin
   
    oplot_pmax = max(data_cube(0:n_frames-1, oplot_col-1, oplot_row-1))
    oplot_pmin = min(data_cube(0:n_frames-1, oplot_col-1, oplot_row-1))
     
    if oplot_pmax gt pixel_max then pixel_max = oplot_pmax
    if oplot_pmin lt pixel_min then pixel_min = oplot_pmin
    
    pixel_data	= (data_cube(0:n_frames-1, current_col-1, current_row-1))

    plot, pixel_data, xTITLE="Samples" , yTITLE="Magnitude uA", YRANGE=[pixel_min, pixel_max], $
                      BACKGROUND='ffffff'x, COLOR='000000'x, /NODATA

    if export eq 0 then oplot, pixel_data, COLOR='ff0000'x $
    else oplot, pixel_data, COLOR='000000'x
  
    pixel_data	= (data_cube(0:n_frames-1, oplot_col-1, oplot_row-1))

    if export eq 0 then begin 
      oplot, pixel_data, COLOR='0000ff'x, LINESTYLE=0
      pixel1_str = 'pixel: (' + string(current_col) + ',' + string(current_row)+')'
      pixel2_str = 'pixel: (' + string(oplot_col) + ',' + string(oplot_row)+')'
      pixel1_str = STRCOMPRESS (pixel1_str, /REMOVE_ALL)
      pixel2_str = STRCOMPRESS (pixel2_str, /REMOVE_ALL)
      xyouts, 0.02, 0.52, pixel1_str, ALIGNMENT=0, /NORMAL, CHARSIZE=1.2, COLOR='ff0000'x
      xyouts, 0.02, 0.49, pixel2_str, ALIGNMENT=0, /NORMAL, CHARSIZE=1.2, COLOR='0000ff'x
    endif else begin
      oplot, pixel_data, COLOR='000000'x, LINESTYLE=1
      pixel1_str = 'Solid  Line: Pixel (' + string(current_col) + ',' + string(current_row)+')'
      pixel2_str = 'Dashed Line: Pixel (' + string(oplot_col) + ',' + string(oplot_row)+')'
      pixel1_str = STRCOMPRESS (pixel1_str)
      pixel2_str = STRCOMPRESS (pixel2_str)
      xyouts, 0.06, 0.52, pixel1_str, ALIGNMENT=0, /NORMAL, CHARSIZE=1.2, COLOR='000000'x
      xyouts, 0.06, 0.49, pixel2_str, ALIGNMENT=0, /NORMAL, CHARSIZE=1.2, COLOR='000000'x
    endelse

 endelse

;--------------------------------------------------------------------------
; spectral pixel plot
;------------------------------------------------------------------------

  if oplot_sel eq 0 then begin  

    pixel_spectra	= (spectra_cube(*, current_col-1, current_row-1))    
    spectra_min = min(pixel_spectra)
    spectra_max = max(pixel_spectra)

    plot, xfreq, pixel_spectra, xTITLE="Frequency(Hz)", yTITLE="Spectral Density pA/root(Hz)", $
                               /xLOG, /yLOG, XRANGE=[0.01, xfreq_max], $  
                               BACKGROUND='ffffff'x, COLOR='000000'x, ySTYLE=16, /NODATA
    if export eq 0 then oplot, xfreq, pixel_spectra, COLOR='ff0000'x $
    else oplot, xfreq, pixel_spectra, COLOR='000000'x

  endif else begin

    oplot_smin  = min(spectra_cube(*, oplot_col-1, oplot_row-1))
    oplot_smax  = max(spectra_cube(*, oplot_col-1, oplot_row-1))
    
    ; rescale plot? 
    if oplot_smin lt spectra_min then spectra_min = oplot_smin
  ;  if spectra_min lt 1 then spectra_min = 1
    if oplot_smax gt spectra_max then spectra_max = oplot_smax


    pixel_spectra	= (spectra_cube(*, current_col-1, current_row-1))
    plot, xfreq, pixel_spectra, xTITLE="Frequency(Hz)", yTITLE="Spectral Density pA/root(Hz)", $
                               /xLOG, /yLOG, XRANGE=[0.01, xfreq_max],  YRANGE=[spectra_min, spectra_max],  $  
                               BACKGROUND='ffffff'x, COLOR='000000'x, /nodata

    if export eq 0 then oplot, xfreq, pixel_spectra, COLOR='ff0000'x $
    else oplot, xfreq, pixel_spectra, COLOR='000000'x


    pixel_spectra	= (spectra_cube(*, oplot_col-1, oplot_row-1))
    if export eq 0 then oplot, xfreq, pixel_spectra, COLOR='0000ff'x, LINESTYLE=0 $
    else oplot, xfreq, pixel_spectra, COLOR='000000'x, LINESTYLE=1

  endelse

;-----------------------------------------------------------------
; marker lines
;------------------------------------------------------------------
  cut_plot(*)	= cut_level 
  if map_type eq 3 then oplot, xfreq, cut_plot, LINESTYLE=2, THICK=2, COLOR='000000'x
  
  xf_lo(*)	=  f_min   
  xf_hi(*)	=  f_max

  oplot, xf_lo, yf, LINESTYLE=2, COLOR='000000'x
  oplot, xf_hi, yf, LINESTYLE=2, COLOR='000000'x

  if export eq 1 then DEVICE, /CLOSE

;---------------------------------------------------------------  
; export temporal pixel data to file.
;----------------------------------------------------------------


if (export eq 1) and (oplot_sel eq 0) then begin
  openw, lun3, STRCOMPRESS(exportpath +'/pixel_time_'+string(session_id)+'_'+string(export_index)+'.dat', /REMOVE_ALL), /GET_LUN
   hstr1 = '  frame, '
   hstr2 = 'pixel(' + string(current_col) + ',' + string(current_row) + '), '
   hstr2 = STRCOMPRESS (hstr2, /REMOVE_ALL)
   printf, lun3, hstr1, hstr2

  for i=0, n_frames-1 do begin

    printf, lun3, i,  data_cube(i, current_col-1, current_row-1), $
            format = '((1F, :, 1E))'
  endfor 

  free_lun, lun3
endif

if (export eq 1) and (oplot_sel eq 1) then begin

   openw, lun3, STRCOMPRESS(exportpath +'/pixel_time_'+string(session_id)+'_'+string(export_index)+'.dat', /REMOVE_ALL), /GET_LUN

   hstr1 = 'frame'
   hstr2 = 'pixel(' + string(current_col) + ',' + string(current_row) + ')'
   hstr2 = STRCOMPRESS (hstr2, /REMOVE_ALL)
   hstr3 = 'pixel(' + string(oplot_col) + ',' + string(oplot_row) + ')'
   hstr3 = STRCOMPRESS (hstr3, /REMOVE_ALL)
   
   printf, lun3, '  ', hstr1, ', ', hstr2, ', ', hstr3

  for i=0, (n_frames-1) do begin

    printf, lun3, i,  data_cube(i, current_col-1, current_row-1), $
            data_cube(i, oplot_col-1, oplot_row-1), format = '((1F, :, 1E, :, 1E))'
  endfor 

  free_lun, lun3
endif

;---------------------------------------------------------------  
; export spectral data to file.
;----------------------------------------------------------------

if (export eq 1) and (oplot_sel eq 0) then begin
 
  openw, lun2, STRCOMPRESS(exportpath +'/pixel_spectral_'+string(session_id)+'_'+string(export_index)+'.dat', /REMOVE_ALL), /GET_LUN

   hstr1 = '  frequency, '
   hstr2 = 'pixel(' + string(current_col) + ',' + string(current_row) + '), '
   hstr2 = STRCOMPRESS (hstr2, /REMOVE_ALL)
   printf, lun2, hstr1, hstr2

  for i=0, (n_frames/2) do begin

    printf, lun2, xfreq(i),  spectra_cube(i, current_col-1, current_row-1), $
            format = '((1F, :, 1E))'
  endfor 

  free_lun, lun2
endif

if (export eq 1) and (oplot_sel eq 1) then begin

  openw, lun2, STRCOMPRESS(exportpath +'/pixel_spectral_'+string(session_id)+'_'+string(export_index)+'.dat', /REMOVE_ALL), /GET_LUN
   hstr1 = 'frequency'
   hstr2 = 'pixel(' + string(current_col) + ',' + string(current_row) + ')'
   hstr2 = STRCOMPRESS (hstr2, /REMOVE_ALL)
   hstr3 = 'pixel(' + string(oplot_col) + ',' + string(oplot_row) + ')'
   hstr3 = STRCOMPRESS (hstr3, /REMOVE_ALL)
   
   printf, lun2, '  ', hstr1, ', ', hstr2, ', ', hstr3


  for i=0, (n_frames/2) do begin

    printf, lun2, xfreq(i),  spectra_cube(i, current_col-1, current_row-1), $
            spectra_cube(i, oplot_col-1, oplot_row-1), format = '((1F, :, 1E, :, 1E))'
  endfor 

  free_lun, lun2
endif

; -------------------------------------------------------------------------
; generate and plot pixel map
;------------------------------------------------------------------

;print, fstart
;print, fstop
 
for m=0, n_cols-1 do begin
  for n=0, n_rows-1 do begin
 
   window_mean = mean(spectra_cube(fstart:fstop,m,n))

   pixel_mean(m,n) = window_mean

   if window_mean gt cut_level then $
      pixel_map(m,n) = 255 else $
      pixel_map(m,n) = 0
   
  endfor
endfor

if export eq 1 then begin
 
   openw, lun2, STRCOMPRESS(exportpath +'/sc2_window_mean_'+string(session_id)+'_'+string(export_index)+'.dat', /REMOVE_ALL), /GET_LUN
  printf, lun2, pixel_mean, format = '(32A)'
  free_lun, lun2
  DEVICE, FILENAME=STRCOMPRESS(exportpath +'/pixel_map_'+string(session_id)+'_'+string(export_index)+'.ps', /REMOVE_ALL), /LANDSCAPE
endif ;else begin


;--------------------------------------------------------------
if map_type eq 1 then begin	; linear scale

  for sci=0, s_cols-1 do begin
    for sri=0, s_rows-1 do begin
   
; invert y axis for display
      mpixel_map(sci, s_rows-sri-1) = pixel_mean(sci/pixel_scale, sri/pixel_scale) 

    endfor
  endfor

; plot pixel map
!p.multi=[0,1,1,0,1]
   if export eq 0 then begin
     window, 2, xsize=s_cols, ysize=s_rows, TITLE="Pixel Map: Linear Scale" 
     erase & tvscl, mpixel_map, channel=pixel_color
   endif else begin
     tvscl, mpixel_map
   endelse

endif 
;--------------------------------------------------------------------
if map_type eq 2 then begin	; log scale

  for sci=0, s_cols-1 do begin
    for sri=0, s_rows-1 do begin

; invert y axis for display
       mpixel_map(sci, s_rows-sri-1) = alog10(pixel_mean(sci/pixel_scale, sri/pixel_scale)) 

    endfor
  endfor

; plot pixel map
!p.multi=[0,1,1,0,1]

  if export eq 0 then begin 
    window, 2, xsize=s_cols, ysize=s_rows, TITLE="Pixel Map: Log Scale"
    erase & tvscl, mpixel_map, channel=pixel_color
  endif else begin
    tvscl, mpixel_map
  endelse

endif


if map_type eq 3 then begin      ; threshold scale

  for sci=0, s_cols-1 do begin
    for sri=0, s_rows-1 do begin
;    spixel_map(sci, sri) = pixel_map(sci/pixel_scale, sri/pixel_scale) 

; invert y axis for display
      spixel_map(sci, s_rows-1-sri) = pixel_map(sci/pixel_scale, sri/pixel_scale)

    endfor
  endfor


; plot pixel map
  !p.multi=[0,1,1,0,1]
  if export eq 0 then begin
    window, 2, xsize=s_cols, ysize=s_rows, TITLE="Pixel Map: Threshold"
    erase & tv, spixel_map, channel=pixel_color
  endif else begin
    tv, spixel_map
  endelse

endif

;------------------------------------------------------------------------
  if show_pix eq 1 then begin 
      xyouts, 0.0, (s_rows-pixel_scale)/double(s_rows), '1,1', $ 
                   ALIGNMENT=0, /NORMAL, CHARSIZE=1, COLOR='00ff00'x
      xyouts, (x1-pixel_scale)/double(s_cols), (y1-pixel_scale)/double(s_rows), $
                   '*', ALIGNMENT=0, /NORMAL, CHARSIZE=4, COLOR='ff0000'x

      if (oplot_sel eq 1) then xyouts, (x2-pixel_scale)/double(s_cols), (y2-pixel_scale)/double(s_rows), $
                    '*', ALIGNMENT=0, /NORMAL, CHARSIZE=4, COLOR='0000ff'x
   endif
;--------------------------------------------------------------------
  if show_grid eq 1 then begin
   
    for i=0, n_rows do begin
      plots, [0,n_cols*pixel_scale], [i*pixel_scale, i*pixel_scale], /device, color=color_array(grid_color), thick=1
    endfor
 
    for j=0, n_cols do begin

      plots, [j*pixel_scale, j*pixel_scale], [0, n_rows*pixel_scale], /device, color=color_array(grid_color), thick=1
    endfor

    ; add some thicker lines every 8 rows  &  8 columns
        
    for i=0, n_rows/8 do begin
      plots, [0,n_cols*pixel_scale], [pixel_scale*(1+i*8), pixel_scale*(1+i*8)], /device, color=color_array(grid_color), thick=3
    endfor
 
    for j=0, n_cols/8 do begin

      plots, [j*pixel_scale*8, j*pixel_scale*8], [0, n_rows*pixel_scale], /device, color=color_array(grid_color), thick=3
    endfor

 
  
 
  endif
;----------------------------------------------------------------------------
if export eq 1 then DEVICE, /CLOSE


;DEVICE, DECOMPOSE=0
;loadct, 0

;--------------------------------------------------------------------
  

  READ, select,  $ 
  PROMPT="select: (1)Pixel to plot; (2)Pixel to overplot; (3)Pixel map options; (4)Freq window; (5)Export (0) Exit....:"

  printf, -1, ''

  export = 0

  SET_PLOT, my_device

  if select eq 0 then plot=0

  if select eq 1 then begin
     
     oplot_sel = 0		; not an overplot pixel
     
     printf,-1, 'click cursor on pixel to select....' 
     printf,-1,''
     cursor, x1, y1, /device
     current_col = (x1/pixel_scale) + 1
;     current_row = (y1/pixel_scale) + 1

; invert and scale row index
     current_row = n_rows - (y1/pixel_scale)


     printf, -1, 'selected pixel column:', current_col
     printf, -1, 'selected pixel row:   ', current_row
     printf, -1, 'mean spectral value:  ', pixel_mean(current_col-1,current_row-1)

     xyouts, (x1-pixel_scale)/double(s_cols), (y1-pixel_scale)/double(s_rows), $
                        '*', ALIGNMENT=0, /NORMAL, CHARSIZE=4, COLOR='ff0000'x

  endif 

   if select eq 2 then begin
     
     oplot_sel = 1   ; flag an overplot pixel

     printf,-1, 'click cursor on pixel to select for overplot....' 
     printf,-1,''
     cursor, x2, y2, /device
     oplot_col = (x2/pixel_scale) + 1
;     oplot_row = (y2/pixel_scale) + 1

; invert and scale row index
    oplot_row = n_rows - (y2/pixel_scale)

     printf, -1, 'selected pixel column:', oplot_col
     printf, -1, 'selected pixel row:   ', oplot_row
     printf, -1, 'mean spectral value:  ', pixel_mean(oplot_col-1,oplot_row-1)
     xyouts, (x2-pixel_scale)/double(s_cols), (y2-pixel_scale)/double(s_rows), '*', $ 
                              ALIGNMENT=0, /NORMAL, CHARSIZE=4, COLOR='0000ff'x
  
  endif 

  if select eq 3 then begin 

    READ, map_sel,  $ 
    PROMPT="pixel map: (1)Linear; (2)Log; (3)Threshold; (4)Pixel colour; (5)Show pixel; (6)Grid...: "
    check_range, 1, 6, map_sel    

    if map_sel le 3 then map_type = map_sel
    if map_sel eq 3 then READ, cut_level, PROMPT='Enter spectral density threshold level.....: '

    if map_sel eq 4 then begin
       READ, pixel_color, PROMPT='Enter map colour (0) B&W, (1) Red, (2) Green, (3) Blue......: '
       check_range, 0, 3, pixel_color
    endif 

    if map_sel eq 5 then begin
      READ, show_pix, PROMPT='Show selected pixels on map? (0)No; (1) yes....: "
      check_range, 0, 1, show_pix
    endif
    
   if map_sel eq 6 then begin 
      READ, grid_sel, PROMPT='Show pixel grid on map? (0)No; (1) yes; (2)colour....: "
      check_range, 0, 2, grid_sel
      if grid_sel le 1 then begin
        show_grid = grid_sel
      endif else begin
        READ, grid_color, PROMPT='Grid colour: (0)Bl; (1)Wh, (2)Red, (3)Grn, (4)Blu, (5)Yel: "   
        check_range, 0, 5, grid_color 
     end

    endif
    
  endif 
 
  if select eq 4 then begin 
     READ, f_min,   PROMPT='Enter lower limit of frequency window .......: '
     READ, f_max,   PROMPT='Enter higher limit of frequency window ........: '
     fwindow = where(xfreq gt f_min and xfreq lt f_max)
     fstart  = min(fwindow)		; start xfreq index position of window
     fstop	= max(fwindow)		; stop xfreq index position of window
  endif   

  if select eq 5 then begin
    export = 1 
    export_index=export_index+1
    SET_PLOT, 'PS'
  endif 

endwhile 

; --------------------------------------------------------------
print, '.....program finished'
end
