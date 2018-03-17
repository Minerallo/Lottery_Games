clc;clear all;
addpath('C:\Users\mikpo\Desktop\Loto')

%% Choix du jeux
options.Interpreter = 'tex';
% Réponse par défault
options.Default = 'Loto';
% boite de dialogue
qstring = 'A quel jeu veux-tu jouer ?';
button = questdlg(qstring,'Boundary Condition',...
    'Loto','Euromillion',options)

if strcmp(button,'Loto')
    url = ['https://media.fdj.fr/generated/game/loto/nouveau_loto.zip'];%2008-mars2017
    filename='vieuxloto';
    websave(filename,url);
    unzip(filename);
    vieuxloto=importfile1('nouveau_loto.csv', 2);
    url = ['https://media.fdj.fr/generated/game/loto/loto2017.zip'];
    filename='Lastloto';
    websave(filename,url);
    unzip(filename);
    nloto = importfile('loto2017.csv',2);
    catloto=vertcat(nloto,vieuxloto);
    nboules=49;
    nboulescomp=10;
    nnum='49';
    complem=catloto(:,6);
elseif strcmp(button,'Euromillion')
    url = ['https://media.fdj.fr/generated/game/euromillions/euromillions.zip'];
    filename = 'Euromillions';
    websave(filename,url);
    unzip(filename);
    euromillions = importfile2('euromillions.csv', 2);
    url = ['https://media.fdj.fr/generated/game/euromillions/euromillions_2.zip'];
    filename = 'Euromillions2';
    websave(filename,url);
    unzip(filename);
    euromillions2 = importfile3('euromillions_2.csv', 2);
    url = ['https://media.fdj.fr/generated/game/euromillions/euromillions_3.zip'];
    filename = 'Euromillions3';
    websave(filename,url);
    unzip(filename);
    euromillions3 = importfile4('euromillions_3.csv', 2);
    url = ['https://media.fdj.fr/generated/game/euromillions/euromillions_4.zip'];
    filename = 'Euromillions4';
    websave(filename,url);
    unzip(filename);
    euromillions4 = importfile5('euromillions_4.csv', 2);
    catloto=vertcat(flipud(euromillions4),euromillions3,euromillions2,euromillions);
    neweuroMcomp=catloto(:,6:7);
    nboules=50;
    nboulescomp=12;
    nnum='50';
    complem=catloto(:,6:7);
end

newloto=catloto(:,1:5);

b=1:nboules;

