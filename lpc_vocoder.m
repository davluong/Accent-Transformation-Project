clear all;
[yraw,fs] = audioread('hw6.wav');
%[a,g] = lpc(y,10);
%[A,G,aa,r] = autolpc(y,10);
y_filtered = highpass_filter(yraw(:,1),fs);
fs_new = 8000;
y = resample(y_filtered,fs_new,fs);%downsample to 8kHZ
L = 40;%ms frame size
R=10; %ms frame overlap
L_index = round(L/1000*fs_new) ;
R_index = round(R/1000*fs_new) ;
p = 20;
[As,Gs,nframes,exct]=lpc_analysis(y,1,length(y),L_index,R_index,p);
%%
[p1m,pitch]=gen_pitch(y,fs_new,L_index,R_index,nframes);
%[f0_time,f0_value,SHR,f0_candidates]=shrp(y,fs_new);
plot(y)
eee=create_excitation(pitch,R_index);
figure;
plot(eee);
[e]=create_excitation_signal(nframes,R_index,pitch);
%[ex,exn,Gain] = normalize_excitation(e,R_index,Gs);
[s]=synthesize_speech(1,length(y),L_index,R_index,nframes,1,e,Gs,As,p,0,hamming(L_index)');
audiowrite('C:\Users\ADMÝN\Desktop\dsp\proje\lpc_vocoder\dnm.wav',s/2,fs_new);
figure;
plot(s);