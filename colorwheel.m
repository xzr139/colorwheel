
function final = colorwheel(rgbImage)
clc;
close all;
format long g;
format compact;
fontSize = 20;

%folder = fullfile('/Users/admin/Desktop/photo/');
% folder = fullfile('/Users/admin/Desktop/');
% baseFileName = '1.jpg';
% fullFileName = fullfile(folder, baseFileName);
% rgbImage = imread(fullFileName);
% rgbImage=ones(360,360,3)*255;
% rgbImage(:,1:10,1)=0;

if size(rgbImage,3)~=3
    score = -1;
    return;
end
hsv_img = rgb2hsv(rgbImage);


h = hsv_img(:,:,1);
s = hsv_img(:,:,2);
v = hsv_img(:,:,3);


numberOfBins = 360;
[pixelCount, grayLevels] = hist(h(:), numberOfBins);

c(:,:)=h;
c=ceil((c-min(min(h)))./((max(max(h))-min(min(h)))/numberOfBins));



m=zeros(1,numberOfBins);
for i=1:numberOfBins
    [a,b] = find(c==i);
    for j=1:numel(a)
        m(1,i) = m(1,i)+s(a(j),b(j))*v(a(j),b(j));
    end
end
m=m./sum(m);

[score,temple] = templet_compare(h,c,m,numberOfBins);

% figure;
% subplot(2, 2, 1);
% imshow(rgbImage);
% title('Original Color Image', 'FontSize', fontSize);
% set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
% 
% subplot(2, 2, 2); 
% bar(grayLevels, pixelCount);
% grid on;
% title('Histogram of Hue Channel', 'FontSize', fontSize);
% xlim([grayLevels(1) grayLevels(end)]);


m = m.*numel(c);
m = m/max(m);
cmap = hsv(numberOfBins);
subplot(2, 2, 3);
drawWheel(m, cmap,zeros(1,360));



[n index] = sort(score);
final = n(1);

% figure;
% set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
% for i=1:8
%     subplot(2, 4, i);
%     drawWheel(m, cmap,temple(:,:,index(i)));
%     title(n(i));
% end




%=============================================================

function drawWheel(r, cmap,temp)

n = numel(r);
innerRadius =  90;
outerRadius = 100;
angles = linspace(0,2*pi,n+1);
newR = innerRadius*(1-r);
newR_t = innerRadius*(1-temp);

for k = 1:n
    drawSpoke(newR_t(k), innerRadius, angles(k), angles(k+1), [.75 .75 .75]);
    drawSpoke(innerRadius, outerRadius, angles(k), angles(k+1), cmap(k,:));
	drawSpoke(newR(k), innerRadius, angles(k), angles(k+1), cmap(k,:));
    %drawSpoke(newR_t(k), innerRadius, angles(k), angles(k+1), [.75 .75 .75]);
end

line(0,0,'marker','.');
%line(cos(angles)*outerRadius, sin(angles)*outerRadius, 'LineWidth', 3, 'Color', 'k');
%line(cos(angles)*innerRadius, sin(angles)*innerRadius, 'LineWidth', 3, 'Color', 'k');
axis equal;

%=============================================================

function drawSpoke(ri,ro,thetaStart,thetaEnd,c)
xInnerLeft  = cos(thetaStart) * ri;
xInnerRight = cos(thetaEnd)   * ri;
xOuterLeft  = cos(thetaStart) * ro;
xOuterRight = cos(thetaEnd)   * ro;

yInnerLeft  = sin(thetaStart) * ri;
yInnerRight = sin(thetaEnd)   * ri;
yOuterLeft  = sin(thetaStart) * ro;
yOuterRight = sin(thetaEnd)   * ro;

X = [xInnerLeft, xInnerRight, xOuterRight xOuterLeft];
Y = [yInnerLeft, yInnerRight, yOuterRight yOuterLeft];

h = patch(X,Y,c);
set(h,'edgeColor', 'none');


%=============================================================
 

function [score,temple] = templet_compare(h,c,m,numberOfBins) 

value = ones(1,8)*numberOfBins;
%value = zeros(1,8);
templet_save=zeros(1,numberOfBins,8);

