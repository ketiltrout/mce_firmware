x=[]
t=[]
fid=fopen('calc_out_fltr2');
while 1
  t=fgetl(fid);
  if ~ischar(t), break, end
    x=[x; sscanf(t, '%d')]
end
fclose(fid);
size(x)
figure(1);

plot(20*log10(abs(fft(x))))
grid on;
title('Frequency Response (full precision coefficients)');
xlabel ('Frequency');
ylabel ('Magnitude - dB');
