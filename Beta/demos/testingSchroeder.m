%%
hCrop = rbaCropIR(H(:,3),fsModel,3.5e5);
R = rbaSchroeder(hCrop,fsFull,1,3e4);

%% 
figure(1)
plot(h2full)
%xlim([0 1000])
figure(2)
htest = sum(H,2);
plot(htest(1:end-35)-h2full(36:end))
%xlim([0 1000])
%%