[h,l]=size(h);


norm1=normpdf(10:1:180,10,10);
norm1=norm1.*9+1;

%=====i
for k=1:numberOfBins
    angle1 = k+10;
    if(angle1>numberOfBins)
        angle1 = angle1-numberOfBins;
    end
    
    templet = zeros(1,numberOfBins);
    
    if k+19>numberOfBins
       templet(k:numberOfBins)=1;
       templet(1:k+19-numberOfBins)=1;
    else 
       templet(k:k+19)=1;
    end
   
    s1=zeros(1,numberOfBins);
    for i=1:numberOfBins
        if(templet(i)~=1)
            dis = min(abs(i-angle1),numberOfBins-abs(i-angle1));
            s1(i) = norm1(dis-10+1);
        end
    end   
 
    fix1= sum(s1)/(numberOfBins)*20/180;
    p1=zeros(1,numberOfBins);
    for i=1:numberOfBins
        if s1(i)~=0
            p1(i)= s1(i);
        else
            p1(i)= fix1;
        end
    end
    
    result1 = 0;
    for i=1:numberOfBins
        if(m(i)~=0)
            result1 = result1 + m(i)*p1(i);
        end
    end
    
    %result1 =result1 * 2^(1+5/180);
    if result1 <value(1)
        value(1) = result1;
        templet_save(:,:,1) = templet;
    end 
   
end

norm2=normpdf(50:1:180,50,50);
norm2=norm2.*1.8+1;

%======v
for k=1:numberOfBins
    angle2 = k+50;
    if(angle2>numberOfBins)
        angle2 = angle2-numberOfBins;
    end
    templet = zeros(1,numberOfBins);
    
    if k+99>numberOfBins
       templet(k:numberOfBins)=1;
       templet(1:k+99-numberOfBins)=1;
    else
       templet(k:k+99)=1;
    end
    
    s2=zeros(1,numberOfBins);
    for i=1:numberOfBins
       if(templet(i)~=1)
            dis = min(abs(i-angle2),numberOfBins-abs(i-angle2));
            s2(i) = norm2(dis-50+1);
        end
    end   
    
    fix2= sum(s2)/(numberOfBins)*100/180;
    p2=zeros(1,numberOfBins);
    for i=1:numberOfBins
        if s2(i)~=0
            p2(i)= s2(i);
        else
            p2(i)= fix2;
        end
    end

    result2 = 0;
    for i=1:numberOfBins
        if(m(i)~=0)
            result2 = result2 + m(i)*p2(i);
        end
    end
    %result2 =result2 * 2^(1+25/180);
    if result2 <value(2)
        value(2) = result2;
        templet_save(:,:,2) = templet;
    end 
        
end

norm3=normpdf(90:1:180,90,90);
norm3=norm3+1;

%=====t
for k=1:numberOfBins
    angle3 = k+90;
    if(angle3>numberOfBins)
        angle3 = angle3-numberOfBins;
    end
    templet = zeros(1,numberOfBins);
    
    if k+179>numberOfBins
       templet(k:numberOfBins)=1;
       templet(1:k+179-numberOfBins)=1;
    else
       templet(k:k+179)=1;
    end
    
    s3=zeros(1,numberOfBins);
    for i=1:numberOfBins
        if(templet(i)~=1)
            dis = min(abs(i-angle3),numberOfBins-abs(i-angle3));
            s3(i) = norm3(dis-90+1);
        end
    end   
    
    fix3= sum(s3)/(numberOfBins)*180/180;
    p3=zeros(1,numberOfBins);
    for i=1:numberOfBins
        if s3(i)~=0
            p3(i)= s3(i);
        else
            p3(i)= fix3;
        end
    end
    
    result3 = 0;
    for i=1:numberOfBins
        if(m(i)~=0)
            result3 = result3 + m(i)*p3(i);
        end
    end

    result3 =result3  * 2^(1+45/180);
    if result3 <value(3)
        value(3) = result3;
        templet_save(:,:,3) = templet;
    end 
          
end

norm4=normpdf(10:1:180,10,10);
norm4=norm4.*9+1;

