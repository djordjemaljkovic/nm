clc, clear, close all

%% Ucitavanje podataka
RE_data_exel = readtable( 'Real_Estate_data.csv'); 
RE_data_col14 = table2array(RE_data_exel(:,1:4));
RE_data_col5 = table2array(RE_data_exel(:,5));
RE_data_col68 = table2array(RE_data_exel(:,6:8)); 
N = length(RE_data_col14);
RE_data_col5 = string(RE_data_col5(:,1));
RE_data_col5(RE_data_col5(:,1) == 'individual_heating') = 0;
RE_data_col5(RE_data_col5(:,1) == 'central_heating') = 1;
RE_data_col5 = double(RE_data_col5(:,1));
RE_data = [RE_data_col14, RE_data_col5, RE_data_col68];

%% razdvajanje podataka
RE_izlaz = RE_data(:,1)';
RE_ulaz = RE_data(:,2:8)';
%% mesanje podataka
index = randperm(N);
RE_ulaz = RE_ulaz(:,index);
RE_izlaz = RE_izlaz(index);


%% izlazni podaci

x = linspace(1,N,N)';
Nizl_min = min(RE_izlaz);
Nizl_max = max(RE_izlaz);
RE_izlaz = (RE_izlaz-Nizl_min)/(Nizl_max-Nizl_min); %normiranje
figure
plot(x,RE_izlaz,'.');
grid on
title('Излазни подаци - цена стана');
xlabel('одбирак');
ylabel('Цена стана');

%% godina
Ng_min = min(RE_ulaz(1,:));
Ng_max = max(RE_ulaz(1,:));
Ngg = zeros(1,Ng_max-Ng_min);
for i=0:(Ng_max-Ng_min)
    Ngg(i+1)= sum (RE_ulaz(1,:) == (i+Ng_min));
end
Ngg = Ngg';
RE_ulaz(1,:) = (RE_ulaz(1,:)- Ng_min)/(Ng_max -Ng_min); %normiranje
figure
plot(x,RE_ulaz(1,:),'.');
grid on
title('1.Улазни податak - година изградње стана');
xlabel('одбирак');
ylabel('Година изградње стана');


%% size
Nsize_min = min(RE_ulaz(2,:));
Nsize_max= max(RE_ulaz(2,:));

RE_ulaz(2,:) = (RE_ulaz(2,:)- Nsize_min)/(Nsize_max -Nsize_min); %normiranje

figure
plot(x,RE_ulaz(2,:),'.');
grid on
title('2.Улазни податak - величина стана');
xlabel('одбирак');
ylabel('Величина стана  [m^2]');

%% sprat
Nf_min = min(RE_ulaz(3,:));
Nf_max= max(RE_ulaz(3,:));
Nf = zeros(1,43);
for i=1:43
    Nf(i)= sum (RE_ulaz(3,:) == i);
end
Nf = Nf';
RE_ulaz(3,:) = (RE_ulaz(3,:)- Nf_min)/(Nf_max -Nf_min); %normiranje
figure
plot(x,RE_ulaz(3,:),'.');
grid on
title('3.Улазни податaк - спрат');
xlabel('одбирак');
ylabel('Спрат на коме се налази стан');
%% grejanje
Nh_min = min(RE_ulaz(4,:));
Nh_max = max(RE_ulaz(4,:));
Nind_heat = sum (RE_ulaz(4,:) == 0);
Ncen_heat = sum (RE_ulaz(4,:) == 1);
figure
plot(x,RE_ulaz(4,:),'.');
grid on
title('4.Улазни податaк - тип грејања');
xlabel('одбирак');
ylabel('тип грејања');
axis([0, 6000, -0.2, 1.2]);

%% elevators
Nl_min = min(RE_ulaz(5,:));
Nl_max = max(RE_ulaz(5,:));
Nl = zeros(1,Nl_max+1);
for i=0:Nl_max
    Nl(i+1)= sum (RE_ulaz(5,:) == i);
end
RE_ulaz(5,:) = (RE_ulaz(5,:)- Nl_min)/(Nl_max -Nl_min); %normiranje
figure
plot(x,RE_ulaz(5,:),'.');
grid on
title('5.Улазни податaк - лифт');
xlabel('одбирак');
ylabel('Број лифтова у згради');

%% parkovi
Np_min = min(RE_ulaz(6,:));
Np_max = max(RE_ulaz(6,:));
Np = zeros(1,3);
for i=0:2
    Np(i+1)= sum (RE_ulaz(6,:) == i);