%% Ratio sortie pour chaque numéro
for a=1:nboules % nombres que l'on peut jouer au loto
    nombi(a) = sum(sum(newloto==a));
    ratio(a) = nombi(a)/size(newloto,1)*100;
    ecart  = diff(find(newloto'==a)./5);
    ecartmean(a) = mean(ecart);
    %ecarte{a}=ecart;
end
figure(1);
subplot(1,3,1);plot(b,ratio,'b+',b,ecartmean,'r-'); legend('ratio','ecart moyen nbtirage');title('Boules 1-5');
%figure(55);plot(b,ratio,'b+',b,ecartmean,'r-'); legend('ratio','ecart moyen');title('Ratios boules 1 à 5 - 05/09/2017');grid on;
%% index numero tirage pour chaque nombre
for i=1:nboules
    %disp('la')
    index = find(newloto'==i)./5;
    for j=1:numel(index)
        if  10*rem(index(j),1)== 0
            %disp('1');
            index(j)=fix(index(j));
        elseif 10*rem(index(j),1)~=0
            %disp('2');
            index(j)=fix(index(j))+1;
        end
        indexi{i}=index;
    end
end

%% Cross-correlation
for i=1:nboules
    %disp([num2str(i),'/',nnum])
    numloto=newloto(indexi{i},:);
    taille = size(newloto(indexi{i},:),1);%nombre de tirage comportant le nombre i
    for j=1:nboules
        nombelem(i,j)=sum(sum(numloto==j))/taille; %matrice de correlation croisée
    end
end

minnomb=min(min(nombelem));
nombelem2=nombelem;
nombelem2((nombelem2)==1)=0;
maxnomb=max(max(nombelem2));
figure(2);pcolor(nombelem); caxis([minnomb maxnomb]);colormap(jet);title('Boules 1 à 5 cross-correlation 05/09/2017');

figure(1);
subplot(1,3,2);pcolor(nombelem); caxis([minnomb maxnomb]);colormap(jet);title('Boules cross-correlation');


%% Numero complémentaire
c=1:nboulescomp;


%Ratio sortie pour chaque numéro
for a=1:nboulescomp % nombres que l'on peut jouer au loto
    nombcomplem(a)=sum(sum(complem==a));
    ratiocomplem(a)=nombcomplem(a)/size(complem,1)*100;
    ecartcomplem=diff(find(complem'==a)./5);
    ecartmeancomplem(a)=mean(ecartcomplem);
    %ecarte{a}=ecart;
end

figure(1);
subplot(1,3,3);plot(c,ratiocomplem,'b+',c,ecartmeancomplem,'r-'); legend('ratio','ecart moyen nbtirage');title('numero complementaire');
figure(56);plot(c,ratiocomplem,'b+',c,ecartmeancomplem,'r-'); legend('ratio','ecart moyen');title('numeros complementaires - 05/09/2017');grid on;

%Première statégie par utilisation de l'écartmoyen entre 2 apparition d'un même nombre
%plot(ecartcomplem,'b-');hold on; plot(ecartcomplem,'ro')
for i=1:nboules
    lastapp(i)=indexi{i}(1);
end

%potentiel d'apparition des boules 1 à 5
potapp=lastapp./ecartmean;
minpotapp=min(potapp);

precoce=find(potapp<=0.9);precoce(2,:)=potapp([precoce]);
retarde=find(potapp>=1.10);retarde(2,:)=potapp([retarde]);
normal=find(potapp>0.9 & potapp<1.10);normalrate=potapp([normal]);
diffnormrate=abs(normalrate-1);
minnormalrate= find(diffnormrate==min(diffnormrate));

%Plot
 figure(666);
 g=b*0+1
 plot(b,potapp,'ob',b,g,'--r'); title('Potapp Euromillions - 05/09/2017'); grid on;




%% Première stratégie

%Premier chiffre
tiragefinal(1)=normal(minnormalrate);%chiffre

for i=2:5
    nomb=(nombelem2(tiragefinal(i-1),:));
    indnomb=find(nomb==max(nomb));
    
    for j=1:numel(indnomb)
        if isempty(intersect(indnomb(j),tiragefinal))==0%
            nomb(indnomb(j))=0;
        end
    end
    indnomb=find(nomb==max(nomb));selec=indnomb;
    
    if isscalar(indnomb)==0
        for t=1:numel(indnomb)
            if isempty(intersect(indnomb(t),tiragefinal))==0%
                selec(t)=[];
            end
        end
        maxratselec=max(ratio(selec));
        indnombt=find(ratio==maxratselec);
        indnomb=intersect(indnombt,selec);
    end
    tiragefinal(i)=indnomb;
end

%% deuxième strategie
[tiragefinal2(1),tiragefinal2(2)]=find(nombelem2==max(max(nombelem2)));
nombelem2(tiragefinal2(1),tiragefinal2(2))=0;
[tiragefinal2(3),tiragefinal2(4)]=find(nombelem2==max(max(nombelem2)));
tiragefinal2(5)=find(ratio==max(ratio));

%% Num complémentaire 1
for i=1:nboulescomp
    lastappcomplem(i)=find(complem==i,1);
end
potappcomplem=lastappcomplem./ecartmeancomplem;

precocecomplem=find(potappcomplem<=0.9);precocecomplem(2,:)=potappcomplem([precocecomplem]);
retardecomplem=find(potappcomplem>=1.10);retardecomplem(2,:)=potappcomplem([retardecomplem]);
normalcomplem=find(potappcomplem>0.9 & potappcomplem<1.10);normalratecomplem=potappcomplem([normalcomplem]);

diffnormratecomplem=abs(potappcomplem-1);
minnormalratecomplem= find(diffnormratecomplem==min(diffnormratecomplem));

tiragefinal2(6)=minnormalratecomplem;
tiragefinal(6)=minnormalratecomplem;

%% Num complémentaire 2 pour Euromillion
if strcmp(button,'Euromillion')
    
    % index numero tirage pour chaque nombrecomplémentaire
    for i=1:12
        %disp('aqui')
        indexcomp = find(neweuroMcomp'==i)./2;
        for j=1:numel(indexcomp )
            if  10*rem(indexcomp (j),1)== 0
                %disp('1a');
                indexcomp (j)=fix(indexcomp (j));
            elseif 10*rem(indexcomp (j),1)~= 0
                %disp('2a');
                indexcomp (j)=fix(indexcomp (j))+1;
            end
            indexicomp {i}=indexcomp ;
        end
    end
    
    %% Cross-correlation numéro complémentaire
    for i=1:12
        %disp([num2str(i),'/','12'])
        numeuroMcomp =neweuroMcomp(indexicomp {i},:);
        taillecomp  = size(neweuroMcomp(indexicomp {i},:),1);%nombre de tirage comportant le nombre i
        for j=1:12
            nombelemcomp (i,j)=sum(sum(numeuroMcomp==j))/taillecomp; %matrice de correlation croisée
        end
    end
    
    minnombcomp=min(min(nombelemcomp));
    nombelem2comp=nombelemcomp;
    nombelem2comp((nombelem2comp)==1)=0;
    maxnombcomp=max(max(nombelem2comp));
    figure(5);pcolor(nombelemcomp); caxis([minnombcomp maxnombcomp]);colormap(jet);title('Boules cross-correlation complémentaire');
    
    nomb2comp=(nombelem2comp(tiragefinal(6),:));
    indnomb2comp=find(nomb2comp==max(nomb2comp));%chiffre
    
    for i=1:numel(indnomb2comp)
        if indnomb2comp(i)==tiragefinal(6)
            nomb2comp(indnomb2comp(i))=0;
        end
    end
    indnomb2comp=find(nomb2comp==max(nomb2comp));selec2comp=indnomb2comp;
    if isscalar(indnomb2comp)==0
        for i=1:numel(indnomb2comp)
            if indnomb2comp(i)==tiragefinal(6)
                selec2comp(i)=[];
            end
        end
        maxratselec2comp=max(ratiocomplem(selec2comp));
        indnomb2tcomp=find(ratiocomplem==maxratselec2comp);
        indnomb2comp = intersect(indnomb2tcomp,selec2comp);
    end
    tiragefinal(7)=indnomb2comp;
    tiragefinal2(7)=indnomb2comp;
end
%% dialogue box
msgbox(['Tirage 2 : ', num2str(tiragefinal2)])
msgbox(['Tirage 1 : ', num2str(tiragefinal)])