% %%=====l
for k=1:numberOfBins/2
    angle41 = k+10;
    if(angle41>numberOfBins)
        angle41 = angle41-numberOfBins;
    end
    angle42 = k+numberOfBins/2+10;
    if(angle42>numberOfBins)
        angle42 = angle42-numberOfBins;
    end
    
    templet = zeros(1,numberOfBins);
    
    if k+19>numberOfBins/2
        templet(k:k+19) = 1;
        templet(k+numberOfBins/2:numberOfBins) = -1;
        templet(1:k+numberOfBins/2+19-numberOfBins) = -1;
    else
        templet(k:k+19) = 1;
        templet(k+numberOfBins/2:k+19+numberOfBins/2) = -1;
    end
    
    s41=zeros(1,numberOfBins);
    for i=1:numberOfBins
        if(templet(i)~=1)
            dis = min(abs(i-angle41),numberOfBins-abs(i-angle41));
            s41(i) = norm4(dis-10+1);
        end
    end 
    
    s42=zeros(1,numberOfBins);
    for i=1:numberOfBins
        if(templet(i)~=-1)
            dis = min(abs(i-angle42),numberOfBins-abs(i-angle42));
            s42(i) = norm4(dis-10+1);
        end
    end  
    
    fix41= sum(s41)/numberOfBins*20/180;
    fix42= sum(s42)/numberOfBins*20/180;
    
    p4=zeros(1,numberOfBins);
    for i=1:numberOfBins
        if s41(i)~=0 && s42(i)~=0
            p4(i)= max(s41(i),s42(i))*2-1;
        else
            if s41(i)==0
                p4(i) = fix41+s42(i)*5/180;
            else
                p4(i) = fix42+s41(i)*5/180;
            end
        end
    end
    
    result4 = 0;
    for i=1:numberOfBins
        if(m(i)~=0)
            result4 = result4 + m(i)*p4(i);
        end
    end

    result4 =result4  * 2^(1+10/180);
    if result4 <value(4)
        value(4) = result4;
        templet = abs(templet);
        templet_save(:,:,4) = templet;
    end    
end

norm5=normpdf(50:1:180,50,50);
norm5=norm5.*1.8+1;

%=====x
for k=1:numberOfBins/2
    angle51 = k+50;
    if(angle51>numberOfBins)
        angle51 = angle51-numberOfBins;
    end
    angle52 = k+numberOfBins/2+50;
    if(angle52>numberOfBins)
        angle52 = angle52-numberOfBins;
    end
    
    templet = zeros(1,numberOfBins);
    
    
    if k+99>numberOfBins/2
        templet(k:k+99) = 1;
        templet(k+numberOfBins/2:numberOfBins) = -1;
        templet(1:k+numberOfBins/2+99-numberOfBins) = -1;
    else
        templet(k:k+99) = 1;
        templet(k+numberOfBins/2:k+99+numberOfBins/2) = -1;
    end
    
    s51=zeros(1,numberOfBins);
    for i=1:numberOfBins
        if(templet(i)~=1)
            dis = min(abs(i-angle51),numberOfBins-abs(i-angle51));
            s51(i) = norm5(dis-50+1);
        end
    end 
    
    s52=zeros(1,numberOfBins);
    for i=1:numberOfBins
        if(templet(i)~=-1)
            dis = min(abs(i-angle52),numberOfBins-abs(i-angle52));
            s52(i) = norm5(dis-50+1);
        end
    end  
    
    fix51= sum(s51)/numberOfBins*100/180;
    fix52= sum(s52)/numberOfBins*100/180;
    
    p5=zeros(1,numberOfBins);
    for i=1:numberOfBins
        if s51(i)~=0 && s52(i)~=0
            p5(i)= max(s51(i),s52(i))*2-1;
        else
            if s51(i)==0
                p5(i)= fix51+s52(i)*25/180;
            else
                p5(i)= fix52+s51(i)*25/180;
            end
        end
    end
    
    result5 = 0;
    for i=1:numberOfBins
        if(m(i)~=0)
            result5 = result5 + m(i)*p5(i);
        end
    end
    result5 =result5 * 2^(1+50/180);
    if result5 <value(5)
        templet = abs(templet);
        value(5) = result5;
        templet_save(:,:,5) = templet;
    end      