end
RE_ulaz(6,:) = RE_ulaz(6,:)/2;
figure
plot(x,RE_ulaz(6,:),'.');
grid on
title('6.Улазни податaк - парк');
xlabel('одбирак');
ylabel('Број паркова у близини стана');
%axis([0, 6000, -0.2, 2.2]);
%% skole
Ns_min = min(RE_ulaz(7,:));
Ns_max = max(RE_ulaz(7,:));
Nsch = zeros(1,18);
for i=0:17
    Nsch(i+1)= sum (RE_ulaz(7,:) == i);
end
RE_ulaz(7,:) = (RE_ulaz(7,:)- Ns_min)/(Ns_max -Ns_min); %normiranje
figure
plot(x,RE_ulaz(7,:),'.');
grid on
title('7.Улазни податaк - школа');
xlabel('одбирак');
ylabel('Број школа у близини');


%% Krosvalidacija za trainlm
Per_best = 1e+12;    % srednja kvadratna greska treba da bude sto manja
%definisemo arhitekturu kao konstantu
arhitektura = [40, 40];
i = 0;

for sloj = [2,3,4]
    for br = [20, 25, 30, 40]
        arhitektura=[];   
        for j = 1:sloj
            arhitektura = [arhitektura, br];
        end
        arhitektura  
            %kreiramo neuralnu mrezu
            %REGRESIJA!!!
            net = fitnet(arhitektura);
            
            net.trainFcn = 'trainlm'; % za momentum / gradijentni spust
      %      net.performFcn = 'mae';
        %    net.performFcn = 'mse';  % Mean squared error performance function
            
            net.divideFcn = 'dividerand';
            net.divideParam.testRatio = 0.1;
            net.divideParam.trainRatio = 0.8;
            net.divideParam.valRatio = 0.1;
            
            %trening parametri
%             net.trainParam.lr = lr;
%             net.performParam.regularization = reg;
%             net.trainParam.mc = mom;
%             
            net.trainParam.epochs = 750;
            net.trainParam.goal = 1e-3;
            net.trainParam.min_grad = 1e-4;
            net.trainParam.max_fail = 12;
            
            
            net.trainParam.showWindow = true; % da nam ne uzima vreme
            net.trainParam.showCommandLine = false;
            
            % treniramo neuralnu m
            [net, tr] = train(net, RE_ulaz, RE_izlaz);
            
            Per = tr.best_perf;
            i=i+1;
  %          disp(string(i)+" lr= "+string(lr)+", reg= "+string(reg)+", mom= "+string(mom)+", epo= "+string(tr.best_epoch));
            disp(Per)
            if Per < Per_best
               Per_best = Per;
%                 momBest = mom;
%                 regBest = reg;
%                 lrBest = lr;
                slojNbEST = sloj;
                brBest = br;
                epohaBest = tr.best_epoch;
                disp(string(Per)+" - BOLJE!")
                
                %pamtimo i indekse - trebace nam kasnije
%                 train_index = tr.trainInd;
%                 val_index = tr.valInd;
%                 test_index = tr.testInd;

            end
        end
    
end
disp("kraj");

%% ponovo treniramo nm sa najboljim parametrima
arhitektura = [25, 25, 25];
net = fitnet(arhitektura);
net.trainFcn = 'trainlm';
%net.performFcn = 'mae';
%net.performFcn = 'mse';
%net.divideFcn = '';
net.divideFcn = 'dividerand';
net.divideParam.testRatio = 0.1;
net.divideParam.trainRatio = 0.8;
net.divideParam.valRatio = 0.1;

net.trainParam.goal = 1e-4;
net.trainParam.min_grad = 1e-5;
net.trainParam.max_fail = 12;
net.trainParam.showWindow = true;            %sada prikazujemo treniranje
net.trainParam.showCommandLine = false;
       %treniramo zajedno sa trening i validacionim skupom

[net1, tr] = train(net,RE_ulaz, RE_izlaz);
test_index1 = tr.testInd;

%% Krosvalidacija
Per_best = 1e+12;    % srednja kvadratna greska treba da bude sto manja
%definisemo arhitekturu kao konstantu
arhitektura = [25, 25, 25];
i = 0;

