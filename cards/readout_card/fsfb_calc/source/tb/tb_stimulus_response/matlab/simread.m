x=[];
t=[];
y=[];
z=[];
fid=fopen('filter.in');
while 1
  t=fgetl(fid);
  if ~ischar(t), break, end
  if (t(1) == '1')
    x=[x;-(2.^40-bin2dec(t))];
  else
    x=[x;bin2dec(t)];
  end;  
end
fclose(fid);
size(x);

fid=fopen('filter.mid.out');
while 1
  t=fgetl(fid);
  if ~ischar(t), break, end
  if (t(1) == '1')
    z=[z;-(2.^29-bin2dec(t))];
  else
    z=[z;bin2dec(t)];
  end;  
end
fclose(fid);
i=0;
fid=fopen('filter.out');
while 1
  t=fgetl(fid);
  i=i+1;
  if ~ischar(t), break, end
  if (t(1) == '1')
    y=[y;-(2.^32-bin2dec(t))];
  else
    y=[y;bin2dec(t)];
  end;  
end
fclose(fid);

% plotting
figure(4);
clf()
subplot(2,2,1)
plot(x)
grid on;
xlabel('filter.in')
subplot(2,2,2)
plot(z)
grid on;
xlim([0,2000]);
xlabel('filter.midstage.out')
subplot(2,2,3)
plot(y)
grid on;
xlim([0,2000]);
xlabel('filter.out')
subplot(2,2,4)
plot(20*log10(abs(fft(y,25252))))
grid on;
title('Frequency Response (1.14 precision coefficients)');
xlabel ('Frequency (Hz)');
ylabel ('Magnitude - dB');
xlim([0,500])