end

norm61=normpdf(50:1:180,50,50);
norm61=norm61.*1.8+1;
norm62=normpdf(10:1:180,10,10);
norm62=norm62.*9+1;

%%=====y
for k=1:numberOfBins
    angle61 = k+50;
    if(angle61>numberOfBins)
        angle61 = angle61-numberOfBins;
    end
    angle62 = angle61+numberOfBins/2;
    if(angle62>numberOfBins)
        angle62 = angle62-numberOfBins;
    end
    
    templet = zeros(1,numberOfBins);
    if k+99>numberOfBins
       templet(k:numberOfBins)=1;
       templet(1:k+99-numberOfBins)=1;
    else
       templet(k:k+99)=1;
    end
    
    if k+49+numberOfBins/2-9>numberOfBins
        templet(k+49+numberOfBins/2-9-numberOfBins:k+49+numberOfBins/2-9+19-numberOfBins)=-1;
    else
        if k+numberOfBins/2+49+1+9>numberOfBins
            templet(k+49+numberOfBins/2-9:numberOfBins)=-1;
            templet(1:k+numberOfBins/2+49+1+9-numberOfBins)=-1;
        else
            templet(k+49+numberOfBins/2-9:k+numberOfBins/2+49+1+9)=-1;
        end
    end
   
    s61=zeros(1,numberOfBins);
    for i=1:numberOfBins
        if(templet(i)~=1)
            dis = min(abs(i-angle61),numberOfBins-abs(i-angle61));
            s61(i) = norm61(dis-50+1);
        end
    end 
    
    s62=zeros(1,numberOfBins);
    for i=1:numberOfBins
        if(templet(i)~=-1)
            dis = min(abs(i-angle62),numberOfBins-abs(i-angle62));
            s62(i) = norm62(dis-10+1);
        end
    end  
    
    fix61= sum(s61)/numberOfBins*100/180;
    fix62= sum(s62)/numberOfBins*20/180;
    
    p6=zeros(1,numberOfBins);
    for i=1:numberOfBins
        if s61(i)~=0 && s62(i)~=0
            p6(i) = max(s61(i),s62(i))*2-1;
        else
            if s61(i)==0
                p6(i)= fix61+s62(i)*25/180;
            else
                p6(i)= fix62+s61(i)*5/180;
            end
        end
    end
    result6 = 0;
    for i=1:numberOfBins
        if(m(i)~=0)
            result6 = result6 + p6(i)*m(i);
        end
    end
    result6 =result6 * 2^(1+30/180);
    if result6 <value(6)
        value(6) = result6;
        templet = abs(templet);
        templet_save(:,:,6) = templet;
    end      
    
end

% 
% %=====l

norm71=normpdf(50:1:180,50,50);
norm71=norm71.*1.8+1;
norm72=normpdf(10:1:180,10,10);
norm72=norm72.*9+1;