for lr = [0.35, 0.3, 0.2]
    for reg = [0.003, 0.001, 0.0005]
        for mom = [ 0.65, 0.7, 0.75]
            
            %kreiramo neuralnu mrezu
            %REGRESIJA!!!
            net = fitnet(arhitektura);
            
            net.trainFcn = 'traingdm'; % za momentum / gradijentni spust
      %      net.performFcn = 'mae';
            net.performFcn = 'mse';  % Mean squared error performance function
            
            net.divideFcn = 'dividerand';
            net.divideParam.testRatio = 0.1;
            net.divideParam.trainRatio = 0.8;
            net.divideParam.valRatio = 0.1;
            
            %trening parametri
            net.trainParam.lr = lr;
            net.performParam.regularization = reg;
            net.trainParam.mc = mom;
            
            net.trainParam.epochs = 750;
            net.trainParam.goal = 1e-3;
            net.trainParam.min_grad = 1e-4;
            net.trainParam.max_fail = 20;
            
            
            net.trainParam.showWindow = false; % da nam ne uzima vreme
            net.trainParam.showCommandLine = false;
            
            % treniramo neuralnu m
            [net, tr] = train(net, RE_ulaz, RE_izlaz);
            
            Per = tr.best_perf;
            i=i+1;
            disp(string(i)+" lr= "+string(lr)+", reg= "+string(reg)+", mom= "+string(mom)+", epo= "+string(tr.best_epoch));
            disp(Per)
            if Per < Per_best
                Per_best = Per;
                momBest = mom;
                regBest = reg;
                lrBest = lr;
                epohaBest = tr.best_epoch;
                disp(string(Per)+" - BOLJE!")
                
                %pamtimo i indekse - trebace nam kasnije
                train_index = tr.trainInd;
                val_index = tr.valInd;
                test_index = tr.testInd;

            end
        end
    end
end
disp("kraj");

%% ponovo treniramo nm sa najboljim parametrima
arhitektura = [25, 25, 25];
net = fitnet(arhitektura);
net.trainFcn = 'traingdm';
%net.performFcn = 'mae';
net.performFcn = 'mse';
net.divideFcn = '';
% net.divideFcn = 'divideind';
% net.divideParam.trainInd = train_index;
% net.divideParam.valInd = val_index;
% net.divideParam.testInd = test_index;
net.trainParam.lr = lrBest;
net.trainParam.mc = momBest;
net.performParam.regularization = regBest;

net.trainParam.epochs = 750;
net.trainParam.goal = 1e-3;
net.trainParam.min_grad = 1e-4;
net.trainParam.max_fail = 20;
net.trainParam.showWindow = true;            %sada prikazujemo treniranje
net.trainParam.showCommandLine = false;
indexTV = [train_index, val_index];         %treniramo zajedno sa trening i validacionim skupom

[net, tr] = train(net,RE_ulaz(:,indexTV), RE_izlaz(indexTV));

%% iscrtavanje dobijenih rezultata na test skupu
figure()
hold all
plot(test_index,RE_izlaz(test_index),'b.');
plot(test_index,net(RE_ulaz(:,test_index)),'r.');
grid on
title('тестирање неуралне мреже');
xlabel('одбирак');
ylabel('Цена стана');
%% sortiranje izlaznih podataka
Re_sveee_test = [RE_izlaz(test_index); RE_ulaz(:,test_index)];
Re_sveee_test = sortrows(Re_sveee_test',1)';

RE_ulaz_test = Re_sveee_test(2:8,:);
Re_izlaz_test = Re_sveee_test(1,:)*(Nizl_max-Nizl_min)+Nizl_min;
RE_test_pred = (net(RE_ulaz_test))*(Nizl_max-Nizl_min)+Nizl_min;
figure
hold all
plot(test_index,Re_izlaz_test,'b.');
plot(test_index,RE_test_pred,'r.');
grid on
title('тестирање неуралне мреже');
xlabel('одбирак');
ylabel('Цена стана');

 %% 

figure()
hold all
plot(x,RE_izlaz,'b.');
plot(x,net(RE_ulaz),'r.');
grid on
title('тестирање неуралне мреже - сви улази');
xlabel('одбирак');
ylabel('Цена стана');
%%
Re_sveee = [RE_izlaz; RE_ulaz];
Re_sveee = sortrows(Re_sveee',1)';
RE_ulaz = Re_sveee(2:8,:);
RE_izlaz = Re_sveee(1,:)*(Nizl_max-Nizl_min)+Nizl_min;
RE_izlaz_pred = net(RE_ulaz)*(Nizl_max-Nizl_min)+Nizl_min;
figure()
hold all
plot(x,RE_izlaz,'b.');
plot(x,RE_izlaz_pred,'r.');
grid on
title('тестирање неуралне мреже - сви улази');
xlabel('одбирак');
ylabel('Цена стана');
%% provera
valll = RE_ulaz(:,val_index);
Nind_heattt = sum (valll(4,:) == 0);
Ncen_heattt = sum (valll(4,:) == 1);
%dobro je on to izbrckao!!!



