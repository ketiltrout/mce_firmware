x=[]
t=[]
fid=fopen('calc_impulse_p-50000_4pole_midscale_in18.out');
while 1
  t=fgetl(fid);
  if ~ischar(t), break, end
    x=[x; sscanf(t, '%d')]
end
fclose(fid);
size(x)
figure(1);

plot(20*log10(abs(fft(x,12195))))
grid on;
title('Frequency Response (full precision coefficients)');
xlabel ('Frequency');
ylabel ('Magnitude - dB');
