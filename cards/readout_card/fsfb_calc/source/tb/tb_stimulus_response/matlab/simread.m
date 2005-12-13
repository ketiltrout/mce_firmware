x=[]
t=[]
fid=fopen('filter_sin10_100_p1_0_4k_fj.out');
while 1
  t=fgetl(fid);
  if ~ischar(t), break, end
  if (t(1) == '1')
    x=[x;-(2.^32-bin2dec(t))]
  else
    x=[x;bin2dec(t)]
  end;  
end
fclose(fid);
size(x)
figure(4);

plot(20*log10(abs(fft(x,20000))))
grid on;
title('Frequency Response (full precision coefficients)');
xlabel ('Frequency');
ylabel ('Magnitude - dB');