for k=1:numberOfBins
    angle71 = k+50;
    if(angle71>numberOfBins)
        angle71 = angle71-numberOfBins;
    end
    angle72 = angle71+numberOfBins/4;
    if(angle72>numberOfBins)
        angle72 = angle72-numberOfBins;
    end
    
    templet = zeros(1,numberOfBins);
    
    if k+99>numberOfBins
       templet(k:numberOfBins)=1;
       templet(1:k+99-numberOfBins)=1;
    else
       templet(k:k+99)=1;
    end
    
    if k+49+90-9>numberOfBins
        templet(k+49+90-9-numberOfBins:k+49+90-9+19-numberOfBins)=-1;
    else
        if k+90+49+1+9>numberOfBins
            templet(k+49+90-9:numberOfBins)=-1;
            templet(1:k+90+49+1+9-numberOfBins)=-1;
        else
            templet(k+49+90-9:k+90+49+1+9)=-1;
        end
    end

    s71=zeros(1,numberOfBins);
    for i=1:numberOfBins
        if(templet(i)~=1)
            dis = min(abs(i-angle71),numberOfBins-abs(i-angle71));
            s71(i) = norm71(dis-50+1);
        end
    end 
    
    s72=zeros(1,numberOfBins);
    for i=1:numberOfBins
        if(templet(i)~=-1)
            dis = min(abs(i-angle72),numberOfBins-abs(i-angle72));
            s72(i) = norm72(dis-10+1);
        end
    end  
    
    fix71= sum(s71)/numberOfBins*100/180;
    fix72= sum(s72)/numberOfBins*20/180;
    
    p7=zeros(1,numberOfBins);
    for i=1:numberOfBins
        if s71(i)~=0 && s72(i)~=0
            p7(i)= max(s71(i),s72(i))*2-1;
        else
            if s71(i)==0
                p7(i)= fix71+s72(i)*25/180;
            else
                p7(i)= fix72+s71(i)*10/180;
            end
        end
    end
      
    result7 = 0;
    for i=1:numberOfBins
        if(m(i)~=0)
            result7 = result7 + m(i)*p7(i);
        end
    end
    result7 =result7 * 2^(1+30/180);
    if result7 <value(7)
        value(7) = result7;
        templet=abs(templet);
        templet_save(:,:,7) = templet;
    end       
end
% %%=====j

norm81=normpdf(50:1:180,50,50);
norm81=norm81.*1.8+1;
norm82=normpdf(10:1:180,10,10);
norm82=norm82.*9+1;

for k=1:numberOfBins

    angle81 = k+50;
    if(angle81>numberOfBins)
        angle81 = angle81-numberOfBins;
    end
    angle82 = angle81+numberOfBins/4*3;
    if(angle82>numberOfBins)
        angle82 = angle82-numberOfBins;
    end
    
    templet = zeros(1,numberOfBins);

    
    if k+99>numberOfBins
       templet(k:numberOfBins)=1;
       templet(1:k+99-numberOfBins)=1;
    else
       templet(k:k+99)=1;
    end
    
    if k+49+90+numberOfBins/2-9>numberOfBins
        templet(k+49+90+numberOfBins/2-9-numberOfBins:k+49+numberOfBins/2+90-9+19-numberOfBins)=-1;
    else
        if k+90+numberOfBins/2+49+1+9>numberOfBins
            templet(k+49+90+numberOfBins/2-9:numberOfBins)=-1;
            templet(1:k+90+numberOfBins/2+49+1+9-numberOfBins)=-1;
        else
            templet(k+49+90+numberOfBins/2-9:k+90+numberOfBins/2+49+1+9)=-1;
        end
    end

    
    s81=zeros(1,numberOfBins);
    for i=1:numberOfBins
        if(templet(i)~=1)
            dis = min(abs(i-angle81),numberOfBins-abs(i-angle81));
            s81(i) = norm81(dis-50+1);
        end
    end 
    
    s82=zeros(1,numberOfBins);
    for i=1:numberOfBins
        if(templet(i)~=-1)
            dis = min(abs(i-angle82),numberOfBins-abs(i-angle82));
            s82(i) = norm82(dis-10+1);
        end
    end  
    

    fix81= sum(s81)/numberOfBins*100/180;
    fix82= sum(s82)/numberOfBins*20/180;
    
    p8=zeros(1,numberOfBins);
    for i=1:numberOfBins
        if s81(i)~=0 && s82(i)~=0
            p8(i)= max(s81(i),s82(i))*2-1;%%%%%
        else          
            if s81(i)==0
                p8(i)= fix81+s82(i)*25/180;
            else
                p8(i)= fix82+s81(i)*5/180;
            end
        end
    end
    
    result8 = 0;
    for i=1:numberOfBins
        if(m(i)~=0)
            result8 = result8 + m(i)*p8(i);
        end
    end
     result8 =result8 * 2^(1+30/180);
    if result8 <value(8)
        value(8) = result8;
        templet = abs(templet);
        templet_save(:,:,8) = templet;
    end      
    
end

%score = min(value);
value;
%temple = templet_save(:,:,find(value==score));
score = value;
temple = templet_save;